'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import prisma from '@/lib/db';
import { createClient } from '@/lib/supabase/server';
import { 
  LeagueCreateSchema, 
  LeagueUpdateSchema,
  TeamCreateSchema,
  TeamUpdateSchema,
  DriverCreateSchema,
  DriverUpdateSchema,
  RoundCreateSchema,
  RoundUpdateSchema,
  ResultCreateSchema,
  ScoringConfigSchema,
} from '@/schemas';

// ============================================
// LEAGUE ACTIONS
// ============================================

export async function createLeague(formData: FormData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const rawData = {
    name: formData.get('name'),
    slug: formData.get('slug'),
    description: formData.get('description'),
    timezone: formData.get('timezone') || 'UTC',
    visibility: formData.get('visibility') || 'PUBLIC',
  };

  const validatedData = LeagueCreateSchema.parse(rawData);

  const league = await prisma.league.create({
    data: {
      ...validatedData,
      memberships: {
        create: {
          userId: user.id,
          role: 'OWNER',
        },
      },
    },
  });

  // Log the action
  await prisma.auditLog.create({
    data: {
      leagueId: league.id,
      userId: user.id,
      action: 'CREATED_LEAGUE',
      metadata: { leagueName: league.name },
    },
  });

  revalidatePath('/leagues');
  redirect(`/leagues/${league.slug}`);
}

export async function updateLeague(leagueId: string, formData: FormData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const league = await prisma.league.findUnique({
    where: { id: leagueId },
    include: { memberships: true },
  });

  if (!league) {
    throw new Error('League not found');
  }

  const membership = league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  const rawData = {
    name: formData.get('name') || undefined,
    slug: formData.get('slug') || undefined,
    description: formData.get('description') || undefined,
    timezone: formData.get('timezone') || undefined,
    visibility: formData.get('visibility') || undefined,
    discordWebhook: formData.get('discordWebhook') || undefined,
  };

  const validatedData = LeagueUpdateSchema.parse(rawData);

  const updatedLeague = await prisma.league.update({
    where: { id: leagueId },
    data: validatedData,
  });

  await prisma.auditLog.create({
    data: {
      leagueId: league.id,
      userId: user.id,
      action: 'UPDATED_LEAGUE',
      metadata: { changes: validatedData },
    },
  });

  revalidatePath(`/leagues/${updatedLeague.slug}`);
  revalidatePath(`/leagues/${updatedLeague.slug}/admin`);
  
  return { success: true };
}

export async function deleteLeague(leagueId: string) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const league = await prisma.league.findUnique({
    where: { id: leagueId },
    include: { memberships: true },
  });

  const membership = league?.memberships.find(m => m.userId === user.id);
  if (!league || membership?.role !== 'OWNER') {
    throw new Error('Unauthorized');
  }

  await prisma.league.delete({
    where: { id: leagueId },
  });

  revalidatePath('/leagues');
  redirect('/leagues');
}

// ============================================
// TEAM ACTIONS
// ============================================

export async function createTeam(leagueId: string, formData: FormData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const league = await prisma.league.findUnique({
    where: { id: leagueId },
    include: { memberships: true },
  });

  if (!league) {
    throw new Error('League not found');
  }

  const membership = league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  const rawData = {
    name: formData.get('name'),
    shortName: formData.get('shortName'),
    country: formData.get('country'),
    primaryColor: formData.get('primaryColor'),
    secondaryColor: formData.get('secondaryColor'),
    logo: formData.get('logo'),
  };

  const validatedData = TeamCreateSchema.parse(rawData);

  const team = await prisma.team.create({
    data: {
      ...validatedData,
      leagueId,
    },
  });

  await prisma.auditLog.create({
    data: {
      leagueId,
      userId: user.id,
      action: 'CREATED_TEAM',
      metadata: { teamName: team.name },
    },
  });

  revalidatePath(`/leagues/${league.slug}/admin`);
  
  return { success: true, teamId: team.id };
}

