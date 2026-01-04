'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import prisma from '@/lib/db';
import { createClient } from '@/lib/supabase/server';
import { LeagueRole, ChampionshipRole, ChampionshipStatus, DriverStatus, RaceStatus, RaceLength, SprintLength, QualyType } from '@prisma/client';

// ============================================
// HELPER FUNCTIONS
// ============================================

async function getCurrentUser() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  return user;
}

async function getOrCreateDbUser(authUser: { id: string; email?: string }) {
  // Try to find existing user
  let dbUser = await prisma.user.findUnique({
    where: { supabaseAuthId: authUser.id },
  });

  if (!dbUser && authUser.email) {
    // Try to find by email
    dbUser = await prisma.user.findUnique({
      where: { email: authUser.email.toLowerCase() },
    });

    // Link Supabase auth if found
    if (dbUser) {
      dbUser = await prisma.user.update({
        where: { id: dbUser.id },
        data: { supabaseAuthId: authUser.id },
      });
    }
  }

  // Create new user if not found
  if (!dbUser && authUser.email) {
    dbUser = await prisma.user.create({
      data: {
        email: authUser.email.toLowerCase(),
        fullName: authUser.email.split('@')[0],
        supabaseAuthId: authUser.id,
      },
    });
  }

  return dbUser;
}

async function isLeagueAdmin(userId: string, leagueId: string): Promise<boolean> {
  const league = await prisma.league.findUnique({
    where: { id: leagueId },
  });

  if (league?.ownerId === userId) return true;

  const membership = await prisma.leagueMember.findUnique({
    where: {
      leagueId_userId: { leagueId, userId },
    },
  });

  return membership?.role === LeagueRole.OWNER || membership?.role === LeagueRole.ADMIN;
}

async function isChampionshipAdmin(userId: string, championshipId: string): Promise<boolean> {
  const championship = await prisma.championship.findUnique({
    where: { id: championshipId },
    include: { league: true },
  });

  if (!championship) return false;

  // Check if league admin
  if (await isLeagueAdmin(userId, championship.leagueId)) return true;

  // Check championship-level admin
  const membership = await prisma.championshipMember.findUnique({
    where: {
      championshipId_userId: { championshipId, userId },
    },
  });

  return membership?.role === ChampionshipRole.ADMIN;
}

// ============================================
// LEAGUE ACTIONS
// ============================================

export async function createLeague(formData: FormData) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not create user');

  const name = formData.get('name') as string;
  const slug = formData.get('slug') as string;
  const description = formData.get('description') as string | null;
  const timezone = (formData.get('timezone') as string) || 'America/Chicago';
  const isPublic = formData.get('visibility') !== 'PRIVATE';

  // Validate required fields
  if (!name || !slug) {
    throw new Error('Name and slug are required');
  }

  // Check slug availability
  const existingLeague = await prisma.league.findUnique({
    where: { slug },
  });

  if (existingLeague) {
    throw new Error('This slug is already taken');
  }

  // Create league with owner
  const league = await prisma.league.create({
    data: {
      name,
      slug,
      description,
      timezone,
      isPublic,
      ownerId: dbUser.id,
      members: {
        create: {
          userId: dbUser.id,
          role: LeagueRole.OWNER,
        },
      },
    },
  });

  // Log the action
  await prisma.auditLog.create({
    data: {
      leagueId: league.id,
      userId: dbUser.id,
      action: 'CREATED_LEAGUE',
      metadata: { leagueName: league.name },
    },
  });

  revalidatePath('/leagues');
  revalidatePath('/dashboard');
  redirect(`/leagues/${league.slug}`);
}

