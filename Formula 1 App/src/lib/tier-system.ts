/**
 * ApexGrid AI - Tier System Utilities
 * 
 * This module provides functions for checking tier limits and permissions.
 */

import { prisma } from '@/lib/prisma';
import { TierType, UserRole } from '@prisma/client';

// ============================================
// TIER DEFINITIONS (cached for performance)
// ============================================

export interface TierLimits {
  maxLeagues: number;           // -1 = unlimited
  maxChampionshipsPerLeague: number; // -1 = unlimited
  maxAdminsPerLeague: number;
  hasAIFeatures: boolean;
  hasAdvancedStats: boolean;
  hasCustomBranding: boolean;
  trialDays: number;
}

// Default tier limits (fallback if DB not available)
export const DEFAULT_TIER_LIMITS: Record<TierType, TierLimits> = {
  FREE: {
    maxLeagues: 1,
    maxChampionshipsPerLeague: 1,
    maxAdminsPerLeague: 2,
    hasAIFeatures: false,
    hasAdvancedStats: false,
    hasCustomBranding: false,
    trialDays: 30,
  },
  PRO: {
    maxLeagues: 5,
    maxChampionshipsPerLeague: 3,
    maxAdminsPerLeague: 2,
    hasAIFeatures: true,
    hasAdvancedStats: true,
    hasCustomBranding: false,
    trialDays: 0,
  },
  UNLIMITED: {
    maxLeagues: -1,
    maxChampionshipsPerLeague: -1,
    maxAdminsPerLeague: 2,
    hasAIFeatures: true,
    hasAdvancedStats: true,
    hasCustomBranding: true,
    trialDays: 0,
  },
};

// ============================================
// USER PERMISSIONS
// ============================================

export interface UserWithTier {
  id: string;
  role: UserRole;
  tier: TierType;
  tierExpiresAt: Date | null;
}

/**
 * Check if user is the App Owner (bypasses all limits)
 */
export function isAppOwner(user: UserWithTier): boolean {
  return user.role === UserRole.APP_OWNER;
}

/**
 * Check if user's FREE trial has expired
 */
export function isTrialExpired(user: UserWithTier): boolean {
  if (user.tier !== TierType.FREE) return false;
  if (!user.tierExpiresAt) return false;
  return new Date() > user.tierExpiresAt;
}

/**
 * Get tier limits for a user
 */
export async function getTierLimits(tier: TierType): Promise<TierLimits> {
  try {
    const tierDef = await prisma.tierDefinition.findUnique({
      where: { tier },
    });
    
    if (tierDef) {
      return {
        maxLeagues: tierDef.maxLeagues,
        maxChampionshipsPerLeague: tierDef.maxChampionshipsPerLeague,
        maxAdminsPerLeague: tierDef.maxAdminsPerLeague,
        hasAIFeatures: tierDef.hasAIFeatures,
        hasAdvancedStats: tierDef.hasAdvancedStats,
        hasCustomBranding: tierDef.hasCustomBranding,
        trialDays: tierDef.trialDays,
      };
    }
  } catch (error) {
    console.error('Error fetching tier limits:', error);
  }
  
  return DEFAULT_TIER_LIMITS[tier];
}

// ============================================
// LEAGUE PERMISSIONS
// ============================================

/**
 * Check if user can create a new league
 */
export async function canCreateLeague(userId: string): Promise<{
  allowed: boolean;
  reason?: string;
  currentCount: number;
  maxAllowed: number;
}> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });

  if (!user) {
    return { allowed: false, reason: 'User not found', currentCount: 0, maxAllowed: 0 };
  }

  // App Owner bypasses all limits
  if (user.role === UserRole.APP_OWNER) {
    return { allowed: true, currentCount: 0, maxAllowed: -1 };
  }

  // Check if FREE trial expired
  if (isTrialExpired(user)) {
    return { 
      allowed: false, 
      reason: 'Your free trial has expired. Please upgrade to PRO or UNLIMITED.',
      currentCount: 0,
      maxAllowed: 0,
    };
  }

  const limits = await getTierLimits(user.tier);
  const leagueCount = await prisma.league.count({
    where: { ownerId: userId },
  });

  const maxAllowed = limits.maxLeagues;
  const allowed = maxAllowed === -1 || leagueCount < maxAllowed;

  return {
    allowed,
    reason: allowed ? undefined : `You have reached your limit of ${maxAllowed} league(s). Upgrade to create more.`,
    currentCount: leagueCount,
    maxAllowed,
  };
}

/**
 * Check if user can create a championship in a league
 */
