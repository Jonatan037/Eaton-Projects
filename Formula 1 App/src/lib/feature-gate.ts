/**
 * Feature Gate Utilities
 * Server-side functions to check subscription status and gate features
 */

import prisma from '@/lib/db';
import {
  SubscriptionTier,
  getPlan,
  hasFeature,
  isWithinLimit,
  PlanFeatures,
  PlanLimits,
  UPGRADE_PROMPTS,
} from '@/lib/subscription';

export interface FeatureGateResult {
  allowed: boolean;
  reason?: string;
  upgradePrompt?: { en: string; es: string };
  currentTier: SubscriptionTier;
  requiredTier?: SubscriptionTier;
}

export interface LimitGateResult {
  allowed: boolean;
  current: number;
  limit: number;
  remaining: number;
  reason?: string;
  upgradePrompt?: { en: string; es: string };
  currentTier: SubscriptionTier;
}

/**
 * Get user's subscription tier
 */
export async function getUserTier(userId: string): Promise<SubscriptionTier> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      subscriptionTier: true,
      subscriptionEndsAt: true,
    },
  });

  if (!user) {
    return 'FREE';
  }

  // Check if subscription is still valid
  if (user.subscriptionTier === 'PRO' && user.subscriptionEndsAt) {
    if (new Date(user.subscriptionEndsAt) < new Date()) {
      // Subscription expired, downgrade to FREE
      await prisma.user.update({
        where: { id: userId },
        data: { subscriptionTier: 'FREE' },
      });
      return 'FREE';
    }
  }

  return user.subscriptionTier as SubscriptionTier;
}

/**
 * Check if user can access a specific feature
 */
export async function canAccessFeature(
  userId: string,
  feature: keyof PlanFeatures
): Promise<FeatureGateResult> {
  const tier = await getUserTier(userId);
  const allowed = hasFeature(tier, feature);

  if (allowed) {
    return {
      allowed: true,
      currentTier: tier,
    };
  }

  return {
    allowed: false,
    reason: `This feature requires a Pro subscription`,
    upgradePrompt: UPGRADE_PROMPTS[feature as keyof typeof UPGRADE_PROMPTS],
    currentTier: tier,
    requiredTier: 'PRO',
  };
}

/**
 * Check if user is within a specific limit
 */
export async function checkLimit(
  userId: string,
  limitType: keyof PlanLimits,
  current: number
): Promise<LimitGateResult> {
  const tier = await getUserTier(userId);
  const plan = getPlan(tier);
  const limit = plan.limits[limitType];
  const allowed = current < limit;

  return {
    allowed,
    current,
    limit,
    remaining: Math.max(0, limit - current),
    reason: allowed ? undefined : `You've reached the ${limitType} limit for your plan`,
    upgradePrompt: allowed ? undefined : {
      en: `Upgrade to Pro to increase your ${limitType} limit`,
      es: `Actualiza a Pro para aumentar tu límite de ${limitType}`,
    },
    currentTier: tier,
  };
}

/**
 * Check if user can create a new league
 */
export async function canCreateLeague(userId: string): Promise<LimitGateResult> {
  const tier = await getUserTier(userId);
  
  // Count user's owned leagues
  const leagueCount = await prisma.membership.count({
    where: {
      userId,
      role: 'OWNER',
    },
  });

  const plan = getPlan(tier);
  const limit = plan.limits.maxLeagues;
  const allowed = leagueCount < limit;

  return {
    allowed,
    current: leagueCount,
    limit,
    remaining: Math.max(0, limit - leagueCount),
    reason: allowed ? undefined : UPGRADE_PROMPTS.maxLeagues.en,
    upgradePrompt: allowed ? undefined : UPGRADE_PROMPTS.maxLeagues,
    currentTier: tier,
  };
}

/**
 * Check if a league can accept new members
 */
export async function canAddMember(leagueId: string): Promise<LimitGateResult> {
  // Get league owner's tier
  const ownerMembership = await prisma.membership.findFirst({
    where: {
      leagueId,
      role: 'OWNER',
    },
    include: {
      user: {
        select: {
          subscriptionTier: true,
          subscriptionEndsAt: true,
        },
      },
    },
  });

  const tier = (ownerMembership?.user?.subscriptionTier as SubscriptionTier) || 'FREE';
  
  // Count current members
  const memberCount = await prisma.membership.count({
    where: { leagueId },
  });

  const plan = getPlan(tier);
  const limit = plan.limits.maxMembersPerLeague;
  const allowed = memberCount < limit;

  return {
    allowed,
    current: memberCount,
    limit,
    remaining: Math.max(0, limit - memberCount),
    reason: allowed ? undefined : UPGRADE_PROMPTS.maxMembers.en,
    upgradePrompt: allowed ? undefined : UPGRADE_PROMPTS.maxMembers,
    currentTier: tier,
  };
}

/**
 * Check if user can use AI features
 */
export async function canUseAI(userId: string): Promise<FeatureGateResult> {
  return canAccessFeature(userId, 'aiChat');
}

/**
 * Check if user can export data
 */
export async function canExportData(userId: string): Promise<FeatureGateResult> {
  return canAccessFeature(userId, 'dataExport');
}

/**
 * Get user's full subscription info
 */
export async function getSubscriptionInfo(userId: string) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      subscriptionTier: true,
      subscriptionEndsAt: true,
      stripeCustomerId: true,
    },
  });

  if (!user) {
    return null;
  }

  const tier = user.subscriptionTier as SubscriptionTier;
  const plan = getPlan(tier);

  // Get current usage
  const leagueCount = await prisma.membership.count({
    where: {
      userId,
      role: 'OWNER',
    },
  });

  return {
    tier,
    plan,
    usage: {
      leagues: leagueCount,
      maxLeagues: plan.limits.maxLeagues,
    },
    subscriptionEndsAt: user.subscriptionEndsAt,
    hasStripeCustomer: !!user.stripeCustomerId,
  };
}