export async function updateLeague(leagueId: string, formData: FormData) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const isAdmin = await isLeagueAdmin(dbUser.id, leagueId);
  if (!isAdmin) throw new Error('Unauthorized');

  const league = await prisma.league.findUnique({
    where: { id: leagueId },
  });

  if (!league) throw new Error('League not found');

  const updateData: Record<string, unknown> = {};

  const name = formData.get('name');
  if (name) updateData.name = name;

  const description = formData.get('description');
  if (description !== null) updateData.description = description;

  const timezone = formData.get('timezone');
  if (timezone) updateData.timezone = timezone;

  const isPublic = formData.get('visibility');
  if (isPublic !== null) updateData.isPublic = isPublic !== 'PRIVATE';

  const instagram = formData.get('instagram');
  if (instagram !== null) updateData.instagram = instagram || null;

  const youtube = formData.get('youtube');
  if (youtube !== null) updateData.youtube = youtube || null;

  const twitch = formData.get('twitch');
  if (twitch !== null) updateData.twitch = twitch || null;

  const twitter = formData.get('twitter');
  if (twitter !== null) updateData.twitter = twitter || null;

  const discord = formData.get('discord');
  if (discord !== null) updateData.discord = discord || null;

  const rules = formData.get('rules');
  if (rules !== null) updateData.rules = rules || null;

  const updatedLeague = await prisma.league.update({
    where: { id: leagueId },
    data: updateData,
  });

  await prisma.auditLog.create({
    data: {
      leagueId: league.id,
      userId: dbUser.id,
      action: 'UPDATED_LEAGUE',
      metadata: { changes: updateData },
    },
  });

  revalidatePath(`/leagues/${updatedLeague.slug}`);
  revalidatePath(`/leagues/${updatedLeague.slug}/admin`);

  return { success: true };
}

export async function deleteLeague(leagueId: string) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const league = await prisma.league.findUnique({
    where: { id: leagueId },
  });

  if (!league) throw new Error('League not found');
  if (league.ownerId !== dbUser.id) throw new Error('Only the owner can delete a league');

  await prisma.league.delete({
    where: { id: leagueId },
  });

  revalidatePath('/leagues');
  revalidatePath('/dashboard');
  redirect('/dashboard');
}

// ============================================
// CHAMPIONSHIP ACTIONS
// ============================================

export async function createChampionship(leagueId: string, formData: FormData) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const isAdmin = await isLeagueAdmin(dbUser.id, leagueId);
  if (!isAdmin) throw new Error('Unauthorized');

  const name = formData.get('name') as string;
  const description = formData.get('description') as string | null;
  const carPerformance = formData.get('carPerformance') === 'EQUAL' ? 'EQUAL' : 'REAL';
  const useF1Scoring = formData.get('scoringSystem') !== 'CUSTOM';

  if (!name) throw new Error('Championship name is required');

  const league = await prisma.league.findUnique({
    where: { id: leagueId },
  });

  if (!league) throw new Error('League not found');

  // Create championship with default config
  const championship = await prisma.championship.create({
    data: {
      leagueId,
      name,
      description,
      createdById: dbUser.id,
      carPerformance: carPerformance as 'REAL' | 'EQUAL',
      useF1Scoring,
      status: ChampionshipStatus.DRAFT,
      // Create default assists
      assists: {
        create: {},
      },
      // Create default scoring
      scoring: {
        create: {
          useF1Default: useF1Scoring,
        },
      },
    },
  });

  // Add creator as championship admin
  await prisma.championshipMember.create({
    data: {
      championshipId: championship.id,
      userId: dbUser.id,
      role: ChampionshipRole.ADMIN,
    },
  });

  await prisma.auditLog.create({
    data: {
      leagueId,
      userId: dbUser.id,
      action: 'CREATED_CHAMPIONSHIP',
      metadata: { championshipName: championship.name },
    },
  });

  revalidatePath(`/leagues/${league.slug}`);
  revalidatePath(`/leagues/${league.slug}/admin`);

  return { success: true, championshipId: championship.id };
}

