import { describe, it, expect } from 'vitest';
import {
  calculateDriverStandings,
  calculateConstructorStandings,
  calculateResultPoints,
  compareDrivers,
  compareConstructors,
  type RaceResult,
  type DriverStanding,
  type ConstructorStanding,
  type ScoringConfig,
} from '@/lib/standings';

// Default scoring config for tests
const defaultScoring: ScoringConfig = {
  racePoints: { '1': 25, '2': 18, '3': 15, '4': 12, '5': 10, '6': 8, '7': 6, '8': 4, '9': 2, '10': 1 },
  sprintPoints: { '1': 8, '2': 7, '3': 6, '4': 5, '5': 4, '6': 3, '7': 2, '8': 1 },
  polePositionPoints: 0,
  fastestLapPoints: 1,
  fastestLapEligibleTop: 10,
  dnfPenalty: 0,
  attendancePenalty: 0,
};

// Helper to create mock results
function createResult(overrides: Partial<RaceResult> = {}): RaceResult {
  return {
    driverId: 'driver-1',
    driverName: 'Test Driver',
    teamId: 'team-1',
    teamName: 'Test Team',
    roundId: 'round-1',
    roundNumber: 1,
    sessionType: 'RACE',
    position: 1,
    status: 'FINISHED',
    points: 25,
    fastestLap: false,
    pole: false,
    ...overrides,
  };
}

