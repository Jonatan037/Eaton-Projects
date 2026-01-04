import { PrismaClient, UserRole, TierType, LeagueRole, ChampionshipRole, DriverStatus, ChampionshipStatus, CarStyle, CarPerformance, RaceLength, SprintLength, QualyType, RaceStatus, AssistLevel, TractionControlLevel, RacingLineLevel, GearboxType } from '@prisma/client';
import { addDays, addWeeks, setHours, setMinutes, format } from 'date-fns';

const prisma = new PrismaClient();

// ============================================
// SEED DATA DEFINITIONS
// ============================================

// App Owner (You - Jonatan)
const APP_OWNER_EMAIL = 'JonatanAriasGonzalez@Gmail.com';

// ============================================
// TIER DEFINITIONS
// ============================================
const TIER_DEFINITIONS = [
  {
    tier: TierType.FREE,
    name: 'Free Trial',
    description: 'Try ApexGrid AI free for 30 days. 1 league, 1 active championship.',
    maxLeagues: 1,
    maxChampionshipsPerLeague: 1,
    maxAdminsPerLeague: 2,
    hasAIFeatures: false,
    hasAdvancedStats: false,
    hasCustomBranding: false,
    trialDays: 30,
    monthlyPrice: 0,
    yearlyPrice: 0,
  },
  {
    tier: TierType.PRO,
    name: 'Pro',
    description: 'For serious league organizers. 5 leagues, 3 championships each, AI features.',
    maxLeagues: 5,
    maxChampionshipsPerLeague: 3,
    maxAdminsPerLeague: 2,
    hasAIFeatures: true,
    hasAdvancedStats: true,
    hasCustomBranding: false,
    trialDays: 0,
    monthlyPrice: 9.99,
    yearlyPrice: 99.99,
  },
  {
    tier: TierType.UNLIMITED,
    name: 'Unlimited',
    description: 'No limits. Unlimited leagues, championships, full AI, custom branding.',
    maxLeagues: -1, // -1 = unlimited
    maxChampionshipsPerLeague: -1,
    maxAdminsPerLeague: 2,
    hasAIFeatures: true,
    hasAdvancedStats: true,
    hasCustomBranding: true,
    trialDays: 0,
    monthlyPrice: 24.99,
    yearlyPrice: 249.99,
  },
];

// ============================================
// F1 TEAMS (Reference Data for 2025 Season)
// ============================================
const F1_TEAMS = [
  {
    name: 'Red Bull Racing',
    shortName: 'RBR',
    fullName: 'Oracle Red Bull Racing',
    primaryColor: '#3671C6',
    secondaryColor: '#FFD700',
    country: 'Austria',
    displayOrder: 1,
  },
  {
    name: 'Ferrari',
    shortName: 'FER',
    fullName: 'Scuderia Ferrari HP',
    primaryColor: '#E8002D',
    secondaryColor: '#FFEB3B',
    country: 'Italy',
    displayOrder: 2,
  },
  {
    name: 'McLaren',
    shortName: 'MCL',
    fullName: 'McLaren F1 Team',
    primaryColor: '#FF8000',
    secondaryColor: '#000000',
    country: 'United Kingdom',
    displayOrder: 3,
  },
  {
    name: 'Mercedes',
    shortName: 'MER',
    fullName: 'Mercedes-AMG PETRONAS F1 Team',
    primaryColor: '#27F4D2',
    secondaryColor: '#000000',
    country: 'Germany',
    displayOrder: 4,
  },
  {
    name: 'Aston Martin',
    shortName: 'AMR',
    fullName: 'Aston Martin Aramco F1 Team',
    primaryColor: '#229971',
    secondaryColor: '#FFFFFF',
    country: 'United Kingdom',
    displayOrder: 5,
  },
  {
    name: 'Alpine',
    shortName: 'ALP',
    fullName: 'BWT Alpine F1 Team',
    primaryColor: '#FF87BC',
    secondaryColor: '#0093CC',
    country: 'France',
    displayOrder: 6,
  },
  {
    name: 'Williams',
    shortName: 'WIL',
    fullName: 'Williams Racing',
    primaryColor: '#64C4FF',
    secondaryColor: '#FFFFFF',
    country: 'United Kingdom',
    displayOrder: 7,
  },
  {
    name: 'RB',
    shortName: 'RB',
    fullName: 'Visa Cash App RB F1 Team',
    primaryColor: '#6692FF',
    secondaryColor: '#FFFFFF',
    country: 'Italy',
    displayOrder: 8,
  },
  {
    name: 'Kick Sauber',
    shortName: 'SAU',
    fullName: 'Stake F1 Team Kick Sauber',
    primaryColor: '#52E252',
    secondaryColor: '#000000',
    country: 'Switzerland',
    displayOrder: 9,
  },
  {
    name: 'Haas',
    shortName: 'HAA',
    fullName: 'MoneyGram Haas F1 Team',
    primaryColor: '#B6BABD',
    secondaryColor: '#E10600',
    country: 'United States',
    displayOrder: 10,
  },
];

