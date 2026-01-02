// Standings Calculator for ApexGrid AI
// Handles driver and constructor championship standings with tie-breakers

import type { SessionType, ResultStatus } from '@/schemas';

// ============================================
// TYPES
// ============================================

export interface RaceResult {
  driverId: string;
  driverName: string;
  teamId: string;
  teamName: string;
  roundId: string;
  roundNumber: number;
  sessionType: SessionType;
  position: number | null;
  status: ResultStatus;
  points: number;
  fastestLap: boolean;
  pole: boolean;
}

export interface DriverStanding {
  driverId: string;
  driverName: string;
  teamId: string;
  teamName: string;
  points: number;
  position: number;
  wins: number;
  podiums: number;
  poles: number;
  fastestLaps: number;
  finishPositions: Record<number, number>; // position -> count
  dnfs: number;
  racesCompleted: number;
  pointsHistory: { roundNumber: number; points: number; total: number }[];
  trend: 'up' | 'down' | 'same'; // Compared to previous round
}

export interface ConstructorStanding {
  teamId: string;
  teamName: string;
  points: number;
  position: number;
  wins: number;
  podiums: number;
  fastestLaps: number;
  finishPositions: Record<number, number>;
  racesCompleted: number;
  drivers: string[];
  pointsHistory: { roundNumber: number; points: number; total: number }[];
  trend: 'up' | 'down' | 'same';
}

export interface ScoringConfig {
  racePoints: Record<string, number>;
  sprintPoints: Record<string, number>;
  polePositionPoints: number;
  fastestLapPoints: number;
  fastestLapEligibleTop: number;
  dnfPenalty: number;
  attendancePenalty: number;
}

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Calculate points for a single result
 */
export function calculateResultPoints(
  result: Omit<RaceResult, 'points'>,
  scoring: ScoringConfig
): number {
  let points = 0;

  // Base position points
  if (result.status === 'FINISHED' && result.position !== null) {
    const positionKey = String(result.position);
    
    if (result.sessionType === 'RACE') {
      points += scoring.racePoints[positionKey] || 0;
    } else if (result.sessionType === 'SPRINT') {
      points += scoring.sprintPoints[positionKey] || 0;
    }
    // QUALIFYING doesn't award points typically
  }

  // Pole position bonus (only for qualifying)
  if (result.pole && result.sessionType === 'QUALIFYING') {
    points += scoring.polePositionPoints;
  }

  // Fastest lap bonus (only if finished in top N)
  if (
    result.fastestLap &&
    result.sessionType === 'RACE' &&
    result.position !== null &&
    result.position <= scoring.fastestLapEligibleTop
  ) {
    points += scoring.fastestLapPoints;
  }

  // DNF penalty
  if (result.status === 'DNF') {
    points += scoring.dnfPenalty; // Usually negative or zero
  }

  return Math.max(0, points); // No negative points overall
}

/**
 * Tie-breaker comparison for drivers
 * Order: wins > podiums > total points > highest finishing positions > fastest laps
 */
export function compareDrivers(a: DriverStanding, b: DriverStanding): number {
  // 1. Points (higher is better)
  if (a.points !== b.points) return b.points - a.points;

  // 2. Wins (higher is better)
  if (a.wins !== b.wins) return b.wins - a.wins;

  // 3. Podiums (higher is better)
  if (a.podiums !== b.podiums) return b.podiums - a.podiums;

  // 4. Highest finishing positions (countback)
  // Compare from 1st place downward
  for (let pos = 1; pos <= 30; pos++) {
    const aCount = a.finishPositions[pos] || 0;
    const bCount = b.finishPositions[pos] || 0;
    if (aCount !== bCount) return bCount - aCount;
  }

  // 5. Fastest laps (higher is better)
  if (a.fastestLaps !== b.fastestLaps) return b.fastestLaps - a.fastestLaps;

  // 6. Poles (higher is better)
  if (a.poles !== b.poles) return b.poles - a.poles;

  // Still tied - maintain original order
  return 0;
}

/**
 * Tie-breaker comparison for constructors
 */
export function compareConstructors(
  a: ConstructorStanding,
  b: ConstructorStanding
): number {
  // 1. Points
  if (a.points !== b.points) return b.points - a.points;

  // 2. Wins
  if (a.wins !== b.wins) return b.wins - a.wins;

  // 3. Podiums
  if (a.podiums !== b.podiums) return b.podiums - a.podiums;

  // 4. Highest finishing positions
  for (let pos = 1; pos <= 30; pos++) {
    const aCount = a.finishPositions[pos] || 0;
    const bCount = b.finishPositions[pos] || 0;
    if (aCount !== bCount) return bCount - aCount;
  }

  // 5. Fastest laps
  if (a.fastestLaps !== b.fastestLaps) return b.fastestLaps - a.fastestLaps;

  return 0;
}

// ============================================
// MAIN CALCULATION FUNCTIONS
// ============================================

/**
 * Calculate driver standings from results
 */
