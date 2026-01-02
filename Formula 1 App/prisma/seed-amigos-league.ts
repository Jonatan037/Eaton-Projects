import { PrismaClient, LeagueVisibility, LeagueRole, RoundStatus, SessionType, ResultStatus } from '@prisma/client';
import { addWeeks } from 'date-fns';

const prisma = new PrismaClient();

// ============================================
// AMIGOS DE AMERICA 2025 - 1 LEAGUE SEED
// ============================================

const ADMIN_EMAIL = 'JonatanAriasGonzalez@Gmail.com';

// Full 2025 F1 Calendar (24 races)
const FULL_CALENDAR = [
  { name: 'Bahrain Grand Prix', country: 'Bahrain', city: 'Sakhir', hasSprint: false },
  { name: 'Saudi Arabian Grand Prix', country: 'Saudi Arabia', city: 'Jeddah', hasSprint: false },
  { name: 'Australian Grand Prix', country: 'Australia', city: 'Melbourne', hasSprint: true },
  { name: 'Japanese Grand Prix', country: 'Japan', city: 'Suzuka', hasSprint: false },
  { name: 'Chinese Grand Prix', country: 'China', city: 'Shanghai', hasSprint: true },
  { name: 'Miami Grand Prix', country: 'United States', city: 'Miami', hasSprint: true },
  { name: 'Emilia Romagna Grand Prix', country: 'Italy', city: 'Imola', hasSprint: false },
  { name: 'Monaco Grand Prix', country: 'Monaco', city: 'Monte Carlo', hasSprint: false },
  { name: 'Canadian Grand Prix', country: 'Canada', city: 'Montreal', hasSprint: false },
  { name: 'Spanish Grand Prix', country: 'Spain', city: 'Barcelona', hasSprint: false },
  { name: 'Austrian Grand Prix', country: 'Austria', city: 'Spielberg', hasSprint: true },
  { name: 'British Grand Prix', country: 'United Kingdom', city: 'Silverstone', hasSprint: false },
  { name: 'Hungarian Grand Prix', country: 'Hungary', city: 'Budapest', hasSprint: false },
  { name: 'Belgian Grand Prix', country: 'Belgium', city: 'Spa', hasSprint: false },
  { name: 'Dutch Grand Prix', country: 'Netherlands', city: 'Zandvoort', hasSprint: false },
  { name: 'Italian Grand Prix', country: 'Italy', city: 'Monza', hasSprint: false },
  { name: 'Azerbaijan Grand Prix', country: 'Azerbaijan', city: 'Baku', hasSprint: true },
  { name: 'Singapore Grand Prix', country: 'Singapore', city: 'Singapore', hasSprint: false },
  { name: 'United States Grand Prix', country: 'United States', city: 'Austin', hasSprint: true },
  { name: 'Mexico City Grand Prix', country: 'Mexico', city: 'Mexico City', hasSprint: false },
  { name: 'São Paulo Grand Prix', country: 'Brazil', city: 'São Paulo', hasSprint: false },
  { name: 'Las Vegas Grand Prix', country: 'United States', city: 'Las Vegas', hasSprint: false },
  { name: 'Qatar Grand Prix', country: 'Qatar', city: 'Lusail', hasSprint: false },
  { name: 'Abu Dhabi Grand Prix', country: 'United Arab Emirates', city: 'Abu Dhabi', hasSprint: false },
];

