import { PrismaClient, Role, LeagueVisibility, LeagueRole, RoundStatus } from '@prisma/client';
import { addDays, addWeeks, setHours, setMinutes } from 'date-fns';

const prisma = new PrismaClient();

// ============================================
// SEED DATA
// ============================================

// Admin user seed
const ADMIN_EMAIL = 'JonatanAriasGonzalez@Gmail.com';

// Track catalog (metadata only - no copyrighted images)
const TRACKS_SEED = [
  {
    name: 'Bahrain International Circuit',
    shortName: 'BHR',
    country: 'Bahrain',
    city: 'Sakhir',
    length: 5.412,
    defaultLaps: 57,
    description: 'Night race in the desert, opened in 2004.',
  },
  {
    name: 'Jeddah Corniche Circuit',
    shortName: 'JED',
    country: 'Saudi Arabia',
    city: 'Jeddah',
    length: 6.174,
    defaultLaps: 50,
    description: 'Ultra-fast street circuit along the Red Sea coast.',
  },
  {
    name: 'Albert Park Circuit',
    shortName: 'AUS',
    country: 'Australia',
    city: 'Melbourne',
    length: 5.278,
    defaultLaps: 58,
    description: 'Street circuit around a lake in the heart of Melbourne.',
  },
  {
    name: 'Suzuka International Racing Course',
    shortName: 'JPN',
    country: 'Japan',
    city: 'Suzuka',
    length: 5.807,
    defaultLaps: 53,
    description: 'Iconic figure-8 circuit known for demanding technical sections.',
  },
  {
    name: 'Circuit de Monaco',
    shortName: 'MON',
    country: 'Monaco',
    city: 'Monte Carlo',
    length: 3.337,
    defaultLaps: 78,
    description: 'The crown jewel of F1, winding through the streets of Monaco.',
  },
  {
    name: 'Silverstone Circuit',
    shortName: 'GBR',
    country: 'United Kingdom',
    city: 'Silverstone',
    length: 5.891,
    defaultLaps: 52,
    description: 'Historic home of British motorsport with high-speed corners.',
  },
  {
    name: 'Circuit de Spa-Francorchamps',
    shortName: 'BEL',
    country: 'Belgium',
    city: 'Stavelot',
    length: 7.004,
    defaultLaps: 44,
    description: 'Legendary track through the Ardennes forest, featuring Eau Rouge.',
  },
  {
    name: 'Autodromo Nazionale Monza',
    shortName: 'ITA',
    country: 'Italy',
    city: 'Monza',
    length: 5.793,
    defaultLaps: 53,
    description: 'Temple of Speed, the fastest track on the calendar.',
  },
  {
    name: 'Circuit of the Americas',
    shortName: 'USA',
    country: 'United States',
    city: 'Austin',
    length: 5.513,
    defaultLaps: 56,
    description: 'Purpose-built F1 venue in Texas with elevation changes.',
  },
  {
    name: 'Yas Marina Circuit',
    shortName: 'ABU',
    country: 'United Arab Emirates',
    city: 'Abu Dhabi',
    length: 5.281,
    defaultLaps: 58,
    description: 'Season finale under the lights at this state-of-the-art facility.',
  },
];

// Default scoring configuration
const DEFAULT_SCORING = {
  racePoints: {
    '1': 25, '2': 18, '3': 15, '4': 12, '5': 10,
    '6': 8, '7': 6, '8': 4, '9': 2, '10': 1,
  },
  sprintPoints: {
    '1': 8, '2': 7, '3': 6, '4': 5, '5': 4,
    '6': 3, '7': 2, '8': 1,
  },
  polePositionPoints: 0,
  fastestLapPoints: 1,
  fastestLapEligibleTop: 10,
  dnfPenalty: 0,
  attendancePenalty: 0,
};

