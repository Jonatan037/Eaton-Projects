// Shared Zod Schemas for ApexGrid AI
// Used on both client and server for validation

import { z } from 'zod';

// ============================================
// ENUMS
// ============================================

export const RoleSchema = z.enum(['admin', 'league_admin', 'member', 'viewer']);
export const LeagueVisibilitySchema = z.enum(['PUBLIC', 'PRIVATE']);
export const LeagueRoleSchema = z.enum(['OWNER', 'ADMIN', 'MEMBER', 'VIEWER']);
export const RoundStatusSchema = z.enum(['SCHEDULED', 'COMPLETED', 'ANNULLED']);
export const ResultStatusSchema = z.enum(['FINISHED', 'DNF', 'DNS', 'DSQ']);
export const SessionTypeSchema = z.enum(['QUALIFYING', 'SPRINT', 'RACE']);

export type Role = z.infer<typeof RoleSchema>;
export type LeagueVisibility = z.infer<typeof LeagueVisibilitySchema>;
export type LeagueRole = z.infer<typeof LeagueRoleSchema>;
export type RoundStatus = z.infer<typeof RoundStatusSchema>;
export type ResultStatus = z.infer<typeof ResultStatusSchema>;
export type SessionType = z.infer<typeof SessionTypeSchema>;

// ============================================
// USER SCHEMAS
// ============================================

export const UserCreateSchema = z.object({
  email: z.string().email('Invalid email address'),
  name: z.string().min(2, 'Name must be at least 2 characters').max(100).optional(),
  gamertag: z.string().min(2).max(50).optional(),
  country: z.string().max(100).optional(),
  bio: z.string().max(500).optional(),
  locale: z.enum(['en', 'es']).default('en'),
});

export const UserUpdateSchema = UserCreateSchema.partial().extend({
  avatar: z.string().url().optional().nullable(),
});

// ============================================
// LEAGUE SCHEMAS
// ============================================

export const LeagueCreateSchema = z.object({
  name: z.string().min(3, 'Name must be at least 3 characters').max(100),
  slug: z.string().min(3, 'Slug must be at least 3 characters').max(100).regex(/^[a-z0-9-]+$/, 'Slug must contain only lowercase letters, numbers, and hyphens'),
  description: z.string().max(1000).optional(),
  visibility: LeagueVisibilitySchema.default('PUBLIC'),
  timezone: z.string().default('America/Chicago'),
  logo: z.string().url().optional().nullable(),
  rules: z.string().max(10000).optional(),
});

export const LeagueUpdateSchema = LeagueCreateSchema.partial();