// Teams with realistic names for "Amigos de America" league
const TEAMS_DATA = [
  { name: 'Red Bull Racing', shortName: 'RBR', primaryColor: '#3671C6', secondaryColor: '#FFD700', country: 'Austria' },
  { name: 'Scuderia Ferrari', shortName: 'FER', primaryColor: '#E8002D', secondaryColor: '#FFEB3B', country: 'Italy' },
  { name: 'McLaren F1 Team', shortName: 'MCL', primaryColor: '#FF8000', secondaryColor: '#000000', country: 'United Kingdom' },
  { name: 'Mercedes-AMG', shortName: 'MER', primaryColor: '#27F4D2', secondaryColor: '#000000', country: 'Germany' },
  { name: 'Aston Martin', shortName: 'AMR', primaryColor: '#229971', secondaryColor: '#FFFFFF', country: 'United Kingdom' },
  { name: 'Alpine F1', shortName: 'ALP', primaryColor: '#FF87BC', secondaryColor: '#0093CC', country: 'France' },
  { name: 'Williams Racing', shortName: 'WIL', primaryColor: '#64C4FF', secondaryColor: '#FFFFFF', country: 'United Kingdom' },
  { name: 'RB F1 Team', shortName: 'RB', primaryColor: '#6692FF', secondaryColor: '#FFFFFF', country: 'Italy' },
  { name: 'Kick Sauber', shortName: 'SAU', primaryColor: '#52E252', secondaryColor: '#000000', country: 'Switzerland' },
  { name: 'Haas F1 Team', shortName: 'HAA', primaryColor: '#B6BABD', secondaryColor: '#E10600', country: 'United States' },
];

// Drivers with realistic gamertags for a Latin American league
const DRIVERS_DATA = [
  // Red Bull Racing
  { teamIndex: 0, fullName: 'Carlos "El Rayo" Mendez', shortName: 'MEN', gamertag: 'ElRayo_GT', country: 'Mexico', number: 1 },
  { teamIndex: 0, fullName: 'Diego Fernandez', shortName: 'FER', gamertag: 'DiegoF_Racing', country: 'Argentina', number: 2 },
  // Ferrari  
  { teamIndex: 1, fullName: 'Alejandro Santos', shortName: 'SAN', gamertag: 'AlejoSantos77', country: 'Colombia', number: 16 },
  { teamIndex: 1, fullName: 'Roberto "Turbo" Gomez', shortName: 'GOM', gamertag: 'TurboRoberto', country: 'Chile', number: 55 },
  // McLaren
  { teamIndex: 2, fullName: 'Sebastian Rojas', shortName: 'ROJ', gamertag: 'SebastianR_MCL', country: 'Peru', number: 4 },
  { teamIndex: 2, fullName: 'Luis Martinez', shortName: 'MAR', gamertag: 'LuisMartinez04', country: 'Venezuela', number: 81 },
  // Mercedes
  { teamIndex: 3, fullName: 'Jorge "La Bestia" Ruiz', shortName: 'RUI', gamertag: 'LaBestiaJorge', country: 'Ecuador', number: 63 },
  { teamIndex: 3, fullName: 'Andres Herrera', shortName: 'HER', gamertag: 'AndresH_MER', country: 'Uruguay', number: 12 },
  // Aston Martin
  { teamIndex: 4, fullName: 'Pablo Castillo', shortName: 'CAS', gamertag: 'PabloCastillo14', country: 'Costa Rica', number: 14 },
  { teamIndex: 4, fullName: 'Miguel Angel Torres', shortName: 'TOR', gamertag: 'MiguelTorres_AM', country: 'Panama', number: 18 },
  // Alpine
  { teamIndex: 5, fullName: 'Fernando Vega', shortName: 'VEG', gamertag: 'FernandoVega10', country: 'Dominican Republic', number: 10 },
  { teamIndex: 5, fullName: 'Ricardo Flores', shortName: 'FLO', gamertag: 'RicardoF_ALP', country: 'Guatemala', number: 31 },
  // Williams
  { teamIndex: 6, fullName: 'Oscar Ramirez', shortName: 'RAM', gamertag: 'OscarRamirez23', country: 'Honduras', number: 23 },
  { teamIndex: 6, fullName: 'Cesar Diaz', shortName: 'DIA', gamertag: 'CesarDiaz_WIL', country: 'El Salvador', number: 43 },
  // RB
  { teamIndex: 7, fullName: 'Adrian Lopez', shortName: 'LOP', gamertag: 'AdrianLopez22', country: 'Nicaragua', number: 22 },
  { teamIndex: 7, fullName: 'Victor Reyes', shortName: 'REY', gamertag: 'VictorReyes_RB', country: 'Bolivia', number: 30 },
  // Kick Sauber
  { teamIndex: 8, fullName: 'Daniel Moreno', shortName: 'MOR', gamertag: 'DanielMoreno27', country: 'Paraguay', number: 27 },
  { teamIndex: 8, fullName: 'Emilio Vargas', shortName: 'VAR', gamertag: 'EmilioV_SAU', country: 'Cuba', number: 77 },
  // Haas
  { teamIndex: 9, fullName: 'Rodrigo Jimenez', shortName: 'JIM', gamertag: 'RodrigoJ_HAA', country: 'Puerto Rico', number: 20 },
  { teamIndex: 9, fullName: 'Mateo Gonzalez', shortName: 'GON', gamertag: 'MateoG_Racing', country: 'Brazil', number: 87 },
];

