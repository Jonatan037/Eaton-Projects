/**
 * Embedding Service for League Data
 * Indexes league data into pgvector for RAG-powered AI chat
 */

import prisma from '@/lib/db';
import { Prisma } from '@prisma/client';

// Document types for embeddings
export type DocumentType = 
  | 'standings'
  | 'schedule'
  | 'results'
  | 'teams'
  | 'drivers'
  | 'scoring'
  | 'rules';

interface EmbeddingDocument {
  type: DocumentType;
  content: string;
  metadata?: Record<string, unknown>;
  documentId?: string;
}

/**
 * Generate embeddings using OpenAI's text-embedding-ada-002
 * Returns null if OpenAI key is not configured
 */
async function generateEmbedding(text: string): Promise<number[] | null> {
  const apiKey = process.env.OPENAI_API_KEY;
  
  if (!apiKey) {
    console.warn('OPENAI_API_KEY not set, skipping embedding generation');
    return null;
  }

  try {
    const response = await fetch('https://api.openai.com/v1/embeddings', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'text-embedding-ada-002',
        input: text.slice(0, 8000), // Limit to ~8000 chars for token limits
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error('OpenAI embedding error:', error);
      return null;
    }

    const data = await response.json();
    return data.data[0].embedding;
  } catch (error) {
    console.error('Failed to generate embedding:', error);
    return null;
  }
}

/**
 * Format vector for PostgreSQL pgvector
 */
function formatVector(embedding: number[]): string {
  return `[${embedding.join(',')}]`;
}

/**
 * Store an embedding document
 */
async function storeEmbedding(
  leagueId: string,
  doc: EmbeddingDocument,
  embedding: number[] | null
): Promise<void> {
  // Delete existing embedding for this document type + id
  await prisma.leagueEmbedding.deleteMany({
    where: {
      leagueId,
      documentType: doc.type,
      documentId: doc.documentId ?? null,
    },
  });

  // Insert new embedding
  if (embedding) {
    // Use raw SQL for vector insertion
    await prisma.$executeRaw`
      INSERT INTO league_embeddings (id, "leagueId", "documentType", "documentId", content, embedding, metadata, "createdAt", "updatedAt")
      VALUES (
        ${crypto.randomUUID()},
        ${leagueId},
        ${doc.type},
        ${doc.documentId ?? null},
        ${doc.content},
        ${formatVector(embedding)}::vector,
        ${JSON.stringify(doc.metadata ?? {})}::jsonb,
        NOW(),
        NOW()
      )
    `;
  } else {
    // Store without embedding (for fallback)
    await prisma.leagueEmbedding.create({
      data: {
        leagueId,
        documentType: doc.type,
        documentId: doc.documentId,
        content: doc.content,
        metadata: doc.metadata ? doc.metadata as Prisma.InputJsonValue : undefined,
      },
    });
  }
}

/**
 * Generate standings document content
 */
async function generateStandingsDocument(leagueId: string): Promise<EmbeddingDocument> {
  const results = await prisma.result.findMany({
    where: {
      round: { leagueId },
    },
    include: {
      driver: { include: { team: true } },
      round: { include: { track: true } },
    },
  });

  // Calculate driver standings
  const driverPoints: Record<string, { name: string; team: string; points: number; wins: number; podiums: number }> = {};
  
  for (const result of results) {
    const driverId = result.driverId;
    if (!driverPoints[driverId]) {
      driverPoints[driverId] = {
        name: result.driver.fullName,
        team: result.driver.team?.name ?? 'Unknown',
        points: 0,
        wins: 0,
        podiums: 0,
      };
    }
    driverPoints[driverId].points += result.points;
    if (result.position === 1) driverPoints[driverId].wins++;
    if (result.position && result.position <= 3) driverPoints[driverId].podiums++;
  }

  const standings = Object.values(driverPoints)
    .sort((a, b) => b.points - a.points);

  // Calculate constructor standings
  const teamPoints: Record<string, { name: string; points: number }> = {};
  for (const driver of standings) {
    if (!teamPoints[driver.team]) {
      teamPoints[driver.team] = { name: driver.team, points: 0 };
    }
    teamPoints[driver.team].points += driver.points;
  }

  const constructorStandings = Object.values(teamPoints)
    .sort((a, b) => b.points - a.points);

  let content = 'DRIVER CHAMPIONSHIP STANDINGS:\n';
  standings.forEach((d, i) => {
    content += `${i + 1}. ${d.name} (${d.team}) - ${d.points} points, ${d.wins} wins, ${d.podiums} podiums\n`;
  });

  content += '\nCONSTRUCTOR CHAMPIONSHIP STANDINGS:\n';
  constructorStandings.forEach((t, i) => {
    content += `${i + 1}. ${t.name} - ${t.points} points\n`;
  });

  return {
    type: 'standings',
    content,
    metadata: {
      driverCount: standings.length,
      teamCount: constructorStandings.length,
      leader: standings[0]?.name ?? null,
      constructorLeader: constructorStandings[0]?.name ?? null,
    },
  };
}