export async function updateChampionship(championshipId: string, formData: FormData) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const isAdmin = await isChampionshipAdmin(dbUser.id, championshipId);
  if (!isAdmin) throw new Error('Unauthorized');

  const championship = await prisma.championship.findUnique({
    where: { id: championshipId },
    include: { league: true },
  });

  if (!championship) throw new Error('Championship not found');

  const updateData: Record<string, unknown> = {};

  const name = formData.get('name');
  if (name) updateData.name = name;

  const description = formData.get('description');
  if (description !== null) updateData.description = description;

  const status = formData.get('status');
  if (status) updateData.status = status;

  await prisma.championship.update({
    where: { id: championshipId },
    data: updateData,
  });

  revalidatePath(`/leagues/${championship.league.slug}`);

  return { success: true };
}

// ============================================
// TEAM ACTIONS (Championship Teams)
// ============================================

export async function createChampionshipTeam(championshipId: string, formData: FormData) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const isAdmin = await isChampionshipAdmin(dbUser.id, championshipId);
  if (!isAdmin) throw new Error('Unauthorized');

  const name = formData.get('name') as string;
  const shortName = formData.get('shortName') as string | null;
  const primaryColor = formData.get('primaryColor') as string | null;
  const secondaryColor = formData.get('secondaryColor') as string | null;
  const country = formData.get('country') as string | null;

  if (!name) throw new Error('Team name is required');

  const championship = await prisma.championship.findUnique({
    where: { id: championshipId },
    include: { league: true },
  });

  if (!championship) throw new Error('Championship not found');

  const team = await prisma.championshipTeam.create({
    data: {
      championshipId,
      name,
      shortName,
      primaryColor,
      secondaryColor,
      country,
    },
  });

  revalidatePath(`/leagues/${championship.league.slug}`);

  return { success: true, teamId: team.id };
}

export async function updateChampionshipTeam(teamId: string, formData: FormData) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const team = await prisma.championshipTeam.findUnique({
    where: { id: teamId },
    include: { championship: { include: { league: true } } },
  });

  if (!team) throw new Error('Team not found');

  const isAdmin = await isChampionshipAdmin(dbUser.id, team.championshipId);
  if (!isAdmin) throw new Error('Unauthorized');

  const updateData: Record<string, unknown> = {};

  const name = formData.get('name');
  if (name) updateData.name = name;

  const shortName = formData.get('shortName');
  if (shortName !== null) updateData.shortName = shortName || null;

  const primaryColor = formData.get('primaryColor');
  if (primaryColor !== null) updateData.primaryColor = primaryColor || null;

  const secondaryColor = formData.get('secondaryColor');
  if (secondaryColor !== null) updateData.secondaryColor = secondaryColor || null;

  await prisma.championshipTeam.update({
    where: { id: teamId },
    data: updateData,
  });

  revalidatePath(`/leagues/${team.championship.league.slug}`);

  return { success: true };
}

export async function deleteChampionshipTeam(teamId: string) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const team = await prisma.championshipTeam.findUnique({
    where: { id: teamId },
    include: { championship: { include: { league: true } } },
  });

  if (!team) throw new Error('Team not found');

  const isAdmin = await isChampionshipAdmin(dbUser.id, team.championshipId);
  if (!isAdmin) throw new Error('Unauthorized');

  await prisma.championshipTeam.delete({
    where: { id: teamId },
  });

  revalidatePath(`/leagues/${team.championship.league.slug}`);

  return { success: true };
}

// ============================================
// DRIVER ACTIONS (Championship Drivers)
// ============================================

export async function createChampionshipDriver(championshipId: string, formData: FormData) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const isAdmin = await isChampionshipAdmin(dbUser.id, championshipId);
  if (!isAdmin) throw new Error('Unauthorized');

  const fullName = formData.get('fullName') as string;
  const shortName = formData.get('shortName') as string | null;
  const gamertag = formData.get('gamertag') as string;
  const number = formData.get('number') ? parseInt(formData.get('number') as string) : null;
  const country = formData.get('country') as string | null;
  const teamId = formData.get('teamId') as string | null;

  if (!fullName || !gamertag) {
    throw new Error('Full name and gamertag are required');
  }

  const championship = await prisma.championship.findUnique({
    where: { id: championshipId },
    include: { league: true },
  });

  if (!championship) throw new Error('Championship not found');

  // Determine status based on team assignment
  const status = teamId ? DriverStatus.ACTIVE : DriverStatus.RESERVE;

  const driver = await prisma.championshipDriver.create({
    data: {
      championshipId,
      teamId: teamId || null,
      fullName,
      shortName,
      gamertag,
      number,
      country,
      status,
    },
  });

  revalidatePath(`/leagues/${championship.league.slug}`);

  return { success: true, driverId: driver.id };
}

