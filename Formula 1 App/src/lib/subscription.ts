/**
 * Subscription Plans Configuration
 * Defines feature limits and capabilities for each tier
 */

export type SubscriptionTier = 'FREE' | 'PRO';

export interface PlanLimits {
  maxLeagues: number;
  maxMembersPerLeague: number;
  maxTeamsPerLeague: number;
  maxDriversPerTeam: number;
  maxRoundsPerSeason: number;
}

export interface PlanFeatures {
  aiChat: boolean;
  aiPredictions: boolean;
  advancedAnalytics: boolean;
  dataExport: boolean;
  customBranding: boolean;
  prioritySupport: boolean;
  discordWebhooks: boolean;
  csvImport: boolean;
  embeddings: boolean;
}

export interface Plan {
  id: SubscriptionTier;
  name: string;
  description: string;
  priceMonthly: number; // in cents
  priceYearly: number;  // in cents
  stripePriceIdMonthly?: string;
  stripePriceIdYearly?: string;
  limits: PlanLimits;
  features: PlanFeatures;
}

/**
 * Subscription Plans Definition
 */
export const PLANS: Record<SubscriptionTier, Plan> = {
  FREE: {
    id: 'FREE',
    name: 'Free',
    description: 'Perfect for getting started with a single league',
    priceMonthly: 0,
    priceYearly: 0,
    limits: {
      maxLeagues: 1,
      maxMembersPerLeague: 20,
      maxTeamsPerLeague: 10,
      maxDriversPerTeam: 4,
      maxRoundsPerSeason: 24,
    },
    features: {
      aiChat: false,
      aiPredictions: false,
      advancedAnalytics: false,
      dataExport: false,
      customBranding: false,
      prioritySupport: false,
      discordWebhooks: true,
      csvImport: true,
      embeddings: false,
    },
  },
  PRO: {
    id: 'PRO',
    name: 'Pro',
    description: 'For serious league organizers with AI-powered features',
    priceMonthly: 999, // $9.99
    priceYearly: 9999, // $99.99 (2 months free)
    stripePriceIdMonthly: process.env.STRIPE_PRICE_ID_PRO_MONTHLY,
    stripePriceIdYearly: process.env.STRIPE_PRICE_ID_PRO_YEARLY,
    limits: {
      maxLeagues: 10,
      maxMembersPerLeague: 200,
      maxTeamsPerLeague: 20,
      maxDriversPerTeam: 6,
      maxRoundsPerSeason: 30,
    },
    features: {
      aiChat: true,
      aiPredictions: true,
      advancedAnalytics: true,
      dataExport: true,
      customBranding: true,
      prioritySupport: true,
      discordWebhooks: true,
      csvImport: true,
      embeddings: true,
    },
  },
};

/**
 * Get plan by tier
 */
export function getPlan(tier: SubscriptionTier): Plan {
  return PLANS[tier] || PLANS.FREE;
}

/**
 * Check if a feature is available for a tier
 */
export function hasFeature(
  tier: SubscriptionTier,
  feature: keyof PlanFeatures
): boolean {
  const plan = getPlan(tier);
  return plan.features[feature] ?? false;
}

/**
 * Check if a limit is within bounds for a tier
 */
export function isWithinLimit(
  tier: SubscriptionTier,
  limit: keyof PlanLimits,
  current: number
): boolean {
  const plan = getPlan(tier);
  return current < plan.limits[limit];
}

/**
 * Get remaining capacity for a limit
 */
export function getRemainingCapacity(
  tier: SubscriptionTier,
  limit: keyof PlanLimits,
  current: number
): number {
  const plan = getPlan(tier);
  return Math.max(0, plan.limits[limit] - current);
}

/**
 * Feature flag names for easier reference
 */
export const FEATURE_FLAGS = {
  AI_CHAT: 'aiChat',
  AI_PREDICTIONS: 'aiPredictions',
  ADVANCED_ANALYTICS: 'advancedAnalytics',
  DATA_EXPORT: 'dataExport',
  CUSTOM_BRANDING: 'customBranding',
  PRIORITY_SUPPORT: 'prioritySupport',
  DISCORD_WEBHOOKS: 'discordWebhooks',
  CSV_IMPORT: 'csvImport',
  EMBEDDINGS: 'embeddings',
} as const;

/**
 * Limit names for easier reference
 */
export const LIMIT_FLAGS = {
  MAX_LEAGUES: 'maxLeagues',
  MAX_MEMBERS_PER_LEAGUE: 'maxMembersPerLeague',
  MAX_TEAMS_PER_LEAGUE: 'maxTeamsPerLeague',
  MAX_DRIVERS_PER_TEAM: 'maxDriversPerTeam',
  MAX_ROUNDS_PER_SEASON: 'maxRoundsPerSeason',
} as const;

/**
 * Upgrade prompts for gated features
 */
export const UPGRADE_PROMPTS = {
  aiChat: {
    en: 'AI Chat is a Pro feature. Upgrade to get AI-powered insights about your league!',
    es: '¡El Chat IA es una función Pro! Actualiza para obtener información impulsada por IA sobre tu liga.',
  },
  aiPredictions: {
    en: 'Race predictions require a Pro subscription. Upgrade to unlock AI predictions!',
    es: '¡Las predicciones de carrera requieren una suscripción Pro! Actualiza para desbloquear predicciones IA.',
  },
  advancedAnalytics: {
    en: 'Advanced analytics is a Pro feature. Upgrade to unlock deep insights!',
    es: '¡Los análisis avanzados son una función Pro! Actualiza para desbloquear información detallada.',
  },
  dataExport: {
    en: 'Data export is available on Pro. Upgrade to export your league data!',
    es: '¡La exportación de datos está disponible en Pro! Actualiza para exportar los datos de tu liga.',
  },
  maxLeagues: {
    en: 'You\'ve reached the maximum number of leagues for your plan. Upgrade to Pro for up to 10 leagues!',
    es: '¡Has alcanzado el número máximo de ligas para tu plan! Actualiza a Pro para tener hasta 10 ligas.',
  },
  maxMembers: {
    en: 'This league has reached the member limit. Upgrade to Pro for up to 200 members!',
    es: '¡Esta liga ha alcanzado el límite de miembros! Actualiza a Pro para tener hasta 200 miembros.',
  },
};
