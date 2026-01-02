// CSV Parser for ApexGrid AI
// Handles CSV import for race results with validation

import Papa from 'papaparse';
import { CSVResultRowSchema, CSVImportSchema } from '@/schemas';
import type { z } from 'zod';

export type CSVResultRow = z.infer<typeof CSVResultRowSchema>;

export interface CSVParseResult {
  success: boolean;
  data: CSVResultRow[];
  errors: CSVParseError[];
  warnings: CSVParseWarning[];
  preview: CSVResultRow[];
}

export interface CSVParseError {
  row: number;
  field: string;
  message: string;
  value?: string;
}

export interface CSVParseWarning {
  row: number;
  message: string;
}

/**
 * Expected CSV headers
 */
export const CSV_HEADERS = [
  'roundIndex',
  'sessionType',
  'driverFullName',
  'gamertag',
  'teamName',
  'position',
  'status',
  'points',
  'fastestLap',
  'pole',
  'notes',
] as const;

/**
 * Generate a CSV template string
 */
export function generateCSVTemplate(): string {
  const headers = CSV_HEADERS.join(',');
  const exampleRows = [
    '1,QUALIFYING,Alex Turner,ApexTurner,Apex Racing,1,FINISHED,0,false,true,Pole position',
    '1,RACE,Alex Turner,ApexTurner,Apex Racing,2,FINISHED,18,true,false,Fastest lap',
    '1,RACE,Maria Santos,MariaSprints,Apex Racing,1,FINISHED,25,false,false,Race winner',
    '1,RACE,Marco Rossi,MarcoR_GFD,GridForce Dynamics,,DNF,0,false,false,Engine failure',
    '2,SPRINT,Emma Müller,EmmaMueller,GridForce Dynamics,3,FINISHED,6,false,false,',
  ];
  
  return [headers, ...exampleRows].join('\n');
}

/**
 * Parse CSV content and validate each row
 */
export function parseResultsCSV(csvContent: string): CSVParseResult {
  const result: CSVParseResult = {
    success: true,
    data: [],
    errors: [],
    warnings: [],
    preview: [],
  };

  // Parse CSV
  const parsed = Papa.parse(csvContent, {
    header: true,
    skipEmptyLines: true,
    transformHeader: (header: string) => header.trim(),
    transform: (value: string) => value.trim(),
  });

  // Check for parse errors
  if (parsed.errors.length > 0) {
    parsed.errors.forEach((error) => {
      result.errors.push({
        row: error.row || 0,
        field: 'csv',
        message: error.message,
      });
    });
  }

  // Validate headers
  const headers = parsed.meta.fields || [];
  const missingHeaders = CSV_HEADERS.filter(
    (h) => !headers.includes(h) && h !== 'notes' // notes is optional
  );
  
  if (missingHeaders.length > 0) {
    result.errors.push({
      row: 0,
      field: 'headers',
      message: `Missing required headers: ${missingHeaders.join(', ')}`,
    });
    result.success = false;
    return result;
  }

  // Validate each row
  const validatedRows: CSVResultRow[] = [];
  
  (parsed.data as Record<string, string>[]).forEach((row, index) => {
    const rowNumber = index + 2; // Account for header row

    // Skip completely empty rows
    if (Object.values(row).every((v) => !v)) {
      return;
    }

    // Transform row data
    const transformedRow = {
      roundIndex: row.roundIndex,
      sessionType: row.sessionType?.toUpperCase(),
      driverFullName: row.driverFullName,
      gamertag: row.gamertag,
      teamName: row.teamName,
      position: row.position || null,
      status: row.status?.toUpperCase() || 'FINISHED',
      points: row.points || '0',
      fastestLap: row.fastestLap?.toLowerCase(),
      pole: row.pole?.toLowerCase(),
      notes: row.notes || '',
    };

    // Validate with Zod
    const validation = CSVResultRowSchema.safeParse(transformedRow);

    if (!validation.success) {
      validation.error.errors.forEach((err) => {
        result.errors.push({
          row: rowNumber,
          field: err.path.join('.'),
          message: err.message,
          value: String(row[err.path[0] as string] || ''),
        });
      });
    } else {
      validatedRows.push(validation.data);

      // Add warnings for potential issues
      if (
        validation.data.status === 'FINISHED' &&
        validation.data.position === null
      ) {
        result.warnings.push({
          row: rowNumber,
          message: 'FINISHED status but no position specified',
        });
      }

      if (
        validation.data.fastestLap &&
        validation.data.sessionType !== 'RACE'
      ) {
        result.warnings.push({
          row: rowNumber,
          message: 'Fastest lap marked for non-race session',
        });
      }

      if (validation.data.pole && validation.data.sessionType !== 'QUALIFYING') {
        result.warnings.push({
          row: rowNumber,
          message: 'Pole position marked for non-qualifying session',
        });
      }
    }
  });

  result.data = validatedRows;
  result.preview = validatedRows.slice(0, 10);
  result.success = result.errors.length === 0;

  return result;
}