export async function updateChampionshipDriver(driverId: string, formData: FormData) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const driver = await prisma.championshipDriver.findUnique({
    where: { id: driverId },
  });

  if (!driver) throw new Error('Driver not found');

  const championship = await prisma.championship.findUnique({
    where: { id: driver.championshipId },
    include: { league: true },
  });

  if (!championship) throw new Error('Championship not found');

  const isAdmin = await isChampionshipAdmin(dbUser.id, championship.id);
  if (!isAdmin) throw new Error('Unauthorized');

  const updateData: Record<string, unknown> = {};

  const fullName = formData.get('fullName');
  if (fullName) updateData.fullName = fullName;

  const shortName = formData.get('shortName');
  if (shortName !== null) updateData.shortName = shortName || null;

  const gamertag = formData.get('gamertag');
  if (gamertag) updateData.gamertag = gamertag;

  const number = formData.get('number');
  if (number !== null) updateData.number = number ? parseInt(number as string) : null;

  const teamId = formData.get('teamId');
  if (teamId !== null) {
    updateData.teamId = teamId || null;
    updateData.status = teamId ? DriverStatus.ACTIVE : DriverStatus.RESERVE;
  }

  await prisma.championshipDriver.update({
    where: { id: driverId },
    data: updateData,
  });

  revalidatePath(`/leagues/${championship.league.slug}`);

  return { success: true };
}

export async function assignDriverToTeam(driverId: string, teamId: string | null) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const driver = await prisma.championshipDriver.findUnique({
    where: { id: driverId },
  });

  if (!driver) throw new Error('Driver not found');

  const isAdmin = await isChampionshipAdmin(dbUser.id, driver.championshipId);
  if (!isAdmin) throw new Error('Unauthorized');

  // If assigning to a team, check team capacity (max 2 drivers)
  if (teamId) {
    const teamDriverCount = await prisma.championshipDriver.count({
      where: {
        teamId,
        status: DriverStatus.ACTIVE,
        id: { not: driverId }, // Exclude current driver
      },
    });

    if (teamDriverCount >= 2) {
      throw new Error('Team already has 2 active drivers');
    }
  }

  await prisma.championshipDriver.update({
    where: { id: driverId },
    data: {
      teamId: teamId || null,
      status: teamId ? DriverStatus.ACTIVE : DriverStatus.RESERVE,
    },
  });

  const championship = await prisma.championship.findUnique({
    where: { id: driver.championshipId },
    include: { league: true },
  });

  if (championship) {
    revalidatePath(`/leagues/${championship.league.slug}`);
  }

  return { success: true };
}

// ============================================
// RACE ACTIONS
// ============================================