// Official F1 2025 Teams
const TEAMS_SEED = [
  {
    name: 'Oracle Red Bull Racing',
    shortName: 'RBR',
    primaryColor: '#3671C6',
    secondaryColor: '#FFD700',
    country: 'Austria',
  },
  {
    name: 'Scuderia Ferrari',
    shortName: 'FER',
    primaryColor: '#E8002D',
    secondaryColor: '#FFEB3B',
    country: 'Italy',
  },
  {
    name: 'McLaren F1 Team',
    shortName: 'MCL',
    primaryColor: '#FF8000',
    secondaryColor: '#000000',
    country: 'United Kingdom',
  },
  {
    name: 'Mercedes-AMG Petronas F1 Team',
    shortName: 'MER',
    primaryColor: '#27F4D2',
    secondaryColor: '#000000',
    country: 'Germany',
  },
  {
    name: 'Aston Martin Aramco F1 Team',
    shortName: 'AMR',
    primaryColor: '#229971',
    secondaryColor: '#FFFFFF',
    country: 'United Kingdom',
  },
  {
    name: 'BWT Alpine F1 Team',
    shortName: 'ALP',
    primaryColor: '#FF87BC',
    secondaryColor: '#0093CC',
    country: 'France',
  },
  {
    name: 'Williams Racing',
    shortName: 'WIL',
    primaryColor: '#64C4FF',
    secondaryColor: '#FFFFFF',
    country: 'United Kingdom',
  },
  {
    name: 'Visa Cash App RB F1 Team',
    shortName: 'RB',
    primaryColor: '#6692FF',
    secondaryColor: '#FFFFFF',
    country: 'Italy',
  },
  {
    name: 'Stake F1 Team Kick Sauber',
    shortName: 'SAU',
    primaryColor: '#52E252',
    secondaryColor: '#000000',
    country: 'Switzerland',
  },
  {
    name: 'MoneyGram Haas F1 Team',
    shortName: 'HAA',
    primaryColor: '#B6BABD',
    secondaryColor: '#E10600',
    country: 'United States',
  },
];

// Demo drivers seed (example drivers - in real use, users assign their own)
const DRIVERS_SEED = [
  // Red Bull Racing (3 drivers + 1 reserve)
  { teamIndex: 0, fullName: 'Driver Slot 1', shortName: 'DR1', gamertag: 'Driver1_RBR', country: 'TBD', number: 1, isReserve: false },
  { teamIndex: 0, fullName: 'Driver Slot 2', shortName: 'DR2', gamertag: 'Driver2_RBR', country: 'TBD', number: 2, isReserve: false },
  { teamIndex: 0, fullName: 'Reserve Driver RBR', shortName: 'RES', gamertag: 'Reserve_RBR', country: 'TBD', number: 99, isReserve: true },
  // Ferrari (3 drivers + 1 reserve)
  { teamIndex: 1, fullName: 'Driver Slot 1', shortName: 'DR1', gamertag: 'Driver1_FER', country: 'TBD', number: 16, isReserve: false },
  { teamIndex: 1, fullName: 'Driver Slot 2', shortName: 'DR2', gamertag: 'Driver2_FER', country: 'TBD', number: 55, isReserve: false },
  { teamIndex: 1, fullName: 'Reserve Driver FER', shortName: 'RES', gamertag: 'Reserve_FER', country: 'TBD', number: 98, isReserve: true },
  // McLaren
  { teamIndex: 2, fullName: 'Driver Slot 1', shortName: 'DR1', gamertag: 'Driver1_MCL', country: 'TBD', number: 4, isReserve: false },
  { teamIndex: 2, fullName: 'Driver Slot 2', shortName: 'DR2', gamertag: 'Driver2_MCL', country: 'TBD', number: 81, isReserve: false },
  // Mercedes
  { teamIndex: 3, fullName: 'Driver Slot 1', shortName: 'DR1', gamertag: 'Driver1_MER', country: 'TBD', number: 63, isReserve: false },
  { teamIndex: 3, fullName: 'Driver Slot 2', shortName: 'DR2', gamertag: 'Driver2_MER', country: 'TBD', number: 12, isReserve: false },
  // Aston Martin
  { teamIndex: 4, fullName: 'Driver Slot 1', shortName: 'DR1', gamertag: 'Driver1_AMR', country: 'TBD', number: 14, isReserve: false },
  { teamIndex: 4, fullName: 'Driver Slot 2', shortName: 'DR2', gamertag: 'Driver2_AMR', country: 'TBD', number: 18, isReserve: false },
  // Alpine
  { teamIndex: 5, fullName: 'Driver Slot 1', shortName: 'DR1', gamertag: 'Driver1_ALP', country: 'TBD', number: 10, isReserve: false },
  { teamIndex: 5, fullName: 'Driver Slot 2', shortName: 'DR2', gamertag: 'Driver2_ALP', country: 'TBD', number: 31, isReserve: false },
  // Williams
  { teamIndex: 6, fullName: 'Driver Slot 1', shortName: 'DR1', gamertag: 'Driver1_WIL', country: 'TBD', number: 23, isReserve: false },
  { teamIndex: 6, fullName: 'Driver Slot 2', shortName: 'DR2', gamertag: 'Driver2_WIL', country: 'TBD', number: 43, isReserve: false },
  // RB
  { teamIndex: 7, fullName: 'Driver Slot 1', shortName: 'DR1', gamertag: 'Driver1_RB', country: 'TBD', number: 22, isReserve: false },
  { teamIndex: 7, fullName: 'Driver Slot 2', shortName: 'DR2', gamertag: 'Driver2_RB', country: 'TBD', number: 30, isReserve: false },
  // Kick Sauber
  { teamIndex: 8, fullName: 'Driver Slot 1', shortName: 'DR1', gamertag: 'Driver1_SAU', country: 'TBD', number: 27, isReserve: false },
  { teamIndex: 8, fullName: 'Driver Slot 2', shortName: 'DR2', gamertag: 'Driver2_SAU', country: 'TBD', number: 77, isReserve: false },
  // Haas
  { teamIndex: 9, fullName: 'Driver Slot 1', shortName: 'DR1', gamertag: 'Driver1_HAA', country: 'TBD', number: 20, isReserve: false },
  { teamIndex: 9, fullName: 'Driver Slot 2', shortName: 'DR2', gamertag: 'Driver2_HAA', country: 'TBD', number: 87, isReserve: false },
];