// ============================================
// TRACKS (2025 F1 Calendar)
// ============================================
const TRACKS = [
  {
    name: 'Bahrain International Circuit',
    shortName: 'BAH',
    country: 'Bahrain',
    countryCode: 'BH',
    city: 'Sakhir',
    length: 5.412,
    defaultLaps: 57,
    turns: 15,
    firstGrandPrix: 2004,
    lapRecord: '1:31.447',
    lapRecordHolder: 'Pedro de la Rosa',
    lapRecordYear: 2005,
    miniImageUrl: '/images/tracks/mini/bah.png',
    layoutImageUrl: '/images/tracks/layout/bah.png',
    description: 'Night race in the desert, season opener.',
    timezone: 'Asia/Bahrain',
  },
  {
    name: 'Jeddah Corniche Circuit',
    shortName: 'JED',
    country: 'Saudi Arabia',
    countryCode: 'SA',
    city: 'Jeddah',
    length: 6.174,
    defaultLaps: 50,
    turns: 27,
    firstGrandPrix: 2021,
    lapRecord: '1:30.734',
    lapRecordHolder: 'Lewis Hamilton',
    lapRecordYear: 2021,
    miniImageUrl: '/images/tracks/mini/jed.png',
    layoutImageUrl: '/images/tracks/layout/jed.png',
    description: 'Ultra-fast street circuit along the Red Sea coast.',
    timezone: 'Asia/Riyadh',
  },
  {
    name: 'Albert Park Circuit',
    shortName: 'AUS',
    country: 'Australia',
    countryCode: 'AU',
    city: 'Melbourne',
    length: 5.278,
    defaultLaps: 58,
    turns: 14,
    firstGrandPrix: 1996,
    lapRecord: '1:19.813',
    lapRecordHolder: 'Charles Leclerc',
    lapRecordYear: 2024,
    miniImageUrl: '/images/tracks/mini/aus.png',
    layoutImageUrl: '/images/tracks/layout/aus.png',
    description: 'Street circuit around a lake in Melbourne.',
    timezone: 'Australia/Melbourne',
  },
  {
    name: 'Shanghai International Circuit',
    shortName: 'SHA',
    country: 'China',
    countryCode: 'CN',
    city: 'Shanghai',
    length: 5.451,
    defaultLaps: 56,
    turns: 16,
    firstGrandPrix: 2004,
    lapRecord: '1:32.238',
    lapRecordHolder: 'Michael Schumacher',
    lapRecordYear: 2004,
    miniImageUrl: '/images/tracks/mini/sha.png',
    layoutImageUrl: '/images/tracks/layout/sha.png',
    description: 'Modern circuit with distinctive design.',
    timezone: 'Asia/Shanghai',
  },
  {
    name: 'Suzuka International Racing Course',
    shortName: 'SUZ',
    country: 'Japan',
    countryCode: 'JP',
    city: 'Suzuka',
    length: 5.807,
    defaultLaps: 53,
    turns: 18,
    firstGrandPrix: 1987,
    lapRecord: '1:30.983',
    lapRecordHolder: 'Lewis Hamilton',
    lapRecordYear: 2019,
    miniImageUrl: '/images/tracks/mini/suz.png',
    layoutImageUrl: '/images/tracks/layout/suz.png',
    description: 'Iconic figure-8 circuit with demanding sections.',
    timezone: 'Asia/Tokyo',
  },
  {
    name: 'Miami International Autodrome',
    shortName: 'MIA',
    country: 'United States',
    countryCode: 'US',
    city: 'Miami',
    length: 5.412,
    defaultLaps: 57,
    turns: 19,
    firstGrandPrix: 2022,
    lapRecord: '1:29.708',
    lapRecordHolder: 'Max Verstappen',
    lapRecordYear: 2023,
    miniImageUrl: '/images/tracks/mini/mia.png',
    layoutImageUrl: '/images/tracks/layout/mia.png',
    description: 'Street circuit around Hard Rock Stadium.',
    timezone: 'America/New_York',
  },
  {
    name: 'Autodromo Enzo e Dino Ferrari',
    shortName: 'IMO',
    country: 'Italy',
    countryCode: 'IT',
    city: 'Imola',
    length: 4.909,
    defaultLaps: 63,
    turns: 19,
    firstGrandPrix: 1980,
    lapRecord: '1:15.484',
    lapRecordHolder: 'Lewis Hamilton',
    lapRecordYear: 2020,
    miniImageUrl: '/images/tracks/mini/imo.png',
    layoutImageUrl: '/images/tracks/layout/imo.png',
    description: 'Historic Italian circuit, home of Emilia Romagna GP.',
    timezone: 'Europe/Rome',
  },
  {
    name: 'Circuit de Monaco',
    shortName: 'MON',
    country: 'Monaco',
    countryCode: 'MC',
    city: 'Monte Carlo',
    length: 3.337,
    defaultLaps: 78,
    turns: 19,
    firstGrandPrix: 1950,
    lapRecord: '1:12.909',
    lapRecordHolder: 'Lewis Hamilton',
    lapRecordYear: 2021,
    miniImageUrl: '/images/tracks/mini/mon.png',
    layoutImageUrl: '/images/tracks/layout/mon.png',
    description: 'The crown jewel of F1, streets of Monaco.',
    timezone: 'Europe/Monaco',
  },
  {
    name: 'Circuit de Barcelona-Catalunya',
    shortName: 'BAR',
    country: 'Spain',
    countryCode: 'ES',
    city: 'Barcelona',
    length: 4.657,
    defaultLaps: 66,
    turns: 14,
    firstGrandPrix: 1991,
    lapRecord: '1:16.330',
    lapRecordHolder: 'Max Verstappen',
    lapRecordYear: 2023,
    miniImageUrl: '/images/tracks/mini/bar.png',
    layoutImageUrl: '/images/tracks/layout/bar.png',
    description: 'Popular testing venue, challenging layout.',
    timezone: 'Europe/Madrid',
  },
  {
    name: 'Circuit Gilles-Villeneuve',
    shortName: 'MTL',
    country: 'Canada',
    countryCode: 'CA',
    city: 'Montreal',
    length: 4.361,
    defaultLaps: 70,
    turns: 14,
    firstGrandPrix: 1978,
    lapRecord: '1:13.078',
    lapRecordHolder: 'Valtteri Bottas',
    lapRecordYear: 2019,
    miniImageUrl: '/images/tracks/mini/mtl.png',
    layoutImageUrl: '/images/tracks/layout/mtl.png',
    description: 'High-speed semi-street circuit on an island.',
    timezone: 'America/Toronto',
  },
  {
    name: 'Red Bull Ring',
    shortName: 'RBR',
    country: 'Austria',
    countryCode: 'AT',
    city: 'Spielberg',
    length: 4.318,
    defaultLaps: 71,
    turns: 10,
    firstGrandPrix: 1970,
    lapRecord: '1:05.619',
    lapRecordHolder: 'Carlos Sainz',
    lapRecordYear: 2020,
    miniImageUrl: '/images/tracks/mini/rbr.png',
    layoutImageUrl: '/images/tracks/layout/rbr.png',
    description: 'Short, fast circuit in the Styrian mountains.',
    timezone: 'Europe/Vienna',
  },
  {
    name: 'Silverstone Circuit',
    shortName: 'SIL',
    country: 'United Kingdom',
    countryCode: 'GB',
    city: 'Silverstone',
    length: 5.891,
    defaultLaps: 52,
    turns: 18,
    firstGrandPrix: 1950,
    lapRecord: '1:27.097',
    lapRecordHolder: 'Max Verstappen',
    lapRecordYear: 2020,
    miniImageUrl: '/images/tracks/mini/sil.png',
    layoutImageUrl: '/images/tracks/layout/sil.png',
    description: 'Home of British motorsport, high-speed corners.',
    timezone: 'Europe/London',
  },
  {
    name: 'Hungaroring',
    shortName: 'HUN',
    country: 'Hungary',
    countryCode: 'HU',
    city: 'Budapest',
    length: 4.381,
    defaultLaps: 70,
    turns: 14,
    firstGrandPrix: 1986,
    lapRecord: '1:16.627',
    lapRecordHolder: 'Lewis Hamilton',
    lapRecordYear: 2020,
    miniImageUrl: '/images/tracks/mini/hun.png',
    layoutImageUrl: '/images/tracks/layout/hun.png',
    description: 'Tight, twisty circuit often called "Monaco without walls".',
    timezone: 'Europe/Budapest',
  },
  {
    name: 'Circuit de Spa-Francorchamps',
    shortName: 'SPA',
    country: 'Belgium',
    countryCode: 'BE',
    city: 'Spa',
    length: 7.004,
    defaultLaps: 44,
    turns: 19,
    firstGrandPrix: 1950,
    lapRecord: '1:46.286',
    lapRecordHolder: 'Valtteri Bottas',
    lapRecordYear: 2018,
    miniImageUrl: '/images/tracks/mini/spa.png',
    layoutImageUrl: '/images/tracks/layout/spa.png',
    description: 'Legendary circuit through the Ardennes forest, featuring Eau Rouge.',
    timezone: 'Europe/Brussels',
  },
  {
    name: 'Circuit Zandvoort',
    shortName: 'ZAN',
    country: 'Netherlands',
    countryCode: 'NL',
    city: 'Zandvoort',
    length: 4.259,
    defaultLaps: 72,
    turns: 14,
    firstGrandPrix: 1952,
    lapRecord: '1:11.097',
    lapRecordHolder: 'Lewis Hamilton',
    lapRecordYear: 2021,
    miniImageUrl: '/images/tracks/mini/zan.png',
    layoutImageUrl: '/images/tracks/layout/zan.png',
    description: 'Coastal circuit with banked corners, Dutch GP home.',
    timezone: 'Europe/Amsterdam',
  },
  {
    name: 'Autodromo Nazionale Monza',
    shortName: 'MNZ',
    country: 'Italy',
    countryCode: 'IT',
    city: 'Monza',
    length: 5.793,
    defaultLaps: 53,
    turns: 11,
    firstGrandPrix: 1950,
    lapRecord: '1:21.046',
    lapRecordHolder: 'Rubens Barrichello',
    lapRecordYear: 2004,
    miniImageUrl: '/images/tracks/mini/mnz.png',
    layoutImageUrl: '/images/tracks/layout/mnz.png',
    description: 'Temple of Speed, fastest track on the calendar.',
    timezone: 'Europe/Rome',
  },
  {
    name: 'Baku City Circuit',
    shortName: 'BAK',
    country: 'Azerbaijan',
    countryCode: 'AZ',
    city: 'Baku',
    length: 6.003,
    defaultLaps: 51,
    turns: 20,
    firstGrandPrix: 2016,
    lapRecord: '1:43.009',
    lapRecordHolder: 'Charles Leclerc',
    lapRecordYear: 2019,
    miniImageUrl: '/images/tracks/mini/bak.png',
    layoutImageUrl: '/images/tracks/layout/bak.png',
    description: 'Street circuit through the old city with long straight.',
    timezone: 'Asia/Baku',
  },
  {
    name: 'Marina Bay Street Circuit',
    shortName: 'SIN',
    country: 'Singapore',
    countryCode: 'SG',
    city: 'Singapore',
    length: 4.940,
    defaultLaps: 62,
    turns: 19,
    firstGrandPrix: 2008,
    lapRecord: '1:35.867',
    lapRecordHolder: 'Lewis Hamilton',
    lapRecordYear: 2023,
    miniImageUrl: '/images/tracks/mini/sin.png',
    layoutImageUrl: '/images/tracks/layout/sin.png',
    description: 'Night race around the Marina Bay, demanding.',
    timezone: 'Asia/Singapore',
  },
  {
    name: 'Circuit of the Americas',
    shortName: 'COTA',
    country: 'United States',
    countryCode: 'US',
    city: 'Austin',
    length: 5.513,
    defaultLaps: 56,
    turns: 20,
    firstGrandPrix: 2012,
    lapRecord: '1:36.169',
    lapRecordHolder: 'Charles Leclerc',
    lapRecordYear: 2019,
    miniImageUrl: '/images/tracks/mini/cota.png',
    layoutImageUrl: '/images/tracks/layout/cota.png',
    description: 'Purpose-built F1 venue in Texas with elevation changes.',
    timezone: 'America/Chicago',
  },
  {
    name: 'Autódromo Hermanos Rodríguez',
    shortName: 'MEX',
    country: 'Mexico',
    countryCode: 'MX',
    city: 'Mexico City',
    length: 4.304,
    defaultLaps: 71,
    turns: 17,
    firstGrandPrix: 1963,
    lapRecord: '1:17.774',
    lapRecordHolder: 'Valtteri Bottas',
    lapRecordYear: 2021,
    miniImageUrl: '/images/tracks/mini/mex.png',
    layoutImageUrl: '/images/tracks/layout/mex.png',
    description: 'High altitude circuit with stadium section.',
    timezone: 'America/Mexico_City',
  },
  {
    name: 'Autódromo José Carlos Pace',
    shortName: 'SAO',
    country: 'Brazil',
    countryCode: 'BR',
    city: 'São Paulo',
    length: 4.309,
    defaultLaps: 71,
    turns: 15,
    firstGrandPrix: 1973,
    lapRecord: '1:10.540',
    lapRecordHolder: 'Valtteri Bottas',
    lapRecordYear: 2018,
    miniImageUrl: '/images/tracks/mini/sao.png',
    layoutImageUrl: '/images/tracks/layout/sao.png',
    description: 'Interlagos, one of F1\'s most iconic circuits.',
    timezone: 'America/Sao_Paulo',
  },
  {
    name: 'Las Vegas Strip Circuit',
    shortName: 'LVS',
    country: 'United States',
    countryCode: 'US',
    city: 'Las Vegas',
    length: 6.201,
    defaultLaps: 50,
    turns: 17,
    firstGrandPrix: 2023,
    lapRecord: '1:35.490',
    lapRecordHolder: 'Oscar Piastri',
    lapRecordYear: 2023,
    miniImageUrl: '/images/tracks/mini/lvs.png',
    layoutImageUrl: '/images/tracks/layout/lvs.png',
    description: 'Night race down the famous Las Vegas Strip.',
    timezone: 'America/Los_Angeles',
  },
  {
    name: 'Lusail International Circuit',
    shortName: 'QAT',
    country: 'Qatar',
    countryCode: 'QA',
    city: 'Lusail',
    length: 5.419,
    defaultLaps: 57,
    turns: 16,
    firstGrandPrix: 2021,
    lapRecord: '1:24.319',
    lapRecordHolder: 'Max Verstappen',
    lapRecordYear: 2023,
    miniImageUrl: '/images/tracks/mini/qat.png',
    layoutImageUrl: '/images/tracks/layout/qat.png',
    description: 'Fast flowing circuit under the lights in Qatar.',
    timezone: 'Asia/Qatar',
  },
  {
    name: 'Yas Marina Circuit',
    shortName: 'ABU',
    country: 'United Arab Emirates',
    countryCode: 'AE',
    city: 'Abu Dhabi',
    length: 5.281,
    defaultLaps: 58,
    turns: 16,
    firstGrandPrix: 2009,
    lapRecord: '1:26.103',
    lapRecordHolder: 'Max Verstappen',
    lapRecordYear: 2021,
    miniImageUrl: '/images/tracks/mini/abu.png',
    layoutImageUrl: '/images/tracks/layout/abu.png',
    description: 'Season finale under the lights at this modern facility.',
    timezone: 'Asia/Dubai',
  },
];

