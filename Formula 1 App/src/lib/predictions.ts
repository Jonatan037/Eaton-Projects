// Predictions Engine for ApexGrid AI
// Simple predictive model for race outcomes

import type { DriverStanding, RaceResult } from './standings';

// ============================================
// TYPES
// ============================================

export interface PredictionInput {
  driverId: string;
  driverName: string;
  teamId: string;
  teamName: string;
  recentResults: RaceResult[]; // Last N race results
  qualiPositions: number[]; // Recent qualifying positions
}

export interface DriverPrediction {
  driverId: string;
  driverName: string;
  teamName: string;
  expectedPosition: number;
  confidence: number; // 0-1
  confidenceBand: [number, number]; // [min, max] position range
  factors: {
    recentPerformance: number;
    qualiPace: number;
    teamMomentum: number;
    consistency: number;
  };
}

export interface PredictionResult {
  predictions: DriverPrediction[];
  modelVersion: string;
  generatedAt: string;
  isExperimental: boolean;
  warnings: string[];
}

// ============================================
// CONFIGURATION
// ============================================

export const PREDICTION_CONFIG = {
  // Number of recent rounds to consider
  recentRoundsCount: 5,
  
  // Weight decay for recency (more recent = higher weight)
  recencyDecayFactor: 0.8,
  
  // Factor weights (must sum to 1.0)
  weights: {
    recentPerformance: 0.45,
    qualiPace: 0.25,
    teamMomentum: 0.20,
    consistency: 0.10,
  },
  
  // Confidence calculation
  minConfidence: 0.3,
  maxConfidence: 0.85,
  
  // Position band widths based on confidence
  bandMultiplier: 2.5,
};

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Calculate weighted average with recency decay
 */
export function weightedAverage(values: number[], decayFactor: number): number {
  if (values.length === 0) return 0;
  
  let weightedSum = 0;
  let totalWeight = 0;
  
  // Most recent first
  values.forEach((value, index) => {
    const weight = Math.pow(decayFactor, index);
    weightedSum += value * weight;
    totalWeight += weight;
  });
  
  return totalWeight > 0 ? weightedSum / totalWeight : 0;
}

/**
 * Calculate standard deviation
 */
export function standardDeviation(values: number[]): number {
  if (values.length < 2) return 0;
  
  const mean = values.reduce((a, b) => a + b, 0) / values.length;
  const squaredDiffs = values.map((v) => Math.pow(v - mean, 2));
  const avgSquaredDiff = squaredDiffs.reduce((a, b) => a + b, 0) / values.length;
  
  return Math.sqrt(avgSquaredDiff);
}

/**
 * Normalize a value to 0-1 range
 */
export function normalize(value: number, min: number, max: number): number {
  if (max === min) return 0.5;
  return Math.max(0, Math.min(1, (value - min) / (max - min)));
}

/**
 * Convert position-based score to 0-1 (lower position = better)
 */
export function positionToScore(position: number, gridSize = 20): number {
  return 1 - (position - 1) / (gridSize - 1);
}

// ============================================
// PREDICTION FACTORS
// ============================================

/**
 * Calculate recent performance factor
 * Based on weighted average of recent race finishing positions
 */
export function calculateRecentPerformance(
  results: RaceResult[],
  config = PREDICTION_CONFIG
): number {
  const raceResults = results
    .filter((r) => r.sessionType === 'RACE' && r.position !== null)
    .slice(0, config.recentRoundsCount);
  
  if (raceResults.length === 0) return 0.5; // Neutral for new drivers
  
  const positions = raceResults.map((r) => r.position!);
  const avgPosition = weightedAverage(positions, config.recencyDecayFactor);
  
  return positionToScore(avgPosition);
}

/**
 * Calculate qualifying pace factor
 * Based on recent qualifying positions
 */
export function calculateQualiPace(
  qualiPositions: number[],
  config = PREDICTION_CONFIG
): number {
  if (qualiPositions.length === 0) return 0.5;
  
  const recentQuali = qualiPositions.slice(0, config.recentRoundsCount);
  const avgPosition = weightedAverage(recentQuali, config.recencyDecayFactor);
  
  return positionToScore(avgPosition);
}

/**
 * Calculate team momentum factor
 * Based on team's recent trajectory (improving or declining)
 */
export function calculateTeamMomentum(
  teamResults: RaceResult[],
  config = PREDICTION_CONFIG
): number {
  const raceResults = teamResults
    .filter((r) => r.sessionType === 'RACE' && r.position !== null)
    .slice(0, config.recentRoundsCount * 2); // More data for team
  
  if (raceResults.length < 2) return 0.5;
  
  // Split into halves and compare
  const midpoint = Math.floor(raceResults.length / 2);
  const recentHalf = raceResults.slice(0, midpoint);
  const olderHalf = raceResults.slice(midpoint);
  
  const recentAvg = recentHalf.reduce((sum, r) => sum + r.position!, 0) / recentHalf.length;
  const olderAvg = olderHalf.reduce((sum, r) => sum + r.position!, 0) / olderHalf.length;
  
  // Improvement = lower recent position
  const improvement = olderAvg - recentAvg;
  
  // Normalize: -5 (worse) to +5 (better) positions
  return normalize(improvement, -5, 5);
}

/**
 * Calculate consistency factor
 * Based on standard deviation of finishing positions
 */
export function calculateConsistency(
  results: RaceResult[],
  config = PREDICTION_CONFIG
): number {
  const positions = results
    .filter((r) => r.sessionType === 'RACE' && r.position !== null)
    .slice(0, config.recentRoundsCount)
    .map((r) => r.position!);
  
  if (positions.length < 2) return 0.5;
  
  const std = standardDeviation(positions);
  
  // Lower std = more consistent = higher score
  // Normalize: 0 (perfect consistency) to 10 (very inconsistent)
  return 1 - normalize(std, 0, 10);
}