/**
 * Generate schedule document content
 */
async function generateScheduleDocument(leagueId: string): Promise<EmbeddingDocument> {
  const rounds = await prisma.round.findMany({
    where: { leagueId },
    include: { track: true },
    orderBy: { roundNumber: 'asc' },
  });

  const now = new Date();
  let content = 'RACE CALENDAR AND SCHEDULE:\n\n';

  for (const round of rounds) {
    const date = round.scheduledAt.toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
    const isPast = round.scheduledAt < now;
    const status = round.status === 'COMPLETED' ? '(Completed)' : 
                   round.status === 'ANNULLED' ? '(Cancelled)' :
                   isPast ? '(Pending Results)' : '(Upcoming)';
    
    content += `Round ${round.roundNumber}: ${round.track?.name ?? round.name ?? 'TBD'}\n`;
    content += `  Date: ${date} ${status}\n`;
    content += `  Track: ${round.track?.name ?? 'TBD'}, ${round.track?.country ?? ''}\n`;
    content += `  Sessions: ${round.hasQuali ? 'Qualifying' : ''}${round.hasSprint ? ' + Sprint' : ''} + Race\n`;
    if (round.laps) content += `  Laps: ${round.laps}\n`;
    content += '\n';
  }

  const upcomingRounds = rounds.filter(r => r.scheduledAt > now && r.status === 'SCHEDULED');
  const nextRound = upcomingRounds[0];

  return {
    type: 'schedule',
    content,
    metadata: {
      totalRounds: rounds.length,
      completedRounds: rounds.filter(r => r.status === 'COMPLETED').length,
      nextRound: nextRound ? {
        number: nextRound.roundNumber,
        track: nextRound.track?.name,
        date: nextRound.scheduledAt.toISOString(),
      } : null,
    },
  };
}

/**
 * Generate teams & drivers document
 */
async function generateTeamsDocument(leagueId: string): Promise<EmbeddingDocument> {
  const teams = await prisma.team.findMany({
    where: { leagueId },
    include: { drivers: true },
    orderBy: { name: 'asc' },
  });

  let content = 'TEAMS AND DRIVERS:\n\n';

  for (const team of teams) {
    content += `${team.name}${team.shortName ? ` (${team.shortName})` : ''}\n`;
    content += `  Country: ${team.country ?? 'Unknown'}\n`;
    content += `  Colors: ${team.primaryColor ?? 'N/A'}\n`;
    content += `  Drivers:\n`;
    
    const regularDrivers = team.drivers.filter(d => !d.isReserve);
    const reserveDrivers = team.drivers.filter(d => d.isReserve);
    
    for (const driver of regularDrivers) {
      content += `    - ${driver.fullName}${driver.shortName ? ` (${driver.shortName})` : ''}`;
      if (driver.number) content += ` #${driver.number}`;
      if (driver.country) content += ` - ${driver.country}`;
      content += '\n';
    }
    
    for (const driver of reserveDrivers) {
      content += `    - ${driver.fullName} (Reserve Driver)\n`;
    }
    content += '\n';
  }

  return {
    type: 'teams',
    content,
    metadata: {
      teamCount: teams.length,
      driverCount: teams.reduce((acc, t) => acc + t.drivers.length, 0),
    },
  };
}