export async function createRace(championshipId: string, trackId: string, formData: FormData) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const isAdmin = await isChampionshipAdmin(dbUser.id, championshipId);
  if (!isAdmin) throw new Error('Unauthorized');

  const championship = await prisma.championship.findUnique({
    where: { id: championshipId },
    include: { league: true },
  });

  if (!championship) throw new Error('Championship not found');

  // Get next round number
  const lastRace = await prisma.race.findFirst({
    where: { championshipId },
    orderBy: { roundNumber: 'desc' },
  });
  const roundNumber = (lastRace?.roundNumber || 0) + 1;

  const name = formData.get('name') as string | null;
  const scheduledDate = formData.get('scheduledDate') as string | null;
  const scheduledTime = formData.get('scheduledTime') as string | null;
  const raceLength = (formData.get('raceLength') as RaceLength) || RaceLength.MEDIUM_50;
  const sprintLength = (formData.get('sprintLength') as SprintLength) || SprintLength.NONE;
  const qualyType = (formData.get('qualyType') as QualyType) || QualyType.FULL;

  // Create championship track if not exists
  const championshipTrack = await prisma.championshipTrack.upsert({
    where: {
      championshipId_trackId: { championshipId, trackId },
    },
    update: { roundNumber },
    create: {
      championshipId,
      trackId,
      roundNumber,
    },
  });

  // Create the race
  const race = await prisma.race.create({
    data: {
      championshipId,
      championshipTrackId: championshipTrack.id,
      trackId,
      roundNumber,
      name,
      scheduledDate: scheduledDate ? new Date(scheduledDate) : null,
      scheduledTime,
      raceLength,
      sprintLength,
      qualyType,
      status: RaceStatus.SCHEDULED,
    },
  });

  revalidatePath(`/leagues/${championship.league.slug}`);

  return { success: true, raceId: race.id };
}

export async function updateRace(raceId: string, formData: FormData) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const race = await prisma.race.findUnique({
    where: { id: raceId },
    include: { championship: { include: { league: true } } },
  });

  if (!race) throw new Error('Race not found');

  const isAdmin = await isChampionshipAdmin(dbUser.id, race.championshipId);
  if (!isAdmin) throw new Error('Unauthorized');

  const updateData: Record<string, unknown> = {};

  const name = formData.get('name');
  if (name !== null) updateData.name = name || null;

  const scheduledDate = formData.get('scheduledDate');
  if (scheduledDate !== null) {
    updateData.scheduledDate = scheduledDate ? new Date(scheduledDate as string) : null;
  }

  const scheduledTime = formData.get('scheduledTime');
  if (scheduledTime !== null) updateData.scheduledTime = scheduledTime || null;

  const raceLength = formData.get('raceLength');
  if (raceLength) updateData.raceLength = raceLength;

  const sprintLength = formData.get('sprintLength');
  if (sprintLength) updateData.sprintLength = sprintLength;

  const qualyType = formData.get('qualyType');
  if (qualyType) updateData.qualyType = qualyType;

  const status = formData.get('status');
  if (status) updateData.status = status;

  await prisma.race.update({
    where: { id: raceId },
    data: updateData,
  });

  revalidatePath(`/leagues/${race.championship.league.slug}`);

  return { success: true };
}

export async function deleteRace(raceId: string) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const race = await prisma.race.findUnique({
    where: { id: raceId },
    include: { championship: { include: { league: true } } },
  });

  if (!race) throw new Error('Race not found');

  const isAdmin = await isChampionshipAdmin(dbUser.id, race.championshipId);
  if (!isAdmin) throw new Error('Unauthorized');

  await prisma.race.delete({
    where: { id: raceId },
  });

  revalidatePath(`/leagues/${race.championship.league.slug}`);

  return { success: true };
}

// ============================================
// RACE RESULTS ACTIONS
// ============================================