export async function updateTeam(teamId: string, formData: FormData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const team = await prisma.team.findUnique({
    where: { id: teamId },
    include: { league: { include: { memberships: true } } },
  });

  if (!team) {
    throw new Error('Team not found');
  }

  const membership = team.league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  const rawData = {
    name: formData.get('name') || undefined,
    shortName: formData.get('shortName') || undefined,
    country: formData.get('country') || undefined,
    primaryColor: formData.get('primaryColor') || undefined,
    secondaryColor: formData.get('secondaryColor') || undefined,
    logo: formData.get('logo') || undefined,
    isActive: formData.get('isActive') === 'true',
  };

  const validatedData = TeamUpdateSchema.parse(rawData);

  await prisma.team.update({
    where: { id: teamId },
    data: validatedData,
  });

  await prisma.auditLog.create({
    data: {
      leagueId: team.leagueId,
      userId: user.id,
      action: 'UPDATED_TEAM',
      metadata: { teamId, changes: validatedData },
    },
  });

  revalidatePath(`/leagues/${team.league.slug}/admin`);
  
  return { success: true };
}

export async function deleteTeam(teamId: string) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const team = await prisma.team.findUnique({
    where: { id: teamId },
    include: { league: { include: { memberships: true } } },
  });

  if (!team) {
    throw new Error('Team not found');
  }

  const membership = team.league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  await prisma.team.delete({
    where: { id: teamId },
  });

  await prisma.auditLog.create({
    data: {
      leagueId: team.leagueId,
      userId: user.id,
      action: 'DELETED_TEAM',
      metadata: { teamName: team.name },
    },
  });

  revalidatePath(`/leagues/${team.league.slug}/admin`);
  
  return { success: true };
}

// ============================================
// DRIVER ACTIONS
// ============================================

export async function createDriver(teamId: string, formData: FormData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const team = await prisma.team.findUnique({
    where: { id: teamId },
    include: { league: { include: { memberships: true } } },
  });

  if (!team) {
    throw new Error('Team not found');
  }

  const membership = team.league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  const rawData = {
    fullName: formData.get('fullName'),
    shortName: formData.get('shortName'),
    number: formData.get('number') ? parseInt(formData.get('number') as string) : undefined,
    gamertag: formData.get('gamertag'),
    nationality: formData.get('nationality'),
    avatar: formData.get('avatar'),
    isReserve: formData.get('isReserve') === 'true',
  };

  const validatedData = DriverCreateSchema.parse(rawData);

  const driver = await prisma.driver.create({
    data: {
      ...validatedData,
      teamId,
    },
  });

  await prisma.auditLog.create({
    data: {
      leagueId: team.leagueId,
      userId: user.id,
      action: 'CREATED_DRIVER',
      metadata: { driverName: driver.fullName, team: team.name },
    },
  });

  revalidatePath(`/leagues/${team.league.slug}/admin`);
  
  return { success: true, driverId: driver.id };
}

export async function updateDriver(driverId: string, formData: FormData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const driver = await prisma.driver.findUnique({
    where: { id: driverId },
    include: { team: { include: { league: { include: { memberships: true } } } } },
  });

  if (!driver) {
    throw new Error('Driver not found');
  }

  const league = driver.team.league;
  const membership = league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  const rawData = {
    fullName: formData.get('fullName') || undefined,
    shortName: formData.get('shortName') || undefined,
    number: formData.get('number') ? parseInt(formData.get('number') as string) : undefined,
    gamertag: formData.get('gamertag') || undefined,
    nationality: formData.get('nationality') || undefined,
    avatar: formData.get('avatar') || undefined,
    isReserve: formData.has('isReserve') ? formData.get('isReserve') === 'true' : undefined,
    isActive: formData.has('isActive') ? formData.get('isActive') === 'true' : undefined,
    teamId: formData.get('teamId') || undefined,
  };

  const validatedData = DriverUpdateSchema.parse(rawData);

  await prisma.driver.update({
    where: { id: driverId },
    data: validatedData,
  });

  await prisma.auditLog.create({
    data: {
      leagueId: league.id,
      userId: user.id,
      action: 'UPDATED_DRIVER',
      metadata: { driverId, changes: validatedData },
    },
  });

  revalidatePath(`/leagues/${league.slug}/admin`);
  
  return { success: true };
}

export async function deleteDriver(driverId: string) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const driver = await prisma.driver.findUnique({
    where: { id: driverId },
    include: { team: { include: { league: { include: { memberships: true } } } } },
  });

  if (!driver) {
    throw new Error('Driver not found');
  }

  const league = driver.team.league;
  const membership = league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  await prisma.driver.delete({
    where: { id: driverId },
  });

  await prisma.auditLog.create({
    data: {
      leagueId: league.id,
      userId: user.id,
      action: 'DELETED_DRIVER',
      metadata: { driverName: driver.fullName },
    },
  });

  revalidatePath(`/leagues/${league.slug}/admin`);
  
  return { success: true };
}