// ============================================
// MAIN SEED FUNCTION
// ============================================

async function main() {
  console.log('🏎️  ApexGrid AI - Database Seeding Started\n');

  // 1. Create or update admin user
  console.log('👤 Seeding admin user...');
  const adminUser = await prisma.user.upsert({
    where: { email: ADMIN_EMAIL.toLowerCase() },
    update: {
      role: Role.admin,
      name: 'Jonatan Arias Gonzalez',
    },
    create: {
      email: ADMIN_EMAIL.toLowerCase(),
      name: 'Jonatan Arias Gonzalez',
      role: Role.admin,
      locale: 'en',
      emailVerified: true,
    },
  });
  console.log(`   ✓ Admin user: ${adminUser.email} (ID: ${adminUser.id})`);

  // 2. Seed tracks catalog
  console.log('\n🏁 Seeding tracks catalog...');
  const tracks = [];
  for (const trackData of TRACKS_SEED) {
    const track = await prisma.track.upsert({
      where: { name: trackData.name },
      update: trackData,
      create: trackData,
    });
    tracks.push(track);
    console.log(`   ✓ ${track.name} (${track.shortName})`);
  }

  // 3. Create demo league
  console.log('\n🏆 Creating demo league...');
  const demoLeague = await prisma.league.upsert({
    where: { slug: 'apex-championship-2025' },
    update: {},
    create: {
      slug: 'apex-championship-2025',
      name: 'Apex Championship 2025',
      description: 'Demo F1 2025 league showcasing ApexGrid AI features. Join the competition!',
      visibility: LeagueVisibility.PUBLIC,
      timezone: 'America/Chicago',
      isActive: true,
      scoringConfig: DEFAULT_SCORING,
      rules: `# Apex Championship 2025 Rules

## General Rules
1. Respect all competitors
2. No intentional contact
3. Blue flags must be respected within 3 corners

## Qualifying
- Standard 18-minute qualifying session
- No assistance allowed

## Race
- 100% race distance
- Damage simulation: Full
- Safety car: On

## Penalties
- Jump starts: Drive-through penalty
- Causing a collision: 5-second time penalty
- Ignoring blue flags: 10-second time penalty
`,
      settings: {
        maxMembers: 50,
        registrationOpen: true,
        aiAssistantEnabled: true,
      },
    },
  });
  console.log(`   ✓ League: ${demoLeague.name} (slug: ${demoLeague.slug})`);

  // 4. Add admin as league owner
  console.log('\n👥 Adding admin as league owner...');
  await prisma.membership.upsert({
    where: {
      userId_leagueId: {
        userId: adminUser.id,
        leagueId: demoLeague.id,
      },
    },
    update: { role: LeagueRole.OWNER },
    create: {
      userId: adminUser.id,
      leagueId: demoLeague.id,
      role: LeagueRole.OWNER,
    },
  });
  console.log(`   ✓ ${adminUser.email} is now OWNER of ${demoLeague.name}`);

  // 5. Add league tracks
  console.log('\n🗺️  Linking tracks to league...');
  for (const track of tracks) {
    await prisma.leagueTrack.upsert({
      where: {
        leagueId_trackId: {
          leagueId: demoLeague.id,
          trackId: track.id,
        },
      },
      update: {},
      create: {
        leagueId: demoLeague.id,
        trackId: track.id,
      },
    });
  }
  console.log(`   ✓ Linked ${tracks.length} tracks to league`);

  // 6. Seed teams
  console.log('\n🚗 Seeding teams...');
  const teams = [];
  for (const teamData of TEAMS_SEED) {
    const team = await prisma.team.upsert({
      where: {
        leagueId_name: {
          leagueId: demoLeague.id,
          name: teamData.name,
        },
      },
      update: teamData,
      create: {
        ...teamData,
        leagueId: demoLeague.id,
      },
    });
    teams.push(team);
    console.log(`   ✓ ${team.name} (${team.shortName})`);
  }

  // 7. Seed drivers
  console.log('\n🏎️  Seeding drivers...');
  for (const driverData of DRIVERS_SEED) {
    const team = teams[driverData.teamIndex];
    const { teamIndex, ...driverFields } = driverData;
    
    await prisma.driver.upsert({
      where: {
        id: `${team.id}-${driverData.gamertag}`, // This won't match, so create will be used
      },
      update: {},
      create: {
        ...driverFields,
        teamId: team.id,
      },
    });
    console.log(`   ✓ ${driverData.fullName} (${driverData.gamertag}) - ${team.shortName}${driverData.isReserve ? ' [Reserve]' : ''}`);
  }

  // 8. Create 6-round calendar with mixed sessions
  console.log('\n📅 Creating 6-round calendar...');
  const startDate = new Date('2025-03-15T19:00:00Z');
  const roundConfigs = [
    { trackIndex: 0, hasQuali: true, hasSprint: false, name: 'Bahrain Grand Prix' },
    { trackIndex: 1, hasQuali: true, hasSprint: true, name: 'Saudi Arabian Grand Prix' },
    { trackIndex: 2, hasQuali: true, hasSprint: false, name: 'Australian Grand Prix' },
    { trackIndex: 3, hasQuali: true, hasSprint: true, name: 'Japanese Grand Prix' },
    { trackIndex: 4, hasQuali: true, hasSprint: false, name: 'Monaco Grand Prix' },
    { trackIndex: 5, hasQuali: true, hasSprint: true, name: 'British Grand Prix' },
  ];

  for (let i = 0; i < roundConfigs.length; i++) {
    const config = roundConfigs[i];
    const track = tracks[config.trackIndex];
    const scheduledAt = addWeeks(startDate, i * 2); // Every 2 weeks

    await prisma.round.upsert({
      where: {
        leagueId_roundNumber: {
          leagueId: demoLeague.id,
          roundNumber: i + 1,
        },
      },
      update: {},
      create: {
        leagueId: demoLeague.id,
        trackId: track.id,
        roundNumber: i + 1,
        name: config.name,
        scheduledAt,
        status: RoundStatus.SCHEDULED,
        hasQuali: config.hasQuali,
        hasSprint: config.hasSprint,
        laps: track.defaultLaps,
      },
    });
    console.log(`   ✓ Round ${i + 1}: ${config.name} @ ${track.shortName}${config.hasSprint ? ' [Sprint]' : ''}`);
  }

  // 9. Create scoring configuration
  console.log('\n📊 Creating scoring configuration...');
  await prisma.scoring.upsert({
    where: { leagueId: demoLeague.id },
    update: {},
    create: {
      leagueId: demoLeague.id,
      racePoints: DEFAULT_SCORING.racePoints,
      sprintPoints: DEFAULT_SCORING.sprintPoints,
      polePositionPoints: DEFAULT_SCORING.polePositionPoints,
      fastestLapPoints: DEFAULT_SCORING.fastestLapPoints,
      fastestLapEligibleTop: DEFAULT_SCORING.fastestLapEligibleTop,
      dnfPenalty: DEFAULT_SCORING.dnfPenalty,
      attendancePenalty: DEFAULT_SCORING.attendancePenalty,
    },
  });
  console.log('   ✓ Scoring configuration created');

  // 10. Create initial audit log entry
  console.log('\n📝 Creating initial audit log...');
  await prisma.auditLog.create({
    data: {
      userId: adminUser.id,
      leagueId: demoLeague.id,
      action: 'SEED_DATABASE',
      entityType: 'System',
      metadata: {
        seededAt: new Date().toISOString(),
        version: '1.0.0',
        tracks: tracks.length,
        teams: teams.length,
        drivers: DRIVERS_SEED.length,
        rounds: roundConfigs.length,
      },
    },
  });
  console.log('   ✓ Audit log entry created');

  console.log('\n✅ Database seeding completed successfully!\n');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📊 Summary:');
  console.log(`   • Admin user: ${adminUser.email}`);
  console.log(`   • Tracks: ${tracks.length}`);
  console.log(`   • Demo league: ${demoLeague.name}`);
  console.log(`   • Teams: ${teams.length}`);
  console.log(`   • Drivers: ${DRIVERS_SEED.length}`);
  console.log(`   • Calendar rounds: ${roundConfigs.length}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  console.log('⚠️  IMAGE LICENSING NOTICE:');
  console.log('   This seed does NOT include any copyrighted team/track images.');
  console.log('   League admins can add external image URLs or upload their own.');
  console.log('   Users are responsible for ensuring they have rights to use images.\n');
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