export async function submitRaceResults(
  raceId: string,
  results: Array<{
    driverId: string;
    teamId: string;
    position: number | null;
    status: 'FINISHED' | 'DNF' | 'DNS' | 'DSQ';
    fastestLap?: boolean;
    driverOfTheDay?: boolean;
  }>
) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const race = await prisma.race.findUnique({
    where: { id: raceId },
    include: {
      championship: {
        include: {
          league: true,
          scoring: true,
        },
      },
    },
  });

  if (!race) throw new Error('Race not found');

  const isAdmin = await isChampionshipAdmin(dbUser.id, race.championshipId);
  if (!isAdmin) throw new Error('Unauthorized');

  const scoring = race.championship.scoring;
  if (!scoring) throw new Error('Scoring system not configured');

  // Calculate points for each result
  const racePoints: Record<number, number> = {
    1: scoring.raceP1,
    2: scoring.raceP2,
    3: scoring.raceP3,
    4: scoring.raceP4,
    5: scoring.raceP5,
    6: scoring.raceP6,
    7: scoring.raceP7,
    8: scoring.raceP8,
    9: scoring.raceP9,
    10: scoring.raceP10,
    11: scoring.raceP11,
    12: scoring.raceP12,
    13: scoring.raceP13,
    14: scoring.raceP14,
    15: scoring.raceP15,
    16: scoring.raceP16,
    17: scoring.raceP17,
    18: scoring.raceP18,
    19: scoring.raceP19,
    20: scoring.raceP20,
  };

  // Delete existing results for this race
  await prisma.raceResult.deleteMany({
    where: { raceId },
  });

  // Create new results
  for (const result of results) {
    let points = 0;

    if (result.status === 'FINISHED' && result.position) {
      points = racePoints[result.position] || 0;

      // Fastest lap bonus (only if in top N)
      if (result.fastestLap && result.position <= scoring.fastestLapTopN) {
        points += scoring.fastestLap;
      }

      // Finish bonus
      points += scoring.finishRace;

      // Driver of the day
      if (result.driverOfTheDay) {
        points += scoring.driverOfTheDay;
      }
    }

    await prisma.raceResult.create({
      data: {
        championshipId: race.championshipId,
        raceId,
        driverId: result.driverId,
        teamId: result.teamId,
        position: result.position,
        status: result.status,
        points,
        fastestLap: result.fastestLap || false,
        driverOfTheDay: result.driverOfTheDay || false,
        finishedRace: result.status === 'FINISHED',
      },
    });
  }

  // Update race status
  await prisma.race.update({
    where: { id: raceId },
    data: {
      status: RaceStatus.COMPLETED,
      completedAt: new Date(),
    },
  });

  revalidatePath(`/leagues/${race.championship.league.slug}`);

  return { success: true };
}

// ============================================
// ASSISTS CONFIGURATION
// ============================================

export async function updateChampionshipAssists(championshipId: string, formData: FormData) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const isAdmin = await isChampionshipAdmin(dbUser.id, championshipId);
  if (!isAdmin) throw new Error('Unauthorized');

  const championship = await prisma.championship.findUnique({
    where: { id: championshipId },
    include: { league: true },
  });

  if (!championship) throw new Error('Championship not found');

  await prisma.championshipAssists.upsert({
    where: { championshipId },
    update: {
      steeringAssist: formData.get('steeringAssist') as 'ON' | 'OFF' || 'OFF',
      brakingAssist: formData.get('brakingAssist') as 'ON' | 'OFF' || 'OFF',
      antiLockBrakes: formData.get('antiLockBrakes') as 'ON' | 'OFF' || 'OFF',
      tractionControl: formData.get('tractionControl') as 'FULL' | 'MEDIUM' | 'OFF' || 'OFF',
      racingLine: formData.get('racingLine') as 'FULL' | 'CORNERS' | 'OFF' || 'OFF',
      gearbox: formData.get('gearbox') as 'AUTOMATIC' | 'MANUAL' || 'MANUAL',
      pitAssist: formData.get('pitAssist') as 'ON' | 'OFF' || 'OFF',
      pitReleaseAssist: formData.get('pitReleaseAssist') as 'ON' | 'OFF' || 'OFF',
      ersAssist: formData.get('ersAssist') as 'ON' | 'OFF' || 'OFF',
      drsAssist: formData.get('drsAssist') as 'ON' | 'OFF' || 'OFF',
    },
    create: {
      championshipId,
      steeringAssist: formData.get('steeringAssist') as 'ON' | 'OFF' || 'OFF',
      brakingAssist: formData.get('brakingAssist') as 'ON' | 'OFF' || 'OFF',
      antiLockBrakes: formData.get('antiLockBrakes') as 'ON' | 'OFF' || 'OFF',
      tractionControl: formData.get('tractionControl') as 'FULL' | 'MEDIUM' | 'OFF' || 'OFF',
      racingLine: formData.get('racingLine') as 'FULL' | 'CORNERS' | 'OFF' || 'OFF',
      gearbox: formData.get('gearbox') as 'AUTOMATIC' | 'MANUAL' || 'MANUAL',
      pitAssist: formData.get('pitAssist') as 'ON' | 'OFF' || 'OFF',
      pitReleaseAssist: formData.get('pitReleaseAssist') as 'ON' | 'OFF' || 'OFF',
      ersAssist: formData.get('ersAssist') as 'ON' | 'OFF' || 'OFF',
      drsAssist: formData.get('drsAssist') as 'ON' | 'OFF' || 'OFF',
    },
  });

  revalidatePath(`/leagues/${championship.league.slug}`);

  return { success: true };
}