// ============================================
// MAIN PREDICTION FUNCTION
// ============================================

/**
 * Generate predictions for all drivers
 */
export function generatePredictions(
  inputs: PredictionInput[],
  allResults: RaceResult[],
  config = PREDICTION_CONFIG
): PredictionResult {
  const warnings: string[] = [];
  
  if (inputs.length === 0) {
    return {
      predictions: [],
      modelVersion: '1.0.0-experimental',
      generatedAt: new Date().toISOString(),
      isExperimental: true,
      warnings: ['No driver data provided'],
    };
  }
  
  // Group results by team for team momentum calculation
  const resultsByTeam = new Map<string, RaceResult[]>();
  allResults.forEach((r) => {
    if (!resultsByTeam.has(r.teamId)) {
      resultsByTeam.set(r.teamId, []);
    }
    resultsByTeam.get(r.teamId)!.push(r);
  });
  
  // Calculate predictions for each driver
  const predictions: DriverPrediction[] = inputs.map((input) => {
    const teamResults = resultsByTeam.get(input.teamId) || [];
    
    // Calculate factors
    const factors = {
      recentPerformance: calculateRecentPerformance(input.recentResults, config),
      qualiPace: calculateQualiPace(input.qualiPositions, config),
      teamMomentum: calculateTeamMomentum(teamResults, config),
      consistency: calculateConsistency(input.recentResults, config),
    };
    
    // Calculate weighted score
    const weightedScore =
      factors.recentPerformance * config.weights.recentPerformance +
      factors.qualiPace * config.weights.qualiPace +
      factors.teamMomentum * config.weights.teamMomentum +
      factors.consistency * config.weights.consistency;
    
    // Confidence based on data availability and consistency
    const dataPoints = input.recentResults.length + input.qualiPositions.length;
    const dataConfidence = normalize(dataPoints, 0, config.recentRoundsCount * 2);
    const confidence = Math.max(
      config.minConfidence,
      Math.min(config.maxConfidence, dataConfidence * factors.consistency)
    );
    
    return {
      driverId: input.driverId,
      driverName: input.driverName,
      teamName: input.teamName,
      expectedPosition: 0, // Will be calculated after sorting
      confidence,
      confidenceBand: [0, 0] as [number, number],
      factors,
      _score: weightedScore, // Internal, removed later
    };
  });
  
  // Sort by score (higher = better = lower position)
  predictions.sort((a, b) => (b as any)._score - (a as any)._score);
  
  // Assign positions and confidence bands
  predictions.forEach((pred, index) => {
    pred.expectedPosition = index + 1;
    
    // Calculate confidence band
    const bandWidth = Math.round(config.bandMultiplier * (1 - pred.confidence));
    pred.confidenceBand = [
      Math.max(1, pred.expectedPosition - bandWidth),
      Math.min(inputs.length, pred.expectedPosition + bandWidth),
    ];
    
    // Remove internal score
    delete (pred as any)._score;
  });
  
  // Add warnings for low-data predictions
  predictions.forEach((pred) => {
    if (pred.confidence < 0.5) {
      warnings.push(
        `Low confidence for ${pred.driverName}: insufficient historical data`
      );
    }
  });
  
  return {
    predictions: predictions.slice(0, 10), // Top 10
    modelVersion: '1.0.0-experimental',
    generatedAt: new Date().toISOString(),
    isExperimental: true,
    warnings,
  };
}

/**
 * Get prediction explanation text
 */
export function explainPrediction(
  prediction: DriverPrediction,
  locale: 'en' | 'es' = 'en'
): string {
  const { factors, expectedPosition, confidence, confidenceBand } = prediction;
  
  const factorDescriptions = {
    en: {
      recentPerformance: factors.recentPerformance > 0.6 ? 'strong recent results' : 'room for improvement',
      qualiPace: factors.qualiPace > 0.6 ? 'good qualifying pace' : 'qualifying challenges',
      teamMomentum: factors.teamMomentum > 0.6 ? 'team on the rise' : 'team stabilizing',
      consistency: factors.consistency > 0.6 ? 'consistent performer' : 'variable results',
    },
    es: {
      recentPerformance: factors.recentPerformance > 0.6 ? 'buenos resultados recientes' : 'margen de mejora',
      qualiPace: factors.qualiPace > 0.6 ? 'buen ritmo en clasificación' : 'desafíos en clasificación',
      teamMomentum: factors.teamMomentum > 0.6 ? 'equipo en ascenso' : 'equipo estabilizándose',
      consistency: factors.consistency > 0.6 ? 'rendimiento consistente' : 'resultados variables',
    },
  };
  
  const desc = factorDescriptions[locale];
  const confidenceLabel = confidence > 0.7 ? (locale === 'en' ? 'High' : 'Alta') : 
                          confidence > 0.5 ? (locale === 'en' ? 'Medium' : 'Media') : 
                          (locale === 'en' ? 'Low' : 'Baja');
  
  if (locale === 'es') {
    return `Posición esperada: P${expectedPosition} (${confidenceBand[0]}-${confidenceBand[1]}). ` +
           `Confianza: ${confidenceLabel}. ` +
           `Factores: ${desc.recentPerformance}, ${desc.qualiPace}, ${desc.teamMomentum}, ${desc.consistency}.`;
  }
  
  return `Expected position: P${expectedPosition} (${confidenceBand[0]}-${confidenceBand[1]}). ` +
         `Confidence: ${confidenceLabel}. ` +
         `Factors: ${desc.recentPerformance}, ${desc.qualiPace}, ${desc.teamMomentum}, ${desc.consistency}.`;
}