/**
 * Generate scoring rules document
 */
async function generateScoringDocument(leagueId: string): Promise<EmbeddingDocument> {
  const scoring = await prisma.scoring.findUnique({
    where: { leagueId },
  });

  const league = await prisma.league.findUnique({
    where: { id: leagueId },
    select: { rules: true, scoringConfig: true },
  });

  let content = 'SCORING SYSTEM AND RULES:\n\n';

  if (scoring) {
    const racePoints = scoring.racePoints as Record<string, number>;
    const sprintPoints = scoring.sprintPoints as Record<string, number>;

    content += 'RACE POINTS:\n';
    Object.entries(racePoints)
      .sort(([a], [b]) => parseInt(a) - parseInt(b))
      .forEach(([pos, pts]) => {
        content += `  ${pos}${getOrdinalSuffix(parseInt(pos))}: ${pts} points\n`;
      });

    content += '\nSPRINT RACE POINTS:\n';
    Object.entries(sprintPoints)
      .sort(([a], [b]) => parseInt(a) - parseInt(b))
      .forEach(([pos, pts]) => {
        content += `  ${pos}${getOrdinalSuffix(parseInt(pos))}: ${pts} points\n`;
      });

    content += '\nBONUS POINTS:\n';
    content += `  Fastest Lap: ${scoring.fastestLapPoints} point(s) (only for top ${scoring.fastestLapEligibleTop} finishers)\n`;
    content += `  Pole Position: ${scoring.polePositionPoints} point(s)\n`;

    content += '\nPENALTIES:\n';
    content += `  DNF Penalty: ${scoring.dnfPenalty} points\n`;
    content += `  Attendance Penalty: ${scoring.attendancePenalty} points\n`;
  } else {
    content += 'Standard F1 scoring system is used.\n';
  }

  if (league?.rules) {
    content += '\nLEAGUE RULES:\n';
    content += league.rules;
  }

  return {
    type: 'scoring',
    content,
    metadata: {
      hasCustomScoring: !!scoring,
      fastestLapPoints: scoring?.fastestLapPoints ?? 1,
      polePoints: scoring?.polePositionPoints ?? 0,
    },
  };
}

/**
 * Generate race results document for a specific round
 */
async function generateResultsDocument(
  leagueId: string,
  roundId: string
): Promise<EmbeddingDocument> {
  const round = await prisma.round.findUnique({
    where: { id: roundId },
    include: {
      track: true,
      results: {
        include: {
          driver: { include: { team: true } },
        },
        orderBy: { position: 'asc' },
      },
    },
  });

  if (!round) {
    return {
      type: 'results',
      content: 'No results found for this round.',
      documentId: roundId,
    };
  }

  let content = `RACE RESULTS - ROUND ${round.roundNumber}: ${round.track?.name ?? round.name ?? 'Unknown'}\n`;
  content += `Date: ${round.scheduledAt.toLocaleDateString()}\n`;
  content += `Status: ${round.status}\n\n`;

  // Group results by session type
  const resultsBySession: Record<string, typeof round.results> = {};
  for (const result of round.results) {
    const session = result.sessionType;
    if (!resultsBySession[session]) {
      resultsBySession[session] = [];
    }
    resultsBySession[session].push(result);
  }

  for (const [session, results] of Object.entries(resultsBySession)) {
    content += `${session} RESULTS:\n`;
    for (const result of results) {
      const posStr = result.position ? `P${result.position}` : result.status;
      const extras: string[] = [];
      if (result.fastestLap) extras.push('Fastest Lap');
      if (result.pole) extras.push('Pole Position');
      
      content += `  ${posStr}: ${result.driver.fullName} (${result.driver.team?.name ?? 'Unknown'}) - ${result.points} pts`;
      if (extras.length > 0) content += ` [${extras.join(', ')}]`;
      content += '\n';
    }
    content += '\n';
  }

  return {
    type: 'results',
    content,
    documentId: roundId,
    metadata: {
      roundNumber: round.roundNumber,
      trackName: round.track?.name,
      status: round.status,
      resultCount: round.results.length,
    },
  };
}

/**
 * Index all league data into embeddings
 */