// ============================================
// SCORING CONFIGURATION
// ============================================

export async function updateScoringSystem(championshipId: string, formData: FormData) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const isAdmin = await isChampionshipAdmin(dbUser.id, championshipId);
  if (!isAdmin) throw new Error('Unauthorized');

  const championship = await prisma.championship.findUnique({
    where: { id: championshipId },
    include: { league: true },
  });

  if (!championship) throw new Error('Championship not found');

  const getInt = (key: string, defaultVal: number) => {
    const val = formData.get(key);
    return val ? parseInt(val as string) : defaultVal;
  };

  await prisma.scoringSystem.upsert({
    where: { championshipId },
    update: {
      useF1Default: formData.get('useF1Default') === 'true',
      // Race points
      raceP1: getInt('raceP1', 25),
      raceP2: getInt('raceP2', 18),
      raceP3: getInt('raceP3', 15),
      raceP4: getInt('raceP4', 12),
      raceP5: getInt('raceP5', 10),
      raceP6: getInt('raceP6', 8),
      raceP7: getInt('raceP7', 6),
      raceP8: getInt('raceP8', 4),
      raceP9: getInt('raceP9', 2),
      raceP10: getInt('raceP10', 1),
      // Sprint points
      sprintP1: getInt('sprintP1', 8),
      sprintP2: getInt('sprintP2', 7),
      sprintP3: getInt('sprintP3', 6),
      sprintP4: getInt('sprintP4', 5),
      sprintP5: getInt('sprintP5', 4),
      sprintP6: getInt('sprintP6', 3),
      sprintP7: getInt('sprintP7', 2),
      sprintP8: getInt('sprintP8', 1),
      // Bonus
      fastestLap: getInt('fastestLap', 1),
      fastestLapTopN: getInt('fastestLapTopN', 10),
      finishRace: getInt('finishRace', 0),
      noPenalty: getInt('noPenalty', 0),
      driverOfTheDay: getInt('driverOfTheDay', 0),
      polePosition: getInt('polePosition', 0),
    },
    create: {
      championshipId,
      useF1Default: formData.get('useF1Default') === 'true',
      raceP1: getInt('raceP1', 25),
      raceP2: getInt('raceP2', 18),
      raceP3: getInt('raceP3', 15),
      raceP4: getInt('raceP4', 12),
      raceP5: getInt('raceP5', 10),
      raceP6: getInt('raceP6', 8),
      raceP7: getInt('raceP7', 6),
      raceP8: getInt('raceP8', 4),
      raceP9: getInt('raceP9', 2),
      raceP10: getInt('raceP10', 1),
      sprintP1: getInt('sprintP1', 8),
      sprintP2: getInt('sprintP2', 7),
      sprintP3: getInt('sprintP3', 6),
      sprintP4: getInt('sprintP4', 5),
      sprintP5: getInt('sprintP5', 4),
      sprintP6: getInt('sprintP6', 3),
      sprintP7: getInt('sprintP7', 2),
      sprintP8: getInt('sprintP8', 1),
      fastestLap: getInt('fastestLap', 1),
      fastestLapTopN: getInt('fastestLapTopN', 10),
      finishRace: getInt('finishRace', 0),
      noPenalty: getInt('noPenalty', 0),
      driverOfTheDay: getInt('driverOfTheDay', 0),
      polePosition: getInt('polePosition', 0),
    },
  });

  revalidatePath(`/leagues/${championship.league.slug}`);

  return { success: true };
}