/**
 * Validate a complete import against league data
 */
export interface LeagueValidationContext {
  drivers: { fullName: string; gamertag: string; teamName: string }[];
  teams: { name: string }[];
  rounds: { roundNumber: number }[];
}

export function validateAgainstLeague(
  parsedData: CSVResultRow[],
  context: LeagueValidationContext
): CSVParseError[] {
  const errors: CSVParseError[] = [];

  const driverMap = new Map(
    context.drivers.map((d) => [d.gamertag.toLowerCase(), d])
  );
  const teamNames = new Set(context.teams.map((t) => t.name.toLowerCase()));
  const roundNumbers = new Set(context.rounds.map((r) => r.roundNumber));

  parsedData.forEach((row, index) => {
    const rowNumber = index + 2;

    // Check round exists
    if (!roundNumbers.has(row.roundIndex)) {
      errors.push({
        row: rowNumber,
        field: 'roundIndex',
        message: `Round ${row.roundIndex} does not exist in this league`,
        value: String(row.roundIndex),
      });
    }

    // Check driver exists
    const driver = driverMap.get(row.gamertag.toLowerCase());
    if (!driver) {
      errors.push({
        row: rowNumber,
        field: 'gamertag',
        message: `Driver with gamertag "${row.gamertag}" not found`,
        value: row.gamertag,
      });
    }

    // Check team exists
    if (!teamNames.has(row.teamName.toLowerCase())) {
      errors.push({
        row: rowNumber,
        field: 'teamName',
        message: `Team "${row.teamName}" not found`,
        value: row.teamName,
      });
    }

    // Check driver-team match
    if (driver && driver.teamName.toLowerCase() !== row.teamName.toLowerCase()) {
      errors.push({
        row: rowNumber,
        field: 'teamName',
        message: `Driver "${row.gamertag}" is not on team "${row.teamName}" (actual: ${driver.teamName})`,
        value: row.teamName,
      });
    }
  });

  return errors;
}

/**
 * Group parsed results by round for preview
 */
export function groupResultsByRound(
  data: CSVResultRow[]
): Map<number, Map<string, CSVResultRow[]>> {
  const grouped = new Map<number, Map<string, CSVResultRow[]>>();

  data.forEach((row) => {
    if (!grouped.has(row.roundIndex)) {
      grouped.set(row.roundIndex, new Map());
    }
    const roundMap = grouped.get(row.roundIndex)!;
    
    if (!roundMap.has(row.sessionType)) {
      roundMap.set(row.sessionType, []);
    }
    roundMap.get(row.sessionType)!.push(row);
  });

  // Sort each session by position
  grouped.forEach((roundMap) => {
    roundMap.forEach((results) => {
      results.sort((a, b) => {
        if (a.position === null || a.position === undefined) return 1;
        if (b.position === null || b.position === undefined) return -1;
        return a.position - b.position;
      });
    });
  });

  return grouped;
}