// ============================================
// MAIN SEED FUNCTION
// ============================================

async function main() {
  console.log('🏎️  ApexGrid AI - Database Seeding Started\n');
  console.log('=' .repeat(50));

  // ============================================
  // 1. SEED TIER DEFINITIONS
  // ============================================
  console.log('\n📊 Seeding Tier Definitions...');
  for (const tierDef of TIER_DEFINITIONS) {
    const tier = await prisma.tierDefinition.upsert({
      where: { tier: tierDef.tier },
      update: tierDef,
      create: tierDef,
    });
    console.log(`   ✓ ${tier.name} (max ${tier.maxLeagues === -1 ? 'unlimited' : tier.maxLeagues} leagues)`);
  }

  // ============================================
  // 2. SEED F1 TEAMS (Reference Data)
  // ============================================
  console.log('\n🏁 Seeding F1 Teams (Reference)...');
  for (const teamData of F1_TEAMS) {
    const team = await prisma.f1Team.upsert({
      where: { name: teamData.name },
      update: teamData,
      create: teamData,
    });
    console.log(`   ✓ ${team.fullName} (${team.shortName})`);
  }

  // ============================================
  // 3. SEED TRACKS
  // ============================================
  console.log('\n🗺️  Seeding Tracks...');
  const tracks = [];
  for (const trackData of TRACKS) {
    const track = await prisma.track.upsert({
      where: { name: trackData.name },
      update: trackData,
      create: trackData,
    });
    tracks.push(track);
    console.log(`   ✓ ${track.name} (${track.shortName})`);
  }

  // ============================================
  // 4. CREATE APP OWNER USER
  // ============================================
  console.log('\n👤 Creating App Owner User...');
  const appOwner = await prisma.user.upsert({
    where: { email: APP_OWNER_EMAIL.toLowerCase() },
    update: {
      role: UserRole.APP_OWNER,
      tier: TierType.UNLIMITED,
      fullName: 'Jonatan Arias Gonzalez',
    },
    create: {
      email: APP_OWNER_EMAIL.toLowerCase(),
      fullName: 'Jonatan Arias Gonzalez',
      role: UserRole.APP_OWNER,
      tier: TierType.UNLIMITED,
      emailVerified: true,
      locale: 'en',
      timezone: 'America/Chicago',
    },
  });
  console.log(`   ✓ App Owner: ${appOwner.email} (${appOwner.role})`);
  console.log(`   ✓ Tier: ${appOwner.tier}`);

  // ============================================
  // 5. CREATE DEMO LEAGUE
  // ============================================
  console.log('\n🏆 Creating Demo League...');
  const demoLeague = await prisma.league.upsert({
    where: { slug: 'apex-championship-2025' },
    update: {},
    create: {
      slug: 'apex-championship-2025',
      name: 'Apex Championship 2025',
      description: 'Official ApexGrid AI demo league. Experience the full platform features!',
      ownerId: appOwner.id,
      rules: `# Apex Championship 2025 Rules

## General Rules
1. Respect all competitors
2. No intentional contact
3. Blue flags must be respected within 3 corners

## Qualifying
- Standard qualifying session
- All assists allowed per championship settings

## Race
- Race distance as per championship settings
- Damage simulation: Reduced
- Safety car: On

## Penalties
- Jump starts: Drive-through penalty
- Causing a collision: 5-10 second time penalty
- Ignoring blue flags: 10-second time penalty
`,
      instagram: 'https://instagram.com/apexgrid',
      youtube: 'https://youtube.com/@apexgrid',
      twitch: 'https://twitch.tv/apexgrid',
      twitter: 'https://twitter.com/apexgrid',
      discord: 'https://discord.gg/apexgrid',
      isActive: true,
      isPublic: true,
      timezone: 'America/Chicago',
    },
  });
  console.log(`   ✓ League: ${demoLeague.name} (slug: ${demoLeague.slug})`);

  // ============================================
  // 6. ADD OWNER AS LEAGUE MEMBER
  // ============================================
  console.log('\n👥 Adding Owner to League...');
  await prisma.leagueMember.upsert({
    where: {
      leagueId_userId: {
        leagueId: demoLeague.id,
        userId: appOwner.id,
      },
    },
    update: { role: LeagueRole.OWNER },
    create: {
      leagueId: demoLeague.id,
      userId: appOwner.id,
      role: LeagueRole.OWNER,
    },
  });
  console.log(`   ✓ ${appOwner.fullName} is OWNER of ${demoLeague.name}`);

  // ============================================
  // 7. CREATE DEMO CHAMPIONSHIP
  // ============================================
  console.log('\n🏅 Creating Demo Championship...');
  const demoChampionship = await prisma.championship.upsert({
    where: {
      leagueId_name: {
        leagueId: demoLeague.id,
        name: 'Season 1 - 2025',
      },
    },
    update: {},
    create: {
      leagueId: demoLeague.id,
      name: 'Season 1 - 2025',
      description: 'The inaugural Apex Championship season!',
      createdById: appOwner.id,
      carStyle: CarStyle.F1,
      carPerformance: CarPerformance.EQUAL,
      assistsEnabled: true,
      useF1Scoring: true,
      defaultDay: 'Sunday',
      defaultTime: '19:00',
      status: ChampionshipStatus.DRAFT,
      startDate: new Date('2025-03-15'),
      endDate: new Date('2025-12-15'),
    },
  });
  console.log(`   ✓ Championship: ${demoChampionship.name}`);

  // ============================================
  // 8. CREATE CHAMPIONSHIP ASSISTS CONFIG
  // ============================================
  console.log('\n🎮 Setting Championship Assists...');
  await prisma.championshipAssists.upsert({
    where: { championshipId: demoChampionship.id },
    update: {},
    create: {
      championshipId: demoChampionship.id,
      steeringAssist: AssistLevel.OFF,
      brakingAssist: AssistLevel.OFF,
      antiLockBrakes: AssistLevel.OFF,
      tractionControl: TractionControlLevel.MEDIUM,
      racingLine: RacingLineLevel.CORNERS,
      gearbox: GearboxType.MANUAL,
      pitAssist: AssistLevel.OFF,
      pitReleaseAssist: AssistLevel.OFF,
      ersAssist: AssistLevel.OFF,
      drsAssist: AssistLevel.OFF,
    },
  });
  console.log('   ✓ Assists configuration created');

  // ============================================
  // 9. CREATE SCORING SYSTEM
  // ============================================
  console.log('\n📈 Setting Scoring System (F1 Default)...');
  await prisma.scoringSystem.upsert({
    where: { championshipId: demoChampionship.id },
    update: {},
    create: {
      championshipId: demoChampionship.id,
      useF1Default: true,
      // Race points (F1 2024+ format)
      raceP1: 25,
      raceP2: 18,
      raceP3: 15,
      raceP4: 12,
      raceP5: 10,
      raceP6: 8,
      raceP7: 6,
      raceP8: 4,
      raceP9: 2,
      raceP10: 1,
      // Sprint points (F1 2024+ format)
      sprintP1: 8,
      sprintP2: 7,
      sprintP3: 6,
      sprintP4: 5,
      sprintP5: 4,
      sprintP6: 3,
      sprintP7: 2,
      sprintP8: 1,
      // Bonus
      fastestLap: 1,
      fastestLapTopN: 10,
    },
  });
  console.log('   ✓ Scoring system created (F1 Default)');

  // ============================================
  // 10. CREATE CHAMPIONSHIP TEAMS
  // ============================================
  console.log('\n🚗 Creating Championship Teams...');
  const championshipTeams = [];
  for (const f1Team of F1_TEAMS) {
    const team = await prisma.championshipTeam.upsert({
      where: {
        championshipId_name: {
          championshipId: demoChampionship.id,
          name: f1Team.name,
        },
      },
      update: {},
      create: {
        championshipId: demoChampionship.id,
        name: f1Team.name,
        shortName: f1Team.shortName,
        primaryColor: f1Team.primaryColor,
        secondaryColor: f1Team.secondaryColor,
        country: f1Team.country,
        displayOrder: f1Team.displayOrder,
      },
    });
    championshipTeams.push(team);
    console.log(`   ✓ ${team.name} (${team.shortName})`);
  }

  // ============================================
  // 11. ADD TRACKS TO CHAMPIONSHIP
  // ============================================
  console.log('\n📍 Adding Tracks to Championship...');
  let roundNumber = 1;
  for (const track of tracks) {
    await prisma.championshipTrack.upsert({
      where: {
        championshipId_trackId: {
          championshipId: demoChampionship.id,
          trackId: track.id,
        },
      },
      update: { roundNumber },
      create: {
        championshipId: demoChampionship.id,
        trackId: track.id,
        roundNumber,
        customName: `${track.country} Grand Prix`,
      },
    });
    console.log(`   ✓ R${roundNumber}: ${track.name}`);
    roundNumber++;
  }

  // ============================================
  // 12. CREATE RACES FROM CHAMPIONSHIP TRACKS
  // ============================================
  console.log('\n🏁 Creating Race Schedule...');
  const championshipTracks = await prisma.championshipTrack.findMany({
    where: { championshipId: demoChampionship.id },
    include: { track: true },
    orderBy: { roundNumber: 'asc' },
  });

  let raceDate = new Date('2025-03-15');
  for (const ct of championshipTracks) {
    await prisma.race.upsert({
      where: {
        championshipId_roundNumber: {
          championshipId: demoChampionship.id,
          roundNumber: ct.roundNumber,
        },
      },
      update: {},
      create: {
        championshipId: demoChampionship.id,
        championshipTrackId: ct.id,
        trackId: ct.trackId,
        roundNumber: ct.roundNumber,
        name: ct.customName || `${ct.track.country} Grand Prix`,
        scheduledDate: raceDate,
        scheduledTime: '19:00',
        raceLength: RaceLength.MEDIUM_50,
        sprintLength: SprintLength.NONE,
        qualyType: QualyType.FULL,
        status: RaceStatus.SCHEDULED,
      },
    });
    console.log(`   ✓ R${ct.roundNumber}: ${ct.customName} - ${format(raceDate, 'MMM dd, yyyy')}`);
    raceDate = addWeeks(raceDate, 2); // Races every 2 weeks
  }

  // ============================================
  // SUMMARY
  // ============================================
  console.log('\n' + '=' .repeat(50));
  console.log('✅ Database seeding completed successfully!\n');
  console.log('📊 Summary:');
  console.log(`   • ${TIER_DEFINITIONS.length} Tier Definitions`);
  console.log(`   • ${F1_TEAMS.length} F1 Teams (Reference)`);
  console.log(`   • ${tracks.length} Tracks`);
  console.log(`   • 1 Demo League`);
  console.log(`   • 1 Demo Championship`);
  console.log(`   • ${championshipTeams.length} Championship Teams`);
  console.log(`   • ${championshipTracks.length} Scheduled Races`);
  console.log('\n🏎️  Ready to race!\n');
}

// ============================================
// EXECUTE
// ============================================

main()
  .catch((e) => {
    console.error('❌ Seed error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