// ============================================
// LEAGUE MEMBERSHIP ACTIONS
// ============================================

export async function addLeagueAdmin(leagueId: string, userEmail: string) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const league = await prisma.league.findUnique({
    where: { id: leagueId },
  });

  if (!league) throw new Error('League not found');
  if (league.ownerId !== dbUser.id) throw new Error('Only the owner can add admins');

  // Find user by email
  const userToAdd = await prisma.user.findUnique({
    where: { email: userEmail.toLowerCase() },
  });

  if (!userToAdd) throw new Error('User not found');

  // Check current admin count
  const adminCount = await prisma.leagueMember.count({
    where: {
      leagueId,
      role: LeagueRole.ADMIN,
    },
  });

  if (adminCount >= 2) {
    throw new Error('Maximum 2 admins allowed per league');
  }

  await prisma.leagueMember.upsert({
    where: {
      leagueId_userId: { leagueId, userId: userToAdd.id },
    },
    update: { role: LeagueRole.ADMIN },
    create: {
      leagueId,
      userId: userToAdd.id,
      role: LeagueRole.ADMIN,
    },
  });

  revalidatePath(`/leagues/${league.slug}/admin`);

  return { success: true };
}

export async function removeLeagueAdmin(leagueId: string, userId: string) {
  const authUser = await getCurrentUser();
  if (!authUser) throw new Error('Unauthorized');

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) throw new Error('Could not find user');

  const league = await prisma.league.findUnique({
    where: { id: leagueId },
  });

  if (!league) throw new Error('League not found');
  if (league.ownerId !== dbUser.id) throw new Error('Only the owner can remove admins');
  if (league.ownerId === userId) throw new Error('Cannot remove the owner');

  await prisma.leagueMember.delete({
    where: {
      leagueId_userId: { leagueId, userId },
    },
  });

  revalidatePath(`/leagues/${league.slug}/admin`);

  return { success: true };
}

// ============================================
// UTILITY ACTIONS
// ============================================

export async function getLeagueBySlug(slug: string) {
  const league = await prisma.league.findUnique({
    where: { slug },
    include: {
      owner: {
        select: { id: true, fullName: true, email: true, avatar: true },
      },
      members: {
        include: {
          user: {
            select: { id: true, fullName: true, email: true, avatar: true },
          },
        },
      },
      championships: {
        orderBy: { createdAt: 'desc' },
        include: {
          teams: {
            include: {
              drivers: true,
            },
          },
          races: {
            orderBy: { roundNumber: 'asc' },
            include: {
              track: true,
            },
          },
        },
      },
    },
  });

  return league;
}

export async function getUserLeagues() {
  const authUser = await getCurrentUser();
  if (!authUser) return [];

  const dbUser = await getOrCreateDbUser(authUser);
  if (!dbUser) return [];

  // Get leagues where user is owner
  const ownedLeagues = await prisma.league.findMany({
    where: { ownerId: dbUser.id },
    include: {
      _count: {
        select: { championships: true, members: true },
      },
    },
  });

  // Get leagues where user is a member
  const memberships = await prisma.leagueMember.findMany({
    where: { userId: dbUser.id },
    include: {
      league: {
        include: {
          _count: {
            select: { championships: true, members: true },
          },
        },
      },
    },
  });

  // Combine and deduplicate
  const memberLeagues = memberships.map(m => m.league);
  const allLeagues = [...ownedLeagues, ...memberLeagues];
  const uniqueLeagues = allLeagues.filter((league, index, self) =>
    index === self.findIndex(l => l.id === league.id)
  );

  return uniqueLeagues;
}

export async function getTracks() {
  const tracks = await prisma.track.findMany({
    where: { isActive: true },
    orderBy: { name: 'asc' },
  });

  return tracks;
}