// ============================================
// ROUND ACTIONS
// ============================================

export async function createRound(leagueId: string, formData: FormData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const league = await prisma.league.findUnique({
    where: { id: leagueId },
    include: { memberships: true, rounds: { orderBy: { roundNumber: 'desc' }, take: 1 } },
  });

  if (!league) {
    throw new Error('League not found');
  }

  const membership = league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  const nextRoundNumber = (league.rounds[0]?.roundNumber || 0) + 1;

  const rawData = {
    roundNumber: formData.get('roundNumber') ? parseInt(formData.get('roundNumber') as string) : nextRoundNumber,
    name: formData.get('name'),
    trackId: formData.get('trackId'),
    scheduledAt: formData.get('scheduledAt'),
    hasQuali: formData.get('hasQuali') === 'true',
    hasSprint: formData.get('hasSprint') === 'true',
  };

  const validatedData = RoundCreateSchema.parse(rawData);

  const round = await prisma.round.create({
    data: {
      ...validatedData,
      scheduledAt: new Date(validatedData.scheduledAt),
      leagueId,
    },
  });

  await prisma.auditLog.create({
    data: {
      leagueId,
      userId: user.id,
      action: 'CREATED_ROUND',
      metadata: { roundNumber: round.roundNumber, name: round.name },
    },
  });

  revalidatePath(`/leagues/${league.slug}/admin`);
  
  return { success: true, roundId: round.id };
}

export async function updateRound(roundId: string, formData: FormData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const round = await prisma.round.findUnique({
    where: { id: roundId },
    include: { league: { include: { memberships: true } } },
  });

  if (!round) {
    throw new Error('Round not found');
  }

  const membership = round.league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  const rawData = {
    roundNumber: formData.get('roundNumber') ? parseInt(formData.get('roundNumber') as string) : undefined,
    name: formData.get('name') || undefined,
    trackId: formData.get('trackId') || undefined,
    scheduledAt: formData.get('scheduledAt') || undefined,
    status: formData.get('status') || undefined,
    hasQuali: formData.has('hasQuali') ? formData.get('hasQuali') === 'true' : undefined,
    hasSprint: formData.has('hasSprint') ? formData.get('hasSprint') === 'true' : undefined,
  };

  const validatedData = RoundUpdateSchema.parse(rawData);
  
  const updateData: Record<string, unknown> = { ...validatedData };
  if (validatedData.scheduledAt) {
    updateData.scheduledAt = new Date(validatedData.scheduledAt);
  }

  await prisma.round.update({
    where: { id: roundId },
    data: updateData,
  });

  await prisma.auditLog.create({
    data: {
      leagueId: round.leagueId,
      userId: user.id,
      action: 'UPDATED_ROUND',
      metadata: { roundId, changes: validatedData },
    },
  });

  revalidatePath(`/leagues/${round.league.slug}/admin`);
  
  return { success: true };
}

export async function deleteRound(roundId: string) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const round = await prisma.round.findUnique({
    where: { id: roundId },
    include: { league: { include: { memberships: true } } },
  });

  if (!round) {
    throw new Error('Round not found');
  }

  const membership = round.league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  await prisma.round.delete({
    where: { id: roundId },
  });

  await prisma.auditLog.create({
    data: {
      leagueId: round.leagueId,
      userId: user.id,
      action: 'DELETED_ROUND',
      metadata: { roundNumber: round.roundNumber },
    },
  });

  revalidatePath(`/leagues/${round.league.slug}/admin`);
  
  return { success: true };
}

// ============================================
// RESULT ACTIONS
// ============================================