// Scoring configuration
const SCORING_CONFIG = {
  racePoints: { '1': 25, '2': 18, '3': 15, '4': 12, '5': 10, '6': 8, '7': 6, '8': 4, '9': 2, '10': 1 },
  sprintPoints: { '1': 8, '2': 7, '3': 6, '4': 5, '5': 4, '6': 3, '7': 2, '8': 1 },
  polePositionPoints: 1,
  fastestLapPoints: 1,
  fastestLapEligibleTop: 10,
  dnfPenalty: 0,
  attendancePenalty: 0,
};

// Simulate race results - creates realistic but random results
function simulateRaceResults(drivers: { id: string; teamId: string }[]): {
  results: { driverId: string; teamId: string; position: number; gap: string; fastestLap: boolean; pole: boolean; status: ResultStatus }[];
} {
  // Shuffle drivers with some consistency (better drivers tend to finish higher)
  const shuffled = [...drivers];
  
  // Add some randomness but weight towards front for top teams
  for (let i = shuffled.length - 1; i > 0; i--) {
    const swapProbability = i < 6 ? 0.3 : 0.7;
    if (Math.random() < swapProbability) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
  }
  
  // Determine DNFs (0-3 per race)
  const dnfCount = Math.floor(Math.random() * 4);
  const dnfPositions = new Set<number>();
  for (let i = 0; i < dnfCount; i++) {
    dnfPositions.add(Math.floor(Math.random() * 20));
  }
  
  // Fastest lap goes to someone in top 10
  const fastestLapPosition = Math.floor(Math.random() * 10);
  
  // Pole position (usually winner or top 5)
  const poleIndex = Math.floor(Math.random() * 5);
  
  const gaps = ['+0.5s', '+1.2s', '+3.4s', '+5.8s', '+8.2s', '+12.5s', '+18.3s', '+25.6s', '+32.1s', '+45.8s', '+52.3s', '+58.7s', '+1:05.2', '+1:12.5', '+1:18.9', '+1:25.3', '+1:32.7', '+1:38.4', '+1 Lap'];
  
  const results = shuffled.map((driver, idx) => {
    const isDNF = dnfPositions.has(idx);
    
    return {
      driverId: driver.id,
      teamId: driver.teamId,
      position: idx + 1,
      gap: idx === 0 ? 'WINNER' : (isDNF ? 'DNF' : gaps[Math.min(idx - 1, gaps.length - 1)]),
      fastestLap: idx === fastestLapPosition,
      pole: idx === poleIndex,
      status: isDNF ? ResultStatus.DNF : ResultStatus.FINISHED,
    };
  });
  
  return { results };
}

// Simulate sprint results (8 positions score)
function simulateSprintResults(drivers: { id: string; teamId: string }[]): { driverId: string; teamId: string; position: number; gap: string; status: ResultStatus }[] {
  const shuffled = [...drivers];
  
  // Shuffle with slight bias towards front runners
  for (let i = shuffled.length - 1; i > 0; i--) {
    const swapProbability = i < 8 ? 0.25 : 0.65;
    if (Math.random() < swapProbability) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
  }
  
  const gaps = ['+0.3s', '+0.8s', '+1.5s', '+2.2s', '+3.1s', '+4.5s', '+5.8s', '+7.2s', '+9.1s', '+11.5s', '+13.2s', '+15.8s', '+18.3s', '+21.5s', '+24.2s', '+27.8s', '+31.5s', '+35.2s', '+38.9s'];
  
  return shuffled.map((driver, idx) => ({
    driverId: driver.id,
    teamId: driver.teamId,
    position: idx + 1,
    gap: idx === 0 ? 'WINNER' : gaps[Math.min(idx - 1, gaps.length - 1)],
    status: ResultStatus.FINISHED,
  }));
}