export const LeagueSettingsSchema = z.object({
  maxMembers: z.number().int().positive().max(500).default(50),
  registrationOpen: z.boolean().default(true),
  aiAssistantEnabled: z.boolean().default(true),
  customColors: z.object({
    primary: z.string().regex(/^#[0-9A-Fa-f]{6}$/).optional(),
    secondary: z.string().regex(/^#[0-9A-Fa-f]{6}$/).optional(),
  }).optional(),
});

// ============================================
// TEAM SCHEMAS
// ============================================

export const TeamCreateSchema = z.object({
  name: z.string().min(2).max(100),
  shortName: z.string().min(2).max(5).optional(),
  logo: z.string().url().optional().nullable(),
  primaryColor: z.string().regex(/^#[0-9A-Fa-f]{6}$/).optional(),
  secondaryColor: z.string().regex(/^#[0-9A-Fa-f]{6}$/).optional(),
  country: z.string().max(100).optional(),
});

export const TeamUpdateSchema = TeamCreateSchema.partial();

// ============================================
// DRIVER SCHEMAS
// ============================================

export const DriverCreateSchema = z.object({
  fullName: z.string().min(2).max(100),
  shortName: z.string().min(2).max(3).optional(),
  gamertag: z.string().min(2).max(50),
  avatar: z.string().url().optional().nullable(),
  country: z.string().max(100).optional(),
  bio: z.string().max(500).optional(),
  number: z.number().int().min(0).max(99).optional(),
  isReserve: z.boolean().default(false),
  teamId: z.string().uuid(),
  userId: z.string().uuid().optional().nullable(),
});

export const DriverUpdateSchema = DriverCreateSchema.partial();

// ============================================
// TRACK SCHEMAS
// ============================================

export const TrackCreateSchema = z.object({
  name: z.string().min(3).max(200),
  shortName: z.string().min(2).max(5).optional(),
  country: z.string().max(100),
  city: z.string().max(100).optional(),
  length: z.number().positive(),
  defaultLaps: z.number().int().positive(),
  imageUrl: z.string().url().optional().nullable(),
  layoutUrl: z.string().url().optional().nullable(),
  description: z.string().max(1000).optional(),
});

export const TrackUpdateSchema = TrackCreateSchema.partial();

// ============================================
// ROUND SCHEMAS
// ============================================

export const RoundCreateSchema = z.object({
  trackId: z.string().uuid(),
  roundNumber: z.number().int().positive(),
  name: z.string().max(200).optional(),
  scheduledAt: z.coerce.date(),
  hasQuali: z.boolean().default(true),
  hasSprint: z.boolean().default(false),
  laps: z.number().int().positive().optional(),
  notes: z.string().max(1000).optional(),
});

export const RoundUpdateSchema = RoundCreateSchema.partial().extend({
  status: RoundStatusSchema.optional(),
});

// ============================================
// SCORING SCHEMAS
// ============================================

export const PointsMapSchema = z.record(z.string(), z.number());

export const ScoringConfigSchema = z.object({
  racePoints: PointsMapSchema.default({
    '1': 25, '2': 18, '3': 15, '4': 12, '5': 10,
    '6': 8, '7': 6, '8': 4, '9': 2, '10': 1,
  }),
  sprintPoints: PointsMapSchema.default({
    '1': 8, '2': 7, '3': 6, '4': 5, '5': 4,
    '6': 3, '7': 2, '8': 1,
  }),
  polePositionPoints: z.number().int().min(0).default(0),
  fastestLapPoints: z.number().int().min(0).default(1),
  fastestLapEligibleTop: z.number().int().min(1).max(30).default(10),
  dnfPenalty: z.number().int().min(-50).max(0).default(0),
  attendancePenalty: z.number().int().min(-50).max(0).default(0),
});

// ============================================
// RESULT SCHEMAS
// ============================================

export const ResultCreateSchema = z.object({
  roundId: z.string().uuid(),
  driverId: z.string().uuid(),
  teamId: z.string().uuid(),
  sessionType: SessionTypeSchema,
  position: z.number().int().positive().optional().nullable(),
  status: ResultStatusSchema.default('FINISHED'),
  points: z.number().default(0),
  fastestLap: z.boolean().default(false),
  pole: z.boolean().default(false),
  gridPosition: z.number().int().positive().optional(),
  gapToLeader: z.string().max(20).optional(),
  notes: z.string().max(500).optional(),
});

export const ResultUpdateSchema = ResultCreateSchema.partial();

// ============================================
// CSV IMPORT SCHEMAS
// ============================================

export const CSVResultRowSchema = z.object({
  roundIndex: z.coerce.number().int().positive(),
  sessionType: SessionTypeSchema,
  driverFullName: z.string().min(1),
  gamertag: z.string().min(1),
  teamName: z.string().min(1),
  position: z.coerce.number().int().positive().optional().nullable(),
  status: ResultStatusSchema.default('FINISHED'),
  points: z.coerce.number().default(0),
  fastestLap: z.preprocess(
    (val) => val === 'true' || val === '1' || val === true,
    z.boolean().default(false)
  ),
  pole: z.preprocess(
    (val) => val === 'true' || val === '1' || val === true,
    z.boolean().default(false)
  ),
  notes: z.string().optional(),
});

export const CSVImportSchema = z.array(CSVResultRowSchema);

// ============================================
// DISCORD WEBHOOK SCHEMAS
// ============================================

export const DiscordWebhookSchema = z.object({
  webhookUrl: z.string().url().startsWith('https://discord.com/api/webhooks/'),
  notifyRaces: z.boolean().default(false),
  notifyResults: z.boolean().default(false),
});

// ============================================
// SEARCH & FILTER SCHEMAS
// ============================================

export const LeagueSearchSchema = z.object({
  query: z.string().optional(),
  visibility: LeagueVisibilitySchema.optional(),
  timezone: z.string().optional(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(50).default(10),
});

// ============================================
// AUTH SCHEMAS
// ============================================

export const LoginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters').optional(),
});

export const RegisterSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  name: z.string().min(2).max(100),
  locale: z.enum(['en', 'es']).default('en'),
});

export const MagicLinkSchema = z.object({
  email: z.string().email('Invalid email address'),
});

// ============================================
// AI CHAT SCHEMAS
// ============================================

export const AIChatMessageSchema = z.object({
  role: z.enum(['user', 'assistant', 'system']),
  content: z.string().min(1).max(10000),
});

export const AIChatRequestSchema = z.object({
  leagueId: z.string().uuid(),
  messages: z.array(AIChatMessageSchema).min(1),
  locale: z.enum(['en', 'es']).default('en'),
});
