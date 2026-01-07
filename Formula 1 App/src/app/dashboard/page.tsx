import { Metadata } from 'next';
import { redirect } from 'next/navigation';
import { Sidebar } from '@/components/layout/sidebar';
import { createClient } from '@/lib/supabase/server';
import prisma from '@/lib/db';
import { DashboardContent } from './dashboard-content';

export const metadata: Metadata = {
  title: 'Dashboard | ApexGrid',
  description: 'Your F1 League Management Dashboard',
};

async function getDbUser(authUser: { id: string; email?: string }) {
  let dbUser = await prisma.user.findUnique({
    where: { supabaseAuthId: authUser.id },
  });

  if (!dbUser && authUser.email) {
    dbUser = await prisma.user.findUnique({
      where: { email: authUser.email.toLowerCase() },
    });
  }

  return dbUser;
}

export default async function DashboardPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    redirect('/auth/signin');
  }

  let dbUser = await getDbUser(user);

  if (!dbUser) {
    dbUser = await prisma.user.create({
      data: {
        email: user.email?.toLowerCase() || '',
        fullName: user.email?.split('@')[0] || 'User',
        supabaseAuthId: user.id,
      },
    });
  }

  // Fetch user's data
  const leagueMemberships = await prisma.leagueMember.findMany({
    where: { userId: dbUser.id },
    include: {
      league: {
        include: {
          championships: {
            include: {
              races: {
                orderBy: { scheduledDate: 'asc' },
                include: { 
                  track: true,
                  results: {
                    include: { driver: { include: { user: true } }, team: true },
                    orderBy: { position: 'asc' },
                  },
                },
              },
              drivers: { include: { user: true } },
              teams: true,
            },
          },
          _count: { select: { members: true, championships: true } },
        },
      },
    },
  });

  const leagues = leagueMemberships.map((m) => ({
    ...m.league,
    role: m.role,
  }));

  // Calculate stats
  const allRaces = leagues.flatMap((l) => l.championships.flatMap((c) => c.races));
  const completedRaces = allRaces.filter((r) => r.status === 'COMPLETED').length;
  const totalChampionships = leagues.reduce((acc, l) => acc + l.championships.length, 0);
  const totalDrivers = leagues.reduce(
    (acc, l) => acc + l.championships.reduce((a, c) => a + c.drivers.length, 0),
    0
  );

  // Get next race
  const upcomingRaces = allRaces
    .filter((r) => r.status === 'SCHEDULED' && r.scheduledDate && new Date(r.scheduledDate) > new Date())
    .sort((a, b) => new Date(a.scheduledDate!).getTime() - new Date(b.scheduledDate!).getTime());

  const nextRace = upcomingRaces[0];

  // Build championship standings
  const championshipsWithStandings = leagues.flatMap((league) =>
    league.championships.map((championship) => {
      const driverPoints = new Map<string, { name: string; teamName: string; points: number }>();
      
      championship.races
        .filter((r) => r.status === 'COMPLETED')
        .forEach((race) => {
          race.results.forEach((result) => {
            const existing = driverPoints.get(result.driverId) || {
              name: result.driver?.user?.fullName || result.driver?.name || 'Unknown',
              teamName: result.team?.name || 'Unknown',
              points: 0,
            };
            existing.points += result.points || 0;
            driverPoints.set(result.driverId, existing);
          });
        });

      const standings = Array.from(driverPoints.entries())
        .map(([_, data]) => data)
        .sort((a, b) => b.points - a.points)
        .slice(0, 5);

      return {
        id: championship.id,
        name: championship.name,
        leagueName: league.name,
        standings,
      };
    })
  );

  // Build leagues data
  const leaguesData = leagues.map((league) => ({
    id: league.id,
    name: league.name,
    slug: league.slug,
    role: league.role,
    memberCount: league._count.members,
    championshipCount: league._count.championships,
  }));

  return (
    <div className="min-h-screen bg-[#0a0a0a] flex">
      <Sidebar />
      <main className="flex-1 ml-[60px]">
        <DashboardContent
          user={{ email: user.email || '', name: dbUser.fullName }}
          stats={{
            leagues: leagues.length,
            championships: totalChampionships,
            completedRaces,
            totalRaces: allRaces.length,
            drivers: totalDrivers,
          }}
          nextRace={nextRace ? {
            name: nextRace.name || nextRace.track?.name || 'TBD',
            trackName: nextRace.track?.name || 'Unknown',
            country: nextRace.track?.country || 'Unknown',
            scheduledDate: nextRace.scheduledDate?.toISOString() || null,
            scheduledTime: nextRace.scheduledTime,
            roundNumber: nextRace.roundNumber,
          } : null}
          championships={championshipsWithStandings}
          leagues={leaguesData}
        />
      </main>
    </div>
  );
}