// Calculate points from results
function calculatePoints(position: number, isRace: boolean, hasFastestLap: boolean, hasPole: boolean, status: ResultStatus): number {
  if (status !== ResultStatus.FINISHED) return 0;
  
  const pointsTable = isRace ? SCORING_CONFIG.racePoints : SCORING_CONFIG.sprintPoints;
  const posKey = position.toString() as keyof typeof pointsTable;
  let points = pointsTable[posKey] || 0;
  
  if (isRace) {
    if (hasFastestLap && position <= SCORING_CONFIG.fastestLapEligibleTop) {
      points += SCORING_CONFIG.fastestLapPoints;
    }
    if (hasPole) {
      points += SCORING_CONFIG.polePositionPoints;
    }
  }
  
  return points;
}

async function main() {
  console.log('🏎️  Amigos de America 2025-1 League Seeding Started\n');

  // 1. Get admin user
  console.log('👤 Finding admin user...');
  const adminUser = await prisma.user.findUnique({
    where: { email: ADMIN_EMAIL.toLowerCase() },
  });
  
  if (!adminUser) {
    console.error('❌ Admin user not found! Run the main seed first.');
    process.exit(1);
  }
  console.log(`   ✓ Found admin: ${adminUser.email}`);

  // 2. Create or get tracks
  console.log('\n🏁 Ensuring tracks exist...');
  const trackMap = new Map<string, string>();
  
  for (const race of FULL_CALENDAR) {
    let track = await prisma.track.findFirst({
      where: { country: race.country },
    });
    
    if (!track) {
      track = await prisma.track.create({
        data: {
          name: `${race.city} Circuit`,
          shortName: race.country.substring(0, 3).toUpperCase(),
          country: race.country,
          city: race.city,
          length: 5.0 + Math.random() * 2,
          defaultLaps: 50 + Math.floor(Math.random() * 15),
          description: `Circuit in ${race.city}, ${race.country}`,
        },
      });
    }
    trackMap.set(race.name, track.id);
    console.log(`   ✓ ${track.name}`);
  }

  // 3. Create the league
  console.log('\n🏆 Creating Amigos de America 2025-1 league...');
  const leagueSlug = 'amigos-de-america-2025-1';
  
  // Delete existing league if exists (for clean re-seed)
  const existingLeague = await prisma.league.findUnique({ where: { slug: leagueSlug } });
  if (existingLeague) {
    await prisma.league.delete({ where: { slug: leagueSlug } });
    console.log('   ⚠️ Deleted existing league for clean re-seed');
  }
  
  const league = await prisma.league.create({
    data: {
      slug: leagueSlug,
      name: 'Amigos de America 2025 - 1',
      description: 'Liga de F1 para amigos de toda América. 24 carreras, clasificación 1 Shot, carreras al 100%. ¡Vamos a competir!',
      visibility: LeagueVisibility.PUBLIC,
      timezone: 'America/New_York',
      isActive: true,
      scoringConfig: SCORING_CONFIG,
      rules: `# Amigos de America 2025 - Temporada 1

## Información General
- **Carreras:** 24 Grandes Premios
- **Clasificación:** 1 Shot Quality
- **Distancia de Carrera:** 100%
- **Sprints:** 6 fines de semana con Sprint 100%
- **Horario:** Viernes 9:00 PM ET

## Reglas de Conducta
1. Respeto entre todos los pilotos
2. Sin contacto intencional
3. Respetar banderas azules en máximo 3 curvas

## Puntuación
- Sistema estándar F1 (25-18-15-12-10-8-6-4-2-1)
- Sprint (8-7-6-5-4-3-2-1)
- Pole Position: +1 punto
- Vuelta Rápida: +1 punto (solo top 10)

## Requisitos
- Asistir mínimo al 75% de las carreras
- Comunicar ausencias con anticipación
`,
    },
  });
  console.log(`   ✓ League created: ${league.name} (${league.slug})`);

  // 4. Add admin as league owner
  console.log('\n👑 Adding admin as league owner...');
  await prisma.membership.create({
    data: {
      userId: adminUser.id,
      leagueId: league.id,
      role: LeagueRole.OWNER,
    },
  });
  console.log(`   ✓ ${adminUser.email} is now OWNER`);

  // 5. Create teams
  console.log('\n🏎️ Creating teams...');
  const teams: { id: string; name: string }[] = [];
  
  for (const teamData of TEAMS_DATA) {
    const team = await prisma.team.create({
      data: {
        leagueId: league.id,
        name: teamData.name,
        shortName: teamData.shortName,
        primaryColor: teamData.primaryColor,
        secondaryColor: teamData.secondaryColor,
        country: teamData.country,
      },
    });
    teams.push({ id: team.id, name: team.name });
    console.log(`   ✓ ${team.name}`);
  }

  // 6. Create drivers
  console.log('\n🧑‍✈️ Creating drivers...');
  const drivers: { id: string; teamId: string; name: string }[] = [];
  
  for (const driverData of DRIVERS_DATA) {
    const team = teams[driverData.teamIndex];
    const driver = await prisma.driver.create({
      data: {
        teamId: team.id,
        fullName: driverData.fullName,
        shortName: driverData.shortName,
        gamertag: driverData.gamertag,
        country: driverData.country,
        number: driverData.number,
        isReserve: false,
      },
    });
    drivers.push({ id: driver.id, teamId: team.id, name: driver.fullName });
    console.log(`   ✓ #${driverData.number} ${driverData.fullName} (${team.name})`);
  }

  // 7. Create rounds and race calendar
  console.log('\n📅 Creating race calendar (24 races)...');
  
  // Calculate first Friday - let's start from early January 2025
  // First race on Friday Jan 10, 2025 at 9 PM ET
  const firstRaceDate = new Date('2025-01-10T21:00:00-05:00');
  
  const rounds: { id: string; roundNumber: number; name: string; hasSprint: boolean; status: RoundStatus }[] = [];
  
  for (let i = 0; i < FULL_CALENDAR.length; i++) {
    const race = FULL_CALENDAR[i];
    const trackId = trackMap.get(race.name)!;
    
    // Each race is on a Friday, one week apart
    const raceDate = addWeeks(firstRaceDate, i);
    
    // First 17 races are completed, rest are scheduled
    const isCompleted = i < 17;
    
    const round = await prisma.round.create({
      data: {
        leagueId: league.id,
        trackId: trackId,
        roundNumber: i + 1,
        name: race.name,
        scheduledAt: raceDate,
        hasQuali: true,
        hasSprint: race.hasSprint,
        status: isCompleted ? RoundStatus.COMPLETED : RoundStatus.SCHEDULED,
      },
    });
    
    rounds.push({
      id: round.id,
      roundNumber: round.roundNumber,
      name: race.name,
      hasSprint: race.hasSprint,
      status: round.status,
    });
    
    console.log(`   ${isCompleted ? '✅' : '📆'} R${i + 1}: ${race.name} ${race.hasSprint ? '(Sprint)' : ''} - ${raceDate.toLocaleDateString()}`);
  }

  // 8. Generate results for completed races
  console.log('\n🏁 Generating race results for 17 completed races...');
  
  const driverData = drivers.map(d => ({ id: d.id, teamId: d.teamId }));
  const driverPoints: Map<string, number> = new Map();
  const teamPoints: Map<string, number> = new Map();
  
  // Initialize points
  drivers.forEach(d => driverPoints.set(d.id, 0));
  teams.forEach(t => teamPoints.set(t.id, 0));
  
  for (let i = 0; i < 17; i++) {
    const round = rounds[i];
    console.log(`\n   📊 R${round.roundNumber}: ${round.name}:`);
    
    // Create race results
    const raceResults = simulateRaceResults(driverData);
    
    for (const result of raceResults.results) {
      const points = calculatePoints(result.position, true, result.fastestLap, result.pole, result.status);
      
      await prisma.result.create({
        data: {
          roundId: round.id,
          driverId: result.driverId,
          teamId: result.teamId,
          sessionType: SessionType.RACE,
          position: result.position,
          status: result.status,
          points: points,
          fastestLap: result.fastestLap,
          pole: result.pole,
          gapToLeader: result.gap,
        },
      });
      
      // Accumulate points
      if (points > 0) {
        driverPoints.set(result.driverId, (driverPoints.get(result.driverId) || 0) + points);
        teamPoints.set(result.teamId, (teamPoints.get(result.teamId) || 0) + points);
      }
    }
    
    const winner = drivers.find(d => d.id === raceResults.results[0].driverId)!;
    console.log(`      🏆 Race Winner: ${winner.name}`);
    
    // Create sprint results if applicable
    if (round.hasSprint) {
      const sprintResults = simulateSprintResults(driverData);
      
      for (const result of sprintResults) {
        const points = calculatePoints(result.position, false, false, false, result.status);
        
        await prisma.result.create({
          data: {
            roundId: round.id,
            driverId: result.driverId,
            teamId: result.teamId,
            sessionType: SessionType.SPRINT,
            position: result.position,
            status: result.status,
            points: points,
            fastestLap: false,
            pole: false,
            gapToLeader: result.gap,
          },
        });
        
        // Accumulate points
        if (points > 0) {
          driverPoints.set(result.driverId, (driverPoints.get(result.driverId) || 0) + points);
          teamPoints.set(result.teamId, (teamPoints.get(result.teamId) || 0) + points);
        }
      }
      
      const sprintWinner = drivers.find(d => d.id === sprintResults[0].driverId)!;
      console.log(`      ⚡ Sprint Winner: ${sprintWinner.name}`);
    }
  }

  // 9. Print final standings
  console.log('\n\n🏆 DRIVER STANDINGS AFTER 17 RACES:');
  console.log('═══════════════════════════════════════════════════════════════');
  
  const sortedDrivers = [...driverPoints.entries()]
    .sort((a, b) => b[1] - a[1])
    .map(([driverId, points], idx) => {
      const driver = drivers.find(d => d.id === driverId)!;
      const team = teams.find(t => t.id === driver.teamId)!;
      return { position: idx + 1, driver, team, points };
    });
  
  sortedDrivers.forEach((entry, idx) => {
    const medal = idx === 0 ? '🥇' : idx === 1 ? '🥈' : idx === 2 ? '🥉' : '  ';
    console.log(`${medal} ${entry.position.toString().padStart(2)}. ${entry.driver.name.padEnd(30)} ${entry.team.name.padEnd(20)} ${entry.points.toString().padStart(4)} pts`);
  });

  console.log('\n\n🏆 CONSTRUCTOR STANDINGS:');
  console.log('═══════════════════════════════════════════════════════════════');
  
  const sortedTeams = [...teamPoints.entries()]
    .sort((a, b) => b[1] - a[1])
    .map(([teamId, points], idx) => {
      const team = teams.find(t => t.id === teamId)!;
      return { position: idx + 1, team, points };
    });
  
  sortedTeams.forEach((entry, idx) => {
    const medal = idx === 0 ? '🥇' : idx === 1 ? '🥈' : idx === 2 ? '🥉' : '  ';
    console.log(`${medal} ${entry.position.toString().padStart(2)}. ${entry.team.name.padEnd(25)} ${entry.points.toString().padStart(4)} pts`);
  });

  console.log('\n\n✅ Amigos de America 2025-1 League seeding complete!');
  console.log(`\n📌 League URL: /leagues/${leagueSlug}`);
  console.log(`📌 Races completed: 17/24`);
  console.log(`📌 Races remaining: 7`);
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
