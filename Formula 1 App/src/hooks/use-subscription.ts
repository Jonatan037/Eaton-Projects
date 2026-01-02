'use client';

import { useState, useEffect, useCallback } from 'react';
import { SubscriptionTier, Plan, PLANS, PlanFeatures, PlanLimits } from '@/lib/subscription';

interface SubscriptionState {
  tier: SubscriptionTier;
  plan: Plan;
  isLoading: boolean;
  error: string | null;
}

interface UseSubscriptionReturn extends SubscriptionState {
  hasFeature: (feature: keyof PlanFeatures) => boolean;
  isWithinLimit: (limit: keyof PlanLimits, current: number) => boolean;
  canCreateLeague: (currentCount: number) => boolean;
  canAddMember: (currentCount: number) => boolean;
  isPro: boolean;
  refresh: () => Promise<void>;
}

/**
 * Hook to access subscription state and feature gates
 */
export function useSubscription(userId?: string): UseSubscriptionReturn {
  const [state, setState] = useState<SubscriptionState>({
    tier: 'FREE',
    plan: PLANS.FREE,
    isLoading: true,
    error: null,
  });

  const fetchSubscription = useCallback(async () => {
    if (!userId) {
      setState({
        tier: 'FREE',
        plan: PLANS.FREE,
        isLoading: false,
        error: null,
      });
      return;
    }

    try {
      const response = await fetch(`/api/subscription?userId=${userId}`);
      if (response.ok) {
        const data = await response.json();
        setState({
          tier: data.tier || 'FREE',
          plan: PLANS[data.tier as SubscriptionTier] || PLANS.FREE,
          isLoading: false,
          error: null,
        });
      } else {
        setState(prev => ({
          ...prev,
          isLoading: false,
          error: 'Failed to fetch subscription',
        }));
      }
    } catch {
      setState(prev => ({
        ...prev,
        isLoading: false,
        error: 'Failed to fetch subscription',
      }));
    }
  }, [userId]);

  useEffect(() => {
    fetchSubscription();
  }, [fetchSubscription]);

  const hasFeature = useCallback(
    (feature: keyof PlanFeatures): boolean => {
      return state.plan.features[feature] ?? false;
    },
    [state.plan]
  );

  const isWithinLimit = useCallback(
    (limit: keyof PlanLimits, current: number): boolean => {
      return current < state.plan.limits[limit];
    },
    [state.plan]
  );

  const canCreateLeague = useCallback(
    (currentCount: number): boolean => {
      return currentCount < state.plan.limits.maxLeagues;
    },
    [state.plan]
  );

  const canAddMember = useCallback(
    (currentCount: number): boolean => {
      return currentCount < state.plan.limits.maxMembersPerLeague;
    },
    [state.plan]
  );

  return {
    ...state,
    hasFeature,
    isWithinLimit,
    canCreateLeague,
    canAddMember,
    isPro: state.tier === 'PRO',
    refresh: fetchSubscription,
  };
}

/**
 * Hook for feature-gated components
 */
export function useFeatureGate(
  feature: keyof PlanFeatures,
  userId?: string
): {
  allowed: boolean;
  isLoading: boolean;
  showUpgrade: () => void;
} {
  const { hasFeature, isLoading, tier } = useSubscription(userId);
  const allowed = hasFeature(feature);

  const showUpgrade = useCallback(() => {
    // Could trigger a modal or redirect to upgrade page
    window.location.href = '/upgrade';
  }, []);

  return {
    allowed,
    isLoading,
    showUpgrade,
  };
}