export function calculateDriverStandings(
  results: RaceResult[],
  previousStandings?: DriverStanding[]
): DriverStanding[] {
  const standingsMap = new Map<string, DriverStanding>();

  // Group results by round for history tracking
  const resultsByRound = new Map<number, RaceResult[]>();
  results.forEach((r) => {
    if (!resultsByRound.has(r.roundNumber)) {
      resultsByRound.set(r.roundNumber, []);
    }
    resultsByRound.get(r.roundNumber)!.push(r);
  });

  // Sort rounds
  const sortedRounds = Array.from(resultsByRound.keys()).sort((a, b) => a - b);

  // Process each result
  for (const result of results) {
    if (!standingsMap.has(result.driverId)) {
      standingsMap.set(result.driverId, {
        driverId: result.driverId,
        driverName: result.driverName,
        teamId: result.teamId,
        teamName: result.teamName,
        points: 0,
        position: 0,
        wins: 0,
        podiums: 0,
        poles: 0,
        fastestLaps: 0,
        finishPositions: {},
        dnfs: 0,
        racesCompleted: 0,
        pointsHistory: [],
        trend: 'same',
      });
    }

    const standing = standingsMap.get(result.driverId)!;

    // Add points
    standing.points += result.points;

    // Count races (only RACE session type counts)
    if (result.sessionType === 'RACE') {
      standing.racesCompleted++;

      if (result.status === 'FINISHED' && result.position !== null) {
        // Wins (P1)
        if (result.position === 1) standing.wins++;
        // Podiums (P1-P3)
        if (result.position <= 3) standing.podiums++;
        // Finish positions
        standing.finishPositions[result.position] =
          (standing.finishPositions[result.position] || 0) + 1;
      }

      if (result.status === 'DNF') {
        standing.dnfs++;
      }
    }

    // Poles (from qualifying)
    if (result.pole) standing.poles++;

    // Fastest laps
    if (result.fastestLap) standing.fastestLaps++;
  }

  // Build points history for each driver
  standingsMap.forEach((standing) => {
    let cumulativePoints = 0;
    for (const roundNum of sortedRounds) {
      const roundResults = resultsByRound.get(roundNum) || [];
      const driverResults = roundResults.filter(
        (r) => r.driverId === standing.driverId
      );
      const roundPoints = driverResults.reduce((sum, r) => sum + r.points, 0);
      cumulativePoints += roundPoints;
      standing.pointsHistory.push({
        roundNumber: roundNum,
        points: roundPoints,
        total: cumulativePoints,
      });
    }
  });

  // Convert to array and sort
  const standings = Array.from(standingsMap.values());
  standings.sort(compareDrivers);

  // Assign positions and calculate trends
  const previousPositions = new Map<string, number>();
  if (previousStandings) {
    previousStandings.forEach((s) => previousPositions.set(s.driverId, s.position));
  }

  standings.forEach((standing, index) => {
    standing.position = index + 1;

    // Calculate trend
    const prevPos = previousPositions.get(standing.driverId);
    if (prevPos !== undefined) {
      if (standing.position < prevPos) standing.trend = 'up';
      else if (standing.position > prevPos) standing.trend = 'down';
      else standing.trend = 'same';
    }
  });

  return standings;
}

/**
 * Calculate constructor standings from driver standings
 */
export function calculateConstructorStandings(
  results: RaceResult[],
  driverStandings: DriverStanding[],
  previousStandings?: ConstructorStanding[]
): ConstructorStanding[] {
  const standingsMap = new Map<string, ConstructorStanding>();

  // Group by team
  for (const driver of driverStandings) {
    if (!standingsMap.has(driver.teamId)) {
      standingsMap.set(driver.teamId, {
        teamId: driver.teamId,
        teamName: driver.teamName,
        points: 0,
        position: 0,
        wins: 0,
        podiums: 0,
        fastestLaps: 0,
        finishPositions: {},
        racesCompleted: 0,
        drivers: [],
        pointsHistory: [],
        trend: 'same',
      });
    }

    const standing = standingsMap.get(driver.teamId)!;
    standing.points += driver.points;
    standing.wins += driver.wins;
    standing.podiums += driver.podiums;
    standing.fastestLaps += driver.fastestLaps;
    standing.racesCompleted = Math.max(standing.racesCompleted, driver.racesCompleted);
    standing.drivers.push(driver.driverId);

    // Merge finish positions
    for (const [pos, count] of Object.entries(driver.finishPositions)) {
      const posNum = parseInt(pos);
      standing.finishPositions[posNum] =
        (standing.finishPositions[posNum] || 0) + count;
    }
  }

  // Build points history for constructors
  const resultsByRound = new Map<number, RaceResult[]>();
  results.forEach((r) => {
    if (!resultsByRound.has(r.roundNumber)) {
      resultsByRound.set(r.roundNumber, []);
    }
    resultsByRound.get(r.roundNumber)!.push(r);
  });
  const sortedRounds = Array.from(resultsByRound.keys()).sort((a, b) => a - b);

  standingsMap.forEach((standing) => {
    let cumulativePoints = 0;
    for (const roundNum of sortedRounds) {
      const roundResults = resultsByRound.get(roundNum) || [];
      const teamResults = roundResults.filter((r) => r.teamId === standing.teamId);
      const roundPoints = teamResults.reduce((sum, r) => sum + r.points, 0);
      cumulativePoints += roundPoints;
      standing.pointsHistory.push({
        roundNumber: roundNum,
        points: roundPoints,
        total: cumulativePoints,
      });
    }
  });

  // Sort and assign positions
  const standings = Array.from(standingsMap.values());
  standings.sort(compareConstructors);

  const previousPositions = new Map<string, number>();
  if (previousStandings) {
    previousStandings.forEach((s) => previousPositions.set(s.teamId, s.position));
  }

  standings.forEach((standing, index) => {
    standing.position = index + 1;

    const prevPos = previousPositions.get(standing.teamId);
    if (prevPos !== undefined) {
      if (standing.position < prevPos) standing.trend = 'up';
      else if (standing.position > prevPos) standing.trend = 'down';
      else standing.trend = 'same';
    }
  });

  return standings;
}

/**
 * Get standings snapshot for caching
 */
export function createStandingsSnapshot(
  driverStandings: DriverStanding[],
  constructorStandings: ConstructorStanding[]
) {
  return {
    driverStandings: driverStandings,
    constructorStandings: constructorStandings,
    calculatedAt: new Date().toISOString(),
  };
}