export async function indexLeagueData(leagueId: string): Promise<{
  success: boolean;
  documentsIndexed: number;
  errors: string[];
}> {
  const errors: string[] = [];
  let documentsIndexed = 0;

  try {
    // Generate and store standings
    const standingsDoc = await generateStandingsDocument(leagueId);
    const standingsEmbed = await generateEmbedding(standingsDoc.content);
    await storeEmbedding(leagueId, standingsDoc, standingsEmbed);
    documentsIndexed++;

    // Generate and store schedule
    const scheduleDoc = await generateScheduleDocument(leagueId);
    const scheduleEmbed = await generateEmbedding(scheduleDoc.content);
    await storeEmbedding(leagueId, scheduleDoc, scheduleEmbed);
    documentsIndexed++;

    // Generate and store teams
    const teamsDoc = await generateTeamsDocument(leagueId);
    const teamsEmbed = await generateEmbedding(teamsDoc.content);
    await storeEmbedding(leagueId, teamsDoc, teamsEmbed);
    documentsIndexed++;

    // Generate and store scoring
    const scoringDoc = await generateScoringDocument(leagueId);
    const scoringEmbed = await generateEmbedding(scoringDoc.content);
    await storeEmbedding(leagueId, scoringDoc, scoringEmbed);
    documentsIndexed++;

    // Generate and store results for each completed round
    const completedRounds = await prisma.round.findMany({
      where: {
        leagueId,
        status: 'COMPLETED',
      },
      select: { id: true },
    });

    for (const round of completedRounds) {
      try {
        const resultsDoc = await generateResultsDocument(leagueId, round.id);
        const resultsEmbed = await generateEmbedding(resultsDoc.content);
        await storeEmbedding(leagueId, resultsDoc, resultsEmbed);
        documentsIndexed++;
      } catch (error) {
        errors.push(`Failed to index round ${round.id}: ${error}`);
      }
    }

    return { success: true, documentsIndexed, errors };
  } catch (error) {
    errors.push(`Failed to index league: ${error}`);
    return { success: false, documentsIndexed, errors };
  }
}

/**
 * Search embeddings using vector similarity
 */
export async function searchEmbeddings(
  leagueId: string,
  query: string,
  limit: number = 5
): Promise<Array<{
  content: string;
  documentType: string;
  similarity: number;
  metadata: Record<string, unknown> | null;
}>> {
  const queryEmbedding = await generateEmbedding(query);

  if (!queryEmbedding) {
    // Fallback: return all documents without vector search
    const docs = await prisma.leagueEmbedding.findMany({
      where: { leagueId },
      take: limit,
      orderBy: { updatedAt: 'desc' },
    });

    return docs.map(d => ({
      content: d.content,
      documentType: d.documentType,
      similarity: 0,
      metadata: d.metadata as Record<string, unknown> | null,
    }));
  }

  // Use raw SQL for vector similarity search
  const results = await prisma.$queryRaw<Array<{
    content: string;
    documentType: string;
    similarity: number;
    metadata: unknown;
  }>>`
    SELECT 
      content,
      "documentType",
      1 - (embedding <=> ${formatVector(queryEmbedding)}::vector) as similarity,
      metadata
    FROM league_embeddings
    WHERE "leagueId" = ${leagueId}
      AND embedding IS NOT NULL
    ORDER BY embedding <=> ${formatVector(queryEmbedding)}::vector
    LIMIT ${limit}
  `;

  return results.map(r => ({
    ...r,
    metadata: r.metadata as Record<string, unknown> | null,
  }));
}

/**
 * Get all embeddings for a league (without vector search)
 */
export async function getLeagueContext(leagueId: string): Promise<string> {
  const docs = await prisma.leagueEmbedding.findMany({
    where: { leagueId },
    orderBy: [
      { documentType: 'asc' },
      { updatedAt: 'desc' },
    ],
  });

  return docs.map(d => d.content).join('\n\n---\n\n');
}

// Helper function
function getOrdinalSuffix(n: number): string {
  const s = ['th', 'st', 'nd', 'rd'];
  const v = n % 100;
  return s[(v - 20) % 10] || s[v] || s[0];
}
