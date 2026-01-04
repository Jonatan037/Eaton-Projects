# ApexGrid AI - Database Architecture v2.0

## Overview

This document describes the complete database architecture for ApexGrid AI, a Formula 1 league management platform. The system supports multiple users with subscription tiers, league creation, championships, team/driver management, race scheduling, and comprehensive scoring systems.

---

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    USER SYSTEM                                           │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│   ┌──────────────┐         ┌──────────────────┐                                         │
│   │     User     │◄───────►│  TierDefinition  │                                         │
│   │──────────────│         │──────────────────│                                         │
│   │ fullName     │         │ tier (FK)        │                                         │
│   │ email        │         │ maxLeagues       │                                         │
│   │ gamertag     │         │ maxChampionships │                                         │
│   │ tier (FK)    │         │ features...      │                                         │
│   │ role         │         └──────────────────┘                                         │
│   └──────────────┘                                                                       │
│          │                                                                               │
│          │ owns (1:N)                                                                    │
│          ▼                                                                               │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                    LEAGUE SYSTEM                                         │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│   ┌──────────────┐         ┌──────────────────┐                                         │
│   │    League    │◄───────►│   LeagueMember   │                                         │
│   │──────────────│         │──────────────────│                                         │
│   │ name         │         │ userId (FK)      │                                         │
│   │ slug         │         │ leagueId (FK)    │                                         │
│   │ ownerId (FK) │         │ role (OWNER/     │                                         │
│   │ socials...   │         │       ADMIN)     │                                         │
│   └──────────────┘         └──────────────────┘                                         │
│          │                                                                               │
│          │ has (1:N)                                                                     │
│          ▼                                                                               │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                 CHAMPIONSHIP SYSTEM                                      │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│   ┌────────────────────────────────────────────────────────────────────────────────┐    │
│   │                              Championship                                       │    │
│   │────────────────────────────────────────────────────────────────────────────────│    │
│   │ name, description, logo                                                         │    │
│   │ leagueId (FK), createdById (FK)                                                │    │
│   │ carStyle (F1/CUSTOM), carPerformance (REAL/EQUAL)                              │    │
│   │ assistsEnabled, useF1Scoring, status (DRAFT/ACTIVE/COMPLETED)                  │    │
│   └────────────────────────────────────────────────────────────────────────────────┘    │
│          │                     │                    │                    │               │
│          │                     │                    │                    │               │
│   ┌──────▼──────┐      ┌──────▼──────┐     ┌──────▼───────┐     ┌──────▼───────┐       │
│   │Championship │      │Championship │     │Championship  │     │   Scoring    │       │
│   │   Member    │      │    Team     │     │   Assists    │     │   System     │       │
│   │─────────────│      │─────────────│     │──────────────│     │──────────────│       │
│   │ userId (FK) │      │ name        │     │ steeringAsst │     │ raceP1-P20   │       │
│   │ role (ADMIN/│      │ shortName   │     │ brakingAsst  │     │ sprintP1-P20 │       │
│   │      DRIVER)│      │ colors      │     │ tractionCtrl │     │ qualyP1-P20  │       │
│   │ driverId    │      │ country     │     │ racingLine   │     │ fastestLap   │       │
│   └─────────────┘      └──────┬──────┘     │ gearbox      │     │ bonuses...   │       │
│                               │            │ pitAssist    │     └──────────────┘       │
│                               │            │ ersAssist    │                            │
│                               ▼            │ drsAssist    │                            │
│                        ┌─────────────┐     └──────────────┘                            │
│                        │Championship │                                                  │
│                        │   Driver    │◄──────────────────────────────────────┐         │
│                        │─────────────│                                        │         │
│                        │ fullName    │                                        │         │
│                        │ gamertag    │                                        │         │
│                        │ teamId (FK) │ (null = reserve)                       │         │
│                        │ userId (FK) │ (link to registered user)              │         │
│                        │ status      │ (RESERVE/ACTIVE/INACTIVE)              │         │
│                        │ number      │                                        │         │
│                        └─────────────┘                                        │         │
│                                                                               │         │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                   TRACK & RACE SYSTEM                                    │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│   ┌──────────────┐         ┌──────────────────┐         ┌──────────────────┐            │
│   │    Track     │◄───────►│ChampionshipTrack │◄───────►│      Race        │            │
│   │──────────────│         │──────────────────│         │──────────────────│            │
│   │ name         │         │ championshipId   │         │ championshipId   │            │
│   │ shortName    │         │ trackId          │         │ trackId          │            │
│   │ country      │         │ roundNumber      │         │ roundNumber      │            │
│   │ length, laps │         │ customName       │         │ scheduledDate    │            │
│   │ images...    │         └──────────────────┘         │ raceLength       │            │
│   └──────────────┘                                      │ sprintLength     │            │
│                                                         │ qualyType        │            │
│                                                         │ status           │            │
│                                                         └─────────┬────────┘            │
│                                                                   │                     │
│                                                                   │ has (1:N)           │
│                                                                   ▼                     │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                    RESULTS SYSTEM                                        │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│   ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐                  │
│   │   RaceResult     │    │   SprintResult   │    │   QualyResult    │                  │
│   │──────────────────│    │──────────────────│    │──────────────────│                  │
│   │ raceId (FK)      │    │ raceId (FK)      │    │ raceId (FK)      │                  │
│   │ driverId (FK)    │    │ driverId (FK)    │    │ driverId (FK)    │                  │
│   │ teamId (FK)      │    │ teamId (FK)      │    │ teamId (FK)      │                  │
│   │ position         │    │ position         │    │ position         │                  │
│   │ status           │    │ status           │    │ q1/q2/q3 times   │                  │
│   │ points           │    │ points           │    │ isPole           │                  │
│   │ fastestLap       │    │ gapToLeader      │    │ points           │                  │
│   │ driverOfTheDay   │    └──────────────────┘    └──────────────────┘                  │
│   └──────────────────┘                                                                   │
│                                                                                          │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## User Roles & Permissions