export async function canCreateChampionship(
  userId: string,
  leagueId: string
): Promise<{
  allowed: boolean;
  reason?: string;
  currentCount: number;
  maxAllowed: number;
}> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });

  if (!user) {
    return { allowed: false, reason: 'User not found', currentCount: 0, maxAllowed: 0 };
  }

  // Check if user is owner of the league
  const league = await prisma.league.findUnique({
    where: { id: leagueId },
  });

  if (!league) {
    return { allowed: false, reason: 'League not found', currentCount: 0, maxAllowed: 0 };
  }

  // Only league owner can create championships (their tier applies)
  const leagueOwner = await prisma.user.findUnique({
    where: { id: league.ownerId },
  });

  if (!leagueOwner) {
    return { allowed: false, reason: 'League owner not found', currentCount: 0, maxAllowed: 0 };
  }

  // App Owner bypasses all limits
  if (leagueOwner.role === UserRole.APP_OWNER) {
    return { allowed: true, currentCount: 0, maxAllowed: -1 };
  }

  // Check if owner's FREE trial expired
  if (isTrialExpired(leagueOwner)) {
    return {
      allowed: false,
      reason: 'The league owner\'s free trial has expired.',
      currentCount: 0,
      maxAllowed: 0,
    };
  }

  const limits = await getTierLimits(leagueOwner.tier);
  const championshipCount = await prisma.championship.count({
    where: { 
      leagueId,
      status: { in: ['DRAFT', 'ACTIVE'] }, // Only count active championships
    },
  });

  const maxAllowed = limits.maxChampionshipsPerLeague;
  const allowed = maxAllowed === -1 || championshipCount < maxAllowed;

  return {
    allowed,
    reason: allowed 
      ? undefined 
      : `This league has reached its limit of ${maxAllowed} active championship(s). The league owner needs to upgrade.`,
    currentCount: championshipCount,
    maxAllowed,
  };
}

// ============================================
// FEATURE ACCESS
// ============================================

/**
 * Check if user has access to AI features
 */
export async function hasAIAccess(userId: string): Promise<boolean> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });

  if (!user) return false;
  if (user.role === UserRole.APP_OWNER) return true;
  if (isTrialExpired(user)) return false;

  const limits = await getTierLimits(user.tier);
  return limits.hasAIFeatures;
}

/**
 * Check if user has access to advanced stats
 */
export async function hasAdvancedStatsAccess(userId: string): Promise<boolean> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });

  if (!user) return false;
  if (user.role === UserRole.APP_OWNER) return true;
  if (isTrialExpired(user)) return false;

  const limits = await getTierLimits(user.tier);
  return limits.hasAdvancedStats;
}

/**
 * Check if user has access to custom branding
 */
export async function hasCustomBrandingAccess(userId: string): Promise<boolean> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });

  if (!user) return false;
  if (user.role === UserRole.APP_OWNER) return true;
  if (isTrialExpired(user)) return false;

  const limits = await getTierLimits(user.tier);
  return limits.hasCustomBranding;
}

// ============================================
// ROLE CHECKS
// ============================================

/**
 * Check if user is owner or admin of a league
 */
export async function isLeagueAdmin(userId: string, leagueId: string): Promise<boolean> {
  const membership = await prisma.leagueMember.findUnique({
    where: {
      leagueId_userId: { leagueId, userId },
    },
  });

  return membership?.role === 'OWNER' || membership?.role === 'ADMIN';
}

/**
 * Check if user is the owner of a league
 */
export async function isLeagueOwner(userId: string, leagueId: string): Promise<boolean> {
  const league = await prisma.league.findUnique({
    where: { id: leagueId },
  });

  return league?.ownerId === userId;
}

/**
 * Check if user is admin of a championship
 */
export async function isChampionshipAdmin(
  userId: string,
  championshipId: string
): Promise<boolean> {
  // Check championship-level admin
  const membership = await prisma.championshipMember.findUnique({
    where: {
      championshipId_userId: { championshipId, userId },
    },
  });

  if (membership?.role === 'ADMIN') return true;

  // Check if user is league admin (inherits championship admin)
  const championship = await prisma.championship.findUnique({
    where: { id: championshipId },
  });

  if (championship) {
    return isLeagueAdmin(userId, championship.leagueId);
  }

  return false;
}

/**
 * Check if user can edit championship (is admin or league owner)
 */
export async function canEditChampionship(
  userId: string,
  championshipId: string
): Promise<boolean> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });

  // App Owner can edit anything
  if (user?.role === UserRole.APP_OWNER) return true;

  return isChampionshipAdmin(userId, championshipId);
}