export async function createResult(roundId: string, formData: FormData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const round = await prisma.round.findUnique({
    where: { id: roundId },
    include: { league: { include: { memberships: true,  } } },
  });

  if (!round) {
    throw new Error('Round not found');
  }

  const membership = round.league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  const rawData = {
    driverId: formData.get('driverId'),
    session: formData.get('session'),
    position: parseInt(formData.get('position') as string),
    fastestLap: formData.get('fastestLap') === 'true',
    dnf: formData.get('dnf') === 'true',
    dsq: formData.get('dsq') === 'true',
    gap: formData.get('gap'),
    notes: formData.get('notes'),
  };

  const validatedData = ResultCreateSchema.parse(rawData);

  // Calculate points based on scoring configuration
  let points = 0;
  const scoringConfig = round.league.scoringConfig as {
    racePoints?: number[];
    sprintPoints?: number[];
    fastestLap?: number;
    poleBonus?: number;
  } | null;
  
  const position = validatedData.position;
  if (scoringConfig && position && position > 0 && validatedData.status !== 'DSQ') {
    if (validatedData.sessionType === 'RACE') {
      const racePoints = scoringConfig.racePoints || [];
      if (position <= racePoints.length) {
        points = racePoints[position - 1];
      }
      if (validatedData.fastestLap && position <= 10) {
        points += scoringConfig.fastestLap || 0;
      }
    } else if (validatedData.sessionType === 'SPRINT') {
      const sprintPoints = scoringConfig.sprintPoints || [];
      if (position <= sprintPoints.length) {
        points = sprintPoints[position - 1];
      }
    } else if (validatedData.sessionType === 'QUALIFYING') {
      if (position === 1) {
        points = scoringConfig.poleBonus || 0;
      }
    }
  }

  const result = await prisma.result.create({
    data: {
      ...validatedData,
      roundId,
      points,
    },
  });

  await prisma.auditLog.create({
    data: {
      leagueId: round.leagueId,
      userId: user.id,
      action: 'CREATED_RESULT',
      metadata: { 
        roundNumber: round.roundNumber, 
        session: validatedData.sessionType,
        position: validatedData.position,
      },
    },
  });

  revalidatePath(`/leagues/${round.league.slug}/admin`);
  revalidatePath(`/leagues/${round.league.slug}/results/${round.roundNumber}`);
  
  return { success: true, resultId: result.id };
}

export async function createBulkResults(roundId: string, results: Array<{
  driverId: string;
  teamId: string;
  sessionType: string;
  position: number;
  fastestLap?: boolean;
  status?: string;
  gapToLeader?: string;
}>) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const round = await prisma.round.findUnique({
    where: { id: roundId },
    include: { league: { include: { memberships: true,  } } },
  });

  if (!round) {
    throw new Error('Round not found');
  }

  const membership = round.league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  const scoring = await prisma.scoring.findUnique({
    where: { leagueId: round.leagueId },
  });
  
  const resultsWithPoints = results.map(result => {
    let points = 0;
    const resultStatus = result.status || 'FINISHED';
    
    if (scoring && result.position > 0 && resultStatus !== 'DSQ') {
      if (result.sessionType === 'RACE') {
        const racePoints = scoring.racePoints as Record<string, number>;
        if (racePoints[result.position.toString()]) {
          points = racePoints[result.position.toString()];
        }
        if (result.fastestLap && result.position <= scoring.fastestLapEligibleTop) {
          points += scoring.fastestLapPoints;
        }
      } else if (result.sessionType === 'SPRINT') {
        const sprintPoints = scoring.sprintPoints as Record<string, number>;
        if (sprintPoints[result.position.toString()]) {
          points = sprintPoints[result.position.toString()];
        }
      } else if (result.sessionType === 'QUALIFYING') {
        if (result.position === 1 && scoring.polePositionPoints) {
          points = scoring.polePositionPoints;
        }
      }
    }

    return {
      driverId: result.driverId,
      teamId: result.teamId,
      sessionType: result.sessionType as 'QUALIFYING' | 'SPRINT' | 'RACE',
      position: result.position,
      fastestLap: result.fastestLap || false,
      status: resultStatus as 'FINISHED' | 'DNF' | 'DNS' | 'DSQ',
      gapToLeader: result.gapToLeader,
      roundId,
      points,
    };
  });

  await prisma.result.createMany({
    data: resultsWithPoints,
  });

  // Mark round as completed
  await prisma.round.update({
    where: { id: roundId },
    data: { status: 'COMPLETED' },
  });

  await prisma.auditLog.create({
    data: {
      leagueId: round.leagueId,
      userId: user.id,
      action: 'CREATED_BULK_RESULTS',
      metadata: { 
        roundNumber: round.roundNumber, 
        resultCount: results.length,
      },
    },
  });

  revalidatePath(`/leagues/${round.league.slug}/admin`);
  revalidatePath(`/leagues/${round.league.slug}/results/${round.roundNumber}`);
  revalidatePath(`/leagues/${round.league.slug}/standings`);
  
  return { success: true };
}

// ============================================
// SCORING ACTIONS
// ============================================