### System Roles (UserRole)

| Role | Description | Capabilities |
|------|-------------|--------------|
| `APP_OWNER` | Platform owner (Jonatan) | Full access to everything, bypass all tier limits |
| `USER` | Regular registered user | Access based on tier subscription |

### League Roles (LeagueRole)

| Role | Description | Capabilities |
|------|-------------|--------------|
| `OWNER` | League creator | Full control: edit/delete league, manage admins, create championships |
| `ADMIN` | League administrator | Manage league settings, create/edit championships, manage members |

### Championship Roles (ChampionshipRole)

| Role | Description | Capabilities |
|------|-------------|--------------|
| `ADMIN` | Championship administrator | Edit championship settings, manage teams/drivers, enter results |
| `DRIVER` | Championship participant | View-only access to championship details |

---

## Subscription Tiers

| Tier | Max Leagues | Championships/League | Trial | Features |
|------|-------------|---------------------|-------|----------|
| `FREE` | 1 | 1 | 30 days | Basic features |
| `PRO` | 5 | 3 | - | AI features, advanced stats |
| `UNLIMITED` | ∞ | ∞ | - | All features + custom branding |

### Tier Limits Enforcement

```typescript
// Example: Check if user can create a league
async function canCreateLeague(userId: string): Promise<boolean> {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  const tierDef = await prisma.tierDefinition.findUnique({ where: { tier: user.tier } });
  
  // APP_OWNER bypasses all limits
  if (user.role === 'APP_OWNER') return true;
  
  // Check FREE tier expiration
  if (user.tier === 'FREE' && user.tierExpiresAt && user.tierExpiresAt < new Date()) {
    return false; // Trial expired
  }
  
  // Count existing leagues
  const leagueCount = await prisma.league.count({ where: { ownerId: userId } });
  
  // -1 means unlimited
  return tierDef.maxLeagues === -1 || leagueCount < tierDef.maxLeagues;
}
```

---

## Championship Configuration

### Teams Configuration

Teams are created per-championship, copied from F1 reference data:

```
Championship
    └── ChampionshipTeam (10 teams)
            └── ChampionshipDriver (20 drivers + reserves)
                    ├── status: RESERVE (unassigned)
                    ├── status: ACTIVE (assigned to team)
                    └── status: INACTIVE (left championship)
```

**Rules:**
- Each team can have **maximum 2 active drivers**
- All other drivers are **reserve drivers** (teamId = null)
- Drivers must be registered users (linked via userId)

### Race Configuration

Each race has individual settings:

| Setting | Options | Default |
|---------|---------|---------|
| Race Length | SHORT_25, MEDIUM_50, FULL_100 | MEDIUM_50 |
| Sprint Length | NONE, SHORT_25, MEDIUM_50, FULL_100 | NONE |
| Qualifying | NONE, REVERSE_GRID, ONE_SHOT, SHORT, FULL | FULL |

### Assists Configuration

Each championship has one `ChampionshipAssists` record:

| Assist | Options |
|--------|---------|
| Steering Assist | ON / OFF |
| Braking Assist | ON / OFF |
| Anti-Lock Brakes | ON / OFF |
| Traction Control | FULL / MEDIUM / OFF |
| Racing Line | FULL / CORNERS / OFF |
| Gearbox | AUTOMATIC / MANUAL |
| Pit Assist | ON / OFF |
| Pit Release Assist | ON / OFF |
| ERS Assist | ON / OFF |
| DRS Assist | ON / OFF |

### Scoring System

Each championship has one `ScoringSystem` record:

**Race Points (Default F1):**
| P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 |
|----|----|----|----|----|----|----|----|----|-----|
| 25 | 18 | 15 | 12 | 10 | 8  | 6  | 4  | 2  | 1   |

**Sprint Points:**
| P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 |
|----|----|----|----|----|----|----|-----|
| 8  | 7  | 6  | 5  | 4  | 3  | 2  | 1   |

**Qualifying Points:** All 0 by default (can be customized)

**Bonus Points:**
| Bonus | Default | Description |
|-------|---------|-------------|
| Fastest Lap | 1 | Must be in top 10 to receive |
| Finish Race | 0 | Points for completing |
| No Penalty | 0 | Clean race bonus |
| Driver of the Day | 0 | Community vote |
| Pole Position | 0 | Qualifying P1 |

---

## Database Tables Summary

| Table | Purpose |
|-------|---------|
| `users` | Registered users with profiles and tiers |
| `tier_definitions` | Tier limits and features |
| `leagues` | League information and settings |
| `league_members` | User-League relationships (Owner/Admin) |
| `championships` | Championships within leagues |
| `championship_members` | User-Championship relationships (Admin/Driver) |
| `championship_teams` | Teams per championship |
| `championship_drivers` | Drivers per championship |
| `tracks` | Master track catalog |
| `championship_tracks` | Selected tracks per championship |
| `races` | Individual race configuration |
| `championship_assists` | Assists settings per championship |
| `scoring_systems` | Scoring configuration per championship |
| `race_results` | Race finishing positions |
| `sprint_results` | Sprint race results |
| `qualy_results` | Qualifying results |
| `standings_snapshots` | Cached standings data |
| `f1_teams` | Reference F1 team data |
| `audit_logs` | Activity tracking |
| `league_embeddings` | AI vector embeddings (future) |

---

## API Flow Examples

### Creating a Championship

```typescript
// 1. Verify user can create championship (tier limits)
// 2. Create championship record
// 3. Create ChampionshipAssists (default or custom)
// 4. Create ScoringSystem (F1 default or custom)
// 5. Copy F1 teams to ChampionshipTeams
// 6. Add ChampionshipMember for creator as ADMIN
```

### Adding a Driver to Championship

```typescript
// 1. Find or create User record for driver
// 2. Create ChampionshipDriver (status: RESERVE, teamId: null)
// 3. Create ChampionshipMember with role: DRIVER
// 4. Driver is now in "driver pool" ready to be assigned
```

### Assigning Driver to Team

```typescript
// 1. Verify team has < 2 active drivers
// 2. Update ChampionshipDriver.teamId = team.id
// 3. Update ChampionshipDriver.status = ACTIVE
```

### Recording Race Results

```typescript
// 1. For each driver in race, create RaceResult
// 2. Calculate points based on ScoringSystem
// 3. Update StandingsSnapshot
```

---

## Migration Notes

### From v1.0 to v2.0

Major changes:
1. `League` no longer has direct teams/drivers (moved to Championship)
2. `Round` replaced by `Race` with more configuration options
3. `Result` split into `RaceResult`, `SprintResult`, `QualyResult`
4. New `ChampionshipAssists` and `ScoringSystem` tables
5. `Membership` replaced by `LeagueMember` and `ChampionshipMember`
6. User model expanded with full profile and tier system

### Running Migrations

```bash
# Reset database and apply new schema (DEVELOPMENT ONLY)
npx prisma migrate reset

# Or generate migration from schema changes
npx prisma migrate dev --name "v2_complete_architecture"

# Then seed the database
npx prisma db seed
```

---

## Future Considerations

1. **Multi-Season Support**: Championships can have multiple seasons
2. **Incident Reporting**: Steward reports and penalties
3. **AI Features**: Chatbot, predictive analytics
4. **Notifications**: Discord/email integration
5. **Live Timing**: Real-time race tracking
6. **Fantasy League**: Points predictions