describe('Standings Calculator', () => {
  describe('calculateResultPoints', () => {
    it('should calculate race points for P1', () => {
      const result = createResult({ position: 1, sessionType: 'RACE', status: 'FINISHED' });
      const points = calculateResultPoints(result, defaultScoring);
      expect(points).toBe(25);
    });

    it('should calculate race points for P10', () => {
      const result = createResult({ position: 10, sessionType: 'RACE', status: 'FINISHED' });
      const points = calculateResultPoints(result, defaultScoring);
      expect(points).toBe(1);
    });

    it('should return 0 for positions outside points', () => {
      const result = createResult({ position: 15, sessionType: 'RACE', status: 'FINISHED' });
      const points = calculateResultPoints(result, defaultScoring);
      expect(points).toBe(0);
    });

    it('should calculate sprint points correctly', () => {
      const result = createResult({ position: 1, sessionType: 'SPRINT', status: 'FINISHED' });
      const points = calculateResultPoints(result, defaultScoring);
      expect(points).toBe(8);
    });

    it('should add fastest lap bonus if in top 10', () => {
      const result = createResult({ 
        position: 5, 
        sessionType: 'RACE', 
        status: 'FINISHED',
        fastestLap: true 
      });
      const points = calculateResultPoints(result, defaultScoring);
      expect(points).toBe(10 + 1); // P5 = 10 pts + FL = 1 pt
    });

    it('should NOT add fastest lap bonus if outside top 10', () => {
      const result = createResult({ 
        position: 11, 
        sessionType: 'RACE', 
        status: 'FINISHED',
        fastestLap: true 
      });
      const points = calculateResultPoints(result, defaultScoring);
      expect(points).toBe(0); // P11 = 0 pts, FL ineligible
    });

    it('should return 0 for DNF', () => {
      const result = createResult({ position: null, status: 'DNF' });
      const points = calculateResultPoints(result, defaultScoring);
      expect(points).toBe(0);
    });

    it('should return 0 for DSQ', () => {
      const result = createResult({ position: null, status: 'DSQ' });
      const points = calculateResultPoints(result, defaultScoring);
      expect(points).toBe(0);
    });

    it('should return 0 for DNS', () => {
      const result = createResult({ position: null, status: 'DNS' });
      const points = calculateResultPoints(result, defaultScoring);
      expect(points).toBe(0);
    });

    it('should add pole position bonus for qualifying', () => {
      const scoringWithPole = { ...defaultScoring, polePositionPoints: 3 };
      const result = createResult({ 
        position: 1, 
        sessionType: 'QUALIFYING', 
        status: 'FINISHED',
        pole: true 
      });
      const points = calculateResultPoints(result, scoringWithPole);
      expect(points).toBe(3); // Only pole bonus, no position points for quali
    });
  });

  describe('calculateDriverStandings', () => {
    it('should calculate standings from race results', () => {
      const results: RaceResult[] = [
        createResult({ driverId: 'd1', driverName: 'Driver 1', position: 1, points: 25 }),
        createResult({ driverId: 'd2', driverName: 'Driver 2', position: 2, points: 18 }),
        createResult({ driverId: 'd3', driverName: 'Driver 3', position: 3, points: 15 }),
      ];

      const standings = calculateDriverStandings(results);

      expect(standings.length).toBe(3);
      expect(standings[0].driverName).toBe('Driver 1');
      expect(standings[0].points).toBe(25);
      expect(standings[0].position).toBe(1);
      expect(standings[0].wins).toBe(1);
    });

    it('should accumulate points across multiple rounds', () => {
      const results: RaceResult[] = [
        createResult({ driverId: 'd1', roundNumber: 1, position: 1, points: 25 }),
        createResult({ driverId: 'd1', roundNumber: 2, position: 2, points: 18 }),
        createResult({ driverId: 'd2', roundNumber: 1, position: 2, points: 18 }),
        createResult({ driverId: 'd2', roundNumber: 2, position: 1, points: 25 }),
      ];

      const standings = calculateDriverStandings(results);

      // Both have 43 points, but d1 has same wins as d2
      expect(standings[0].points).toBe(43);
      expect(standings[1].points).toBe(43);
    });

    it('should count wins, podiums, and DNFs correctly', () => {
      const results: RaceResult[] = [
        createResult({ driverId: 'd1', roundNumber: 1, position: 1, points: 25 }),
        createResult({ driverId: 'd1', roundNumber: 2, position: 3, points: 15 }),
        createResult({ driverId: 'd1', roundNumber: 3, position: null, status: 'DNF', points: 0 }),
      ];

      const standings = calculateDriverStandings(results);

      expect(standings[0].wins).toBe(1);
      expect(standings[0].podiums).toBe(2);
      expect(standings[0].dnfs).toBe(1);
      expect(standings[0].racesCompleted).toBe(3);
    });

    it('should track fastest laps', () => {
      const results: RaceResult[] = [
        createResult({ driverId: 'd1', position: 5, points: 11, fastestLap: true }),
        createResult({ driverId: 'd1', roundNumber: 2, position: 3, points: 15, fastestLap: false }),
      ];

      const standings = calculateDriverStandings(results);

      expect(standings[0].fastestLaps).toBe(1);
    });

    it('should return empty array for no results', () => {
      const standings = calculateDriverStandings([]);
      expect(standings).toEqual([]);
    });
  });

  describe('calculateConstructorStandings', () => {
    it('should aggregate points by team', () => {
      const results: RaceResult[] = [
        createResult({ driverId: 'd1', teamId: 't1', teamName: 'Team A', position: 1, points: 25 }),
        createResult({ driverId: 'd2', teamId: 't1', teamName: 'Team A', position: 3, points: 15 }),
        createResult({ driverId: 'd3', teamId: 't2', teamName: 'Team B', position: 2, points: 18 }),
      ];

      const standings = calculateConstructorStandings(results);

      expect(standings.length).toBe(2);
      expect(standings[0].teamName).toBe('Team A');
      expect(standings[0].points).toBe(40); // 25 + 15
      expect(standings[1].teamName).toBe('Team B');
      expect(standings[1].points).toBe(18);
    });

    it('should track team wins and podiums', () => {
      const results: RaceResult[] = [
        createResult({ driverId: 'd1', teamId: 't1', teamName: 'Team A', position: 1, points: 25 }),
        createResult({ driverId: 'd2', teamId: 't1', teamName: 'Team A', position: 2, points: 18 }),
      ];

      const standings = calculateConstructorStandings(results);

      expect(standings[0].wins).toBe(1);
      expect(standings[0].podiums).toBe(2);
    });
  });

  describe('compareDrivers (tie-breakers)', () => {
    it('should sort by points first', () => {
      const a: DriverStanding = {
        driverId: 'a', driverName: 'A', teamId: 't', teamName: 'T',
        points: 100, position: 0, wins: 0, podiums: 0, poles: 0, fastestLaps: 0,
        finishPositions: {}, dnfs: 0, racesCompleted: 5, pointsHistory: [], trend: 'same',
      };
      const b: DriverStanding = {
        driverId: 'b', driverName: 'B', teamId: 't', teamName: 'T',
        points: 50, position: 0, wins: 5, podiums: 5, poles: 5, fastestLaps: 5,
        finishPositions: {}, dnfs: 0, racesCompleted: 5, pointsHistory: [], trend: 'same',
      };

      expect(compareDrivers(a, b)).toBeLessThan(0); // a should be ahead
    });

    it('should use wins as first tie-breaker', () => {
      const a: DriverStanding = {
        driverId: 'a', driverName: 'A', teamId: 't', teamName: 'T',
        points: 100, position: 0, wins: 2, podiums: 0, poles: 0, fastestLaps: 0,
        finishPositions: {}, dnfs: 0, racesCompleted: 5, pointsHistory: [], trend: 'same',
      };
      const b: DriverStanding = {
        driverId: 'b', driverName: 'B', teamId: 't', teamName: 'T',
        points: 100, position: 0, wins: 3, podiums: 0, poles: 0, fastestLaps: 0,
        finishPositions: {}, dnfs: 0, racesCompleted: 5, pointsHistory: [], trend: 'same',
      };

      expect(compareDrivers(a, b)).toBeGreaterThan(0); // b should be ahead
    });

    it('should use podiums as second tie-breaker', () => {
      const a: DriverStanding = {
        driverId: 'a', driverName: 'A', teamId: 't', teamName: 'T',
        points: 100, position: 0, wins: 2, podiums: 5, poles: 0, fastestLaps: 0,
        finishPositions: {}, dnfs: 0, racesCompleted: 5, pointsHistory: [], trend: 'same',
      };
      const b: DriverStanding = {
        driverId: 'b', driverName: 'B', teamId: 't', teamName: 'T',
        points: 100, position: 0, wins: 2, podiums: 3, poles: 0, fastestLaps: 0,
        finishPositions: {}, dnfs: 0, racesCompleted: 5, pointsHistory: [], trend: 'same',
      };

      expect(compareDrivers(a, b)).toBeLessThan(0); // a should be ahead
    });

    it('should use countback as third tie-breaker', () => {
      const a: DriverStanding = {
        driverId: 'a', driverName: 'A', teamId: 't', teamName: 'T',
        points: 100, position: 0, wins: 2, podiums: 5, poles: 0, fastestLaps: 0,
        finishPositions: { 1: 2, 2: 3, 3: 0 }, dnfs: 0, racesCompleted: 5, pointsHistory: [], trend: 'same',
      };
      const b: DriverStanding = {
        driverId: 'b', driverName: 'B', teamId: 't', teamName: 'T',
        points: 100, position: 0, wins: 2, podiums: 5, poles: 0, fastestLaps: 0,
        finishPositions: { 1: 2, 2: 2, 3: 1 }, dnfs: 0, racesCompleted: 5, pointsHistory: [], trend: 'same',
      };

      // a has more 2nd places (3 vs 2), so a should be ahead
      expect(compareDrivers(a, b)).toBeLessThan(0);
    });
  });

  describe('compareConstructors (tie-breakers)', () => {
    it('should sort by points first', () => {
      const a: ConstructorStanding = {
        teamId: 'a', teamName: 'A', points: 200, position: 0, wins: 0, podiums: 0,
        fastestLaps: 0, finishPositions: {}, racesCompleted: 10, drivers: [], pointsHistory: [], trend: 'same',
      };
      const b: ConstructorStanding = {
        teamId: 'b', teamName: 'B', points: 150, position: 0, wins: 5, podiums: 10,
        fastestLaps: 5, finishPositions: {}, racesCompleted: 10, drivers: [], pointsHistory: [], trend: 'same',
      };

      expect(compareConstructors(a, b)).toBeLessThan(0);
    });

    it('should use wins as tie-breaker', () => {
      const a: ConstructorStanding = {
        teamId: 'a', teamName: 'A', points: 200, position: 0, wins: 3, podiums: 5,
        fastestLaps: 0, finishPositions: {}, racesCompleted: 10, drivers: [], pointsHistory: [], trend: 'same',
      };
      const b: ConstructorStanding = {
        teamId: 'b', teamName: 'B', points: 200, position: 0, wins: 5, podiums: 5,
        fastestLaps: 0, finishPositions: {}, racesCompleted: 10, drivers: [], pointsHistory: [], trend: 'same',
      };

      expect(compareConstructors(a, b)).toBeGreaterThan(0); // b ahead
    });
  });
});