export async function createOrUpdateScoring(leagueId: string, formData: FormData) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const league = await prisma.league.findUnique({
    where: { id: leagueId },
    include: { memberships: true,  },
  });

  if (!league) {
    throw new Error('League not found');
  }

  const membership = league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  const rawData = {
    racePoints: JSON.parse(formData.get('racePoints') as string || '[25, 18, 15, 12, 10, 8, 6, 4, 2, 1]'),
    sprintPoints: JSON.parse(formData.get('sprintPoints') as string || '[8, 7, 6, 5, 4, 3, 2, 1]'),
    qualifyingPoints: JSON.parse(formData.get('qualifyingPoints') as string || '[]'),
    fastestLap: parseInt(formData.get('fastestLap') as string || '1'),
    poleBonus: parseInt(formData.get('poleBonus') as string || '0'),
    dnfPenalty: parseInt(formData.get('dnfPenalty') as string || '0'),
  };

  const validatedData = ScoringConfigSchema.parse(rawData);

  const existingScoring = await prisma.scoring.findUnique({
    where: { leagueId },
  });

  if (existingScoring) {
    await prisma.scoring.update({
      where: { leagueId },
      data: validatedData,
    });
  } else {
    await prisma.scoring.create({
      data: {
        ...validatedData,
        leagueId,
      },
    });
  }

  await prisma.auditLog.create({
    data: {
      leagueId,
      userId: user.id,
      action: 'UPDATED_SCORING',
      metadata: validatedData,
    },
  });

  revalidatePath(`/leagues/${league.slug}/admin`);
  
  return { success: true };
}

// ============================================
// MEMBERSHIP ACTIONS
// ============================================

export async function joinLeague(leagueId: string) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const league = await prisma.league.findUnique({
    where: { id: leagueId },
    include: { memberships: true },
  });

  if (!league) {
    throw new Error('League not found');
  }

  if (league.visibility !== 'PUBLIC') {
    throw new Error('This league is private');
  }

  const existingMembership = league.memberships.find(m => m.userId === user.id);
  if (existingMembership) {
    throw new Error('Already a member');
  }

  await prisma.membership.create({
    data: {
      userId: user.id,
      leagueId,
      role: 'MEMBER',
    },
  });

  await prisma.auditLog.create({
    data: {
      leagueId,
      userId: user.id,
      action: 'JOINED_LEAGUE',
      metadata: {},
    },
  });

  revalidatePath(`/leagues/${league.slug}`);
  
  return { success: true };
}

export async function leaveLeague(leagueId: string) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const league = await prisma.league.findUnique({
    where: { id: leagueId },
    include: { memberships: true },
  });

  if (!league) {
    throw new Error('League not found');
  }

  const membership = league.memberships.find(m => m.userId === user.id);
  if (!membership) {
    throw new Error('Not a member');
  }

  if (membership.role === 'OWNER') {
    throw new Error('Owner cannot leave the league');
  }

  await prisma.membership.delete({
    where: { id: membership.id },
  });

  await prisma.auditLog.create({
    data: {
      leagueId,
      userId: user.id,
      action: 'LEFT_LEAGUE',
      metadata: {},
    },
  });

  revalidatePath(`/leagues/${league.slug}`);
  redirect('/leagues');
}

export async function updateMemberRole(membershipId: string, newRole: 'ADMIN' | 'MEMBER' | 'VIEWER') {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }

  const membership = await prisma.membership.findUnique({
    where: { id: membershipId },
    include: { league: { include: { memberships: true } } },
  });

  if (!membership) {
    throw new Error('Membership not found');
  }

  const userMembership = membership.league.memberships.find(m => m.userId === user.id);
  const isOwner = membership?.role === 'OWNER';
  const isAdmin = isOwner || userMembership?.role === 'OWNER' || userMembership?.role === 'ADMIN';

  if (!isAdmin) {
    throw new Error('Unauthorized');
  }

  if (membership.role === 'OWNER') {
    throw new Error('Cannot change owner role');
  }

  await prisma.membership.update({
    where: { id: membershipId },
    data: { role: newRole },
  });

  await prisma.auditLog.create({
    data: {
      leagueId: membership.leagueId,
      userId: user.id,
      action: 'UPDATED_MEMBER_ROLE',
      metadata: { memberId: membership.userId, newRole },
    },
  });

  revalidatePath(`/leagues/${membership.league.slug}/admin`);
  
  return { success: true };
}
