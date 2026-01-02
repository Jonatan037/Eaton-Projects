import { describe, it, expect } from 'vitest';
import { 
  parseResultsCSV, 
  validateAgainstLeague,
  groupResultsByRound,
  generateCSVTemplate,
  CSV_HEADERS,
  type CSVResultRow,
  type LeagueValidationContext,
} from '@/lib/csv-parser';

describe('CSV Parser', () => {
  describe('parseResultsCSV', () => {
    it('should parse valid CSV with all columns', () => {
      const csv = `roundIndex,sessionType,driverFullName,gamertag,teamName,position,status,points,fastestLap,pole,notes
1,RACE,Max Verstappen,MaxV33,Red Bull,1,FINISHED,25,true,false,Great race
1,RACE,Lewis Hamilton,LH44,Mercedes,2,FINISHED,18,false,false,`;

      const result = parseResultsCSV(csv);

      expect(result.success).toBe(true);
      expect(result.data.length).toBe(2);
      expect(result.data[0]).toMatchObject({
        roundIndex: 1,
        sessionType: 'RACE',
        driverFullName: 'Max Verstappen',
        gamertag: 'MaxV33',
        teamName: 'Red Bull',
        position: 1,
        status: 'FINISHED',
        points: 25,
        fastestLap: true,
        pole: false,
      });
      expect(result.data[1].driverFullName).toBe('Lewis Hamilton');
    });

    it('should handle DNF entries', () => {
      const csv = `roundIndex,sessionType,driverFullName,gamertag,teamName,position,status,points,fastestLap,pole,notes
1,RACE,Charles Leclerc,CL16,Ferrari,,DNF,0,false,false,Engine failure`;

      const result = parseResultsCSV(csv);

      expect(result.success).toBe(true);
      expect(result.data[0].status).toBe('DNF');
      expect(result.data[0].position).toBeNull();
    });

    it('should handle DSQ entries', () => {
      const csv = `roundIndex,sessionType,driverFullName,gamertag,teamName,position,status,points,fastestLap,pole,notes
1,RACE,Sebastian Vettel,SV5,Aston Martin,,DSQ,0,false,false,Technical infringement`;

      const result = parseResultsCSV(csv);

      expect(result.success).toBe(true);
      expect(result.data[0].status).toBe('DSQ');
    });

    it('should handle DNS entries', () => {
      const csv = `roundIndex,sessionType,driverFullName,gamertag,teamName,position,status,points,fastestLap,pole,notes
1,RACE,George Russell,GR63,Mercedes,,DNS,0,false,false,Mechanical issue`;

      const result = parseResultsCSV(csv);

      expect(result.success).toBe(true);
      expect(result.data[0].status).toBe('DNS');
    });

    it('should handle sprint sessions', () => {
      const csv = `roundIndex,sessionType,driverFullName,gamertag,teamName,position,status,points,fastestLap,pole,notes
1,SPRINT,Max Verstappen,MaxV33,Red Bull,1,FINISHED,8,false,false,Sprint winner`;

      const result = parseResultsCSV(csv);

      expect(result.success).toBe(true);
      expect(result.data[0].sessionType).toBe('SPRINT');
      expect(result.data[0].points).toBe(8);
    });

    it('should handle qualifying sessions with pole', () => {
      const csv = `roundIndex,sessionType,driverFullName,gamertag,teamName,position,status,points,fastestLap,pole,notes
1,QUALIFYING,Carlos Sainz,CS55,Ferrari,1,FINISHED,0,false,true,Pole position`;

      const result = parseResultsCSV(csv);

      expect(result.success).toBe(true);
      expect(result.data[0].sessionType).toBe('QUALIFYING');
      expect(result.data[0].pole).toBe(true);
    });

    it('should handle fastest lap bonus', () => {
      const csv = `roundIndex,sessionType,driverFullName,gamertag,teamName,position,status,points,fastestLap,pole,notes
1,RACE,Lando Norris,LN4,McLaren,3,FINISHED,16,true,false,FL + podium`;

      const result = parseResultsCSV(csv);

      expect(result.success).toBe(true);
      expect(result.data[0].fastestLap).toBe(true);
      expect(result.data[0].points).toBe(16);
    });

    it('should skip empty rows', () => {
      const csv = `roundIndex,sessionType,driverFullName,gamertag,teamName,position,status,points,fastestLap,pole,notes
1,RACE,Driver A,TagA,Team A,1,FINISHED,25,false,false,

1,RACE,Driver B,TagB,Team B,2,FINISHED,18,false,false,`;

      const result = parseResultsCSV(csv);
      expect(result.data.length).toBe(2);
    });

    it('should trim whitespace', () => {
      const csv = `roundIndex,sessionType,driverFullName,gamertag,teamName,position,status,points,fastestLap,pole,notes
1,RACE,  Max Verstappen  ,  MaxV33  ,  Red Bull  ,1,FINISHED,25,false,false,`;

      const result = parseResultsCSV(csv);

      expect(result.data[0].driverFullName).toBe('Max Verstappen');
      expect(result.data[0].gamertag).toBe('MaxV33');
      expect(result.data[0].teamName).toBe('Red Bull');
    });

    it('should report missing required headers', () => {
      const csv = `driverFullName,teamName,position
Max Verstappen,Red Bull,1`;

      const result = parseResultsCSV(csv);

      expect(result.success).toBe(false);
      expect(result.errors.length).toBeGreaterThan(0);
      expect(result.errors[0].message).toContain('Missing required headers');
    });

    it('should report validation errors for invalid data', () => {
      const csv = `roundIndex,sessionType,driverFullName,gamertag,teamName,position,status,points,fastestLap,pole,notes
abc,RACE,Max Verstappen,MaxV33,Red Bull,1,FINISHED,25,false,false,`;

      const result = parseResultsCSV(csv);

      expect(result.success).toBe(false);
      expect(result.errors.some(e => e.field === 'roundIndex')).toBe(true);
    });

    it('should add warnings for fastest lap in non-race session', () => {
      const csv = `roundIndex,sessionType,driverFullName,gamertag,teamName,position,status,points,fastestLap,pole,notes
1,QUALIFYING,Max Verstappen,MaxV33,Red Bull,1,FINISHED,0,true,false,FL in quali?`;

      const result = parseResultsCSV(csv);

      expect(result.warnings.length).toBeGreaterThan(0);
      expect(result.warnings[0].message).toContain('Fastest lap marked for non-race session');
    });

    it('should warn about FINISHED status without position', () => {
      const csv = `roundIndex,sessionType,driverFullName,gamertag,teamName,position,status,points,fastestLap,pole,notes
1,RACE,Max Verstappen,MaxV33,Red Bull,,FINISHED,0,false,false,`;

      const result = parseResultsCSV(csv);

      expect(result.warnings.some(w => w.message.includes('FINISHED status but no position'))).toBe(true);
    });
  });

  describe('validateAgainstLeague', () => {
    const mockContext: LeagueValidationContext = {
      drivers: [
        { fullName: 'Max Verstappen', gamertag: 'MaxV33', teamName: 'Red Bull' },
        { fullName: 'Lewis Hamilton', gamertag: 'LH44', teamName: 'Mercedes' },
      ],
      teams: [{ name: 'Red Bull' }, { name: 'Mercedes' }],
      rounds: [{ roundNumber: 1 }, { roundNumber: 2 }],
    };

    it('should validate correctly when all data matches', () => {
      const data: CSVResultRow[] = [
        {
          roundIndex: 1,
          sessionType: 'RACE',
          driverFullName: 'Max Verstappen',
          gamertag: 'MaxV33',
          teamName: 'Red Bull',
          position: 1,
          status: 'FINISHED',
          points: 25,
          fastestLap: false,
          pole: false,
        },
      ];

      const errors = validateAgainstLeague(data, mockContext);
      expect(errors.length).toBe(0);
    });

    it('should report error for non-existent round', () => {
      const data: CSVResultRow[] = [
        {
          roundIndex: 99,
          sessionType: 'RACE',
          driverFullName: 'Max Verstappen',
          gamertag: 'MaxV33',
          teamName: 'Red Bull',
          position: 1,
          status: 'FINISHED',
          points: 25,
          fastestLap: false,
          pole: false,
        },
      ];

      const errors = validateAgainstLeague(data, mockContext);
      expect(errors.length).toBe(1);
      expect(errors[0].message).toContain('Round 99 does not exist');
    });

    it('should report error for non-existent driver', () => {
      const data: CSVResultRow[] = [
        {
          roundIndex: 1,
          sessionType: 'RACE',
          driverFullName: 'Unknown Driver',
          gamertag: 'Unknown123',
          teamName: 'Red Bull',
          position: 1,
          status: 'FINISHED',
          points: 25,
          fastestLap: false,
          pole: false,
        },
      ];

      const errors = validateAgainstLeague(data, mockContext);
      expect(errors.some(e => e.message.includes('not found'))).toBe(true);
    });

    it('should report error for driver-team mismatch', () => {
      const data: CSVResultRow[] = [
        {
          roundIndex: 1,
          sessionType: 'RACE',
          driverFullName: 'Max Verstappen',
          gamertag: 'MaxV33',
          teamName: 'Mercedes', // Wrong team!
          position: 1,
          status: 'FINISHED',
          points: 25,
          fastestLap: false,
          pole: false,
        },
      ];

      const errors = validateAgainstLeague(data, mockContext);
      expect(errors.some(e => e.message.includes('not on team'))).toBe(true);
    });
  });

  describe('groupResultsByRound', () => {
    it('should group results by round and session', () => {
      const data: CSVResultRow[] = [
        { roundIndex: 1, sessionType: 'QUALIFYING', driverFullName: 'A', gamertag: 'a', teamName: 'T', position: 1, status: 'FINISHED', points: 0, fastestLap: false, pole: true },
        { roundIndex: 1, sessionType: 'RACE', driverFullName: 'A', gamertag: 'a', teamName: 'T', position: 1, status: 'FINISHED', points: 25, fastestLap: false, pole: false },
        { roundIndex: 2, sessionType: 'RACE', driverFullName: 'B', gamertag: 'b', teamName: 'T', position: 1, status: 'FINISHED', points: 25, fastestLap: true, pole: false },
      ];

      const grouped = groupResultsByRound(data);

      expect(grouped.size).toBe(2); // 2 rounds
      expect(grouped.get(1)?.size).toBe(2); // Round 1 has QUALIFYING and RACE
      expect(grouped.get(1)?.get('QUALIFYING')?.length).toBe(1);
      expect(grouped.get(1)?.get('RACE')?.length).toBe(1);
      expect(grouped.get(2)?.get('RACE')?.length).toBe(1);
    });

    it('should sort results by position within each session', () => {
      const data: CSVResultRow[] = [
        { roundIndex: 1, sessionType: 'RACE', driverFullName: 'C', gamertag: 'c', teamName: 'T', position: 3, status: 'FINISHED', points: 15, fastestLap: false, pole: false },
        { roundIndex: 1, sessionType: 'RACE', driverFullName: 'A', gamertag: 'a', teamName: 'T', position: 1, status: 'FINISHED', points: 25, fastestLap: false, pole: false },
        { roundIndex: 1, sessionType: 'RACE', driverFullName: 'B', gamertag: 'b', teamName: 'T', position: 2, status: 'FINISHED', points: 18, fastestLap: false, pole: false },
      ];

      const grouped = groupResultsByRound(data);
      const raceResults = grouped.get(1)?.get('RACE');

      expect(raceResults?.[0].position).toBe(1);
      expect(raceResults?.[1].position).toBe(2);
      expect(raceResults?.[2].position).toBe(3);
    });
  });

  describe('generateCSVTemplate', () => {
    it('should generate a valid CSV template', () => {
      const template = generateCSVTemplate();

      // Should have headers
      expect(template).toContain(CSV_HEADERS.join(','));
      
      // Should have example rows
      expect(template).toContain('QUALIFYING');
      expect(template).toContain('RACE');
    });

    it('should be parseable', () => {
      const template = generateCSVTemplate();
      const result = parseResultsCSV(template);

      expect(result.success).toBe(true);
      expect(result.data.length).toBeGreaterThan(0);
    });
  });

  describe('CSV_HEADERS', () => {
    it('should include all required fields', () => {
      expect(CSV_HEADERS).toContain('roundIndex');
      expect(CSV_HEADERS).toContain('sessionType');
      expect(CSV_HEADERS).toContain('driverFullName');
      expect(CSV_HEADERS).toContain('gamertag');
      expect(CSV_HEADERS).toContain('teamName');
      expect(CSV_HEADERS).toContain('position');
      expect(CSV_HEADERS).toContain('status');
      expect(CSV_HEADERS).toContain('points');
      expect(CSV_HEADERS).toContain('fastestLap');
      expect(CSV_HEADERS).toContain('pole');
    });
  });
});
