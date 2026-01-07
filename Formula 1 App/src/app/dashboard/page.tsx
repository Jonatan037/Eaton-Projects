import { Metadata } from 'next';
import { redirect } from 'next/navigation';
import { Trophy, Users, Flag, Medal, Activity } from 'lucide-react';
import { AppLayout } from '@/components/layout/app-layout';
import { NextRaceCard } from '@/components/dashboard/next-race-card';
import { ChampionshipStandingsChart } from '@/components/dashboard/championship-standings-chart';
import { LeaguesList } from '@/components/dashboard/leagues-list';
import { StatCard } from '@/components/dashboard/stat-card';
import { createClient } from '@/lib/supabase/server';
import prisma from '@/lib/db';

export const metadata: Metadata = {
  title: 'Dashboard | ApexGrid',
  description: 'Your F1 League Management Dashboard',
};

// Helper to get DB user from Supabase auth
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

  const dbUser = await getDbUser(user);

  if (!dbUser) {
    // Create user if doesn't exist
    await prisma.user.create({
      data: {
        email: user.email?.toLowerCase() || '',
        fullName: user.email?.split('@')[0] || 'User',
        supabaseAuthId: user.id,
      },
    });
  }

  const userId = dbUser?.id || user.id;

  // Fetch user's league memberships with league data
  const leagueMemberships = await prisma.leagueMember.findMany({
    where: { userId },
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
                    include: {
                      driver: true,
                      team: true,
                    },
                    orderBy: { position: 'asc' },
                  },
                },
              },
              drivers: {
                include: {
                  user: true,
                },
              },
              teams: true,
              _count: {
                select: { teams: true, drivers: true, members: true },
              },
            },
          },
          _count: {
            select: { members: true, championships: true },
          },
        },
      },
    },
  });

  const leagues = leagueMemberships.map((m) => ({
    ...m.league,
    role: m.role,
  }));

  // Calculate totals across all championships
  const allRaces = leagues.flatMap((l) =>
    l.championships.flatMap((c) => c.races)
  );
  const totalRaces = allRaces.length;
  const completedRaces = allRaces.filter((r) => r.status === 'COMPLETED').length;
  const totalChampionships = leagues.reduce((acc, l) => acc + l.championships.length, 0);

  // Get the next upcoming race across all leagues/championships
  const upcomingRaces = allRaces
    .filter((r) => r.status === 'SCHEDULED' && r.scheduledDate && new Date(r.scheduledDate) > new Date())
    .sort((a, b) => new Date(a.scheduledDate!).getTime() - new Date(b.scheduledDate!).getTime());

  const nextRace = upcomingRaces[0];
  
  // Find the championship and league for the next race
  let nextRaceData = null;
  if (nextRace) {
    for (const league of leagues) {
      for (const championship of league.championships) {
        const race = championship.races.find((r) => r.id === nextRace.id);
        if (race) {
          nextRaceData = {
            name: race.name || race.track?.name || 'TBD',
            trackName: race.track?.name || 'Unknown Track',
            country: race.track?.country || 'Unknown',
            scheduledDate: race.scheduledDate,
            scheduledTime: race.scheduledTime,
            roundNumber: race.roundNumber,
            leagueName: league.name,
            championshipName: championship.name,
            trackSlug: race.track?.slug,
          };
          break;
        }
      }
      if (nextRaceData) break;
    }
  }

  // Build championship standings data
  const championshipsWithStandings = leagues.flatMap((league) =>
    league.championships
      .filter((c) => c.races.some((r) => r.status === 'COMPLETED'))
      .map((championship) => {
        // Calculate driver points from race results
        const driverPoints = new Map<string, { name: string; teamName: string; points: number }>();
        
        championship.races
          .filter((r) => r.status === 'COMPLETED')
          .forEach((race) => {
            race.results.forEach((result) => {
              const driverId = result.driverId;
              const existing = driverPoints.get(driverId) || {
                name: result.driver?.user?.fullName || result.driver?.name || 'Unknown',
                teamName: result.team?.name || 'Unknown Team',
                points: 0,
              };
              existing.points += result.points || 0;
              driverPoints.set(driverId, existing);
            });
          });

        const standings = Array.from(driverPoints.entries())
          .map(([id, data]) => ({
            position: 0, // Will be set after sorting
            driverName: data.name,
            teamName: data.teamName,
            points: data.points,
          }))
          .sort((a, b) => b.points - a.points)
          .map((s, i) => ({ ...s, position: i + 1 }));

        return {
          id: championship.id,
          name: championship.name,
          leagueName: league.name,
          standings,
        };
      })
  );

  // Build leagues list data
  const leaguesListData = leagues.map((league) => {
    const activeChamp = league.championships.find((c) => c.status === 'ACTIVE');
    return {
      id: league.id,
      name: league.name,
      slug: league.slug,
      role: league.role as 'OWNER' | 'ADMIN' | 'MEMBER',
      memberCount: league._count.members,
      championshipCount: league._count.championships,
      activeChampionship: activeChamp
        ? {
            name: activeChamp.name,
            completedRaces: activeChamp.races.filter((r) => r.status === 'COMPLETED').length,
            totalRaces: activeChamp.races.length,
          }
        : undefined,
    };
  });

  // Stats for the cards
  const totalDrivers = leagues.reduce(
    (acc, l) => acc + l.championships.reduce((a, c) => a + (c._count.drivers || 0), 0),
    0
  );

  return (
    <AppLayout user={{ email: user.email || '', name: dbUser?.fullName }}>
      <div className="space-y-6">
        {/* Page Header */}
        <div>
          <h1 className="text-2xl font-bold text-white">Dashboard</h1>
          <p className="text-gray-500 text-sm mt-1">
            Manage your leagues, monitor progress, and track your championships.
          </p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard
            label="Active Leagues"
            value={leagues.length}
            change={leagues.length > 0 ? 'Active' : 'None'}
            trend="neutral"
            icon={Trophy}
            color="#DC2626"
          />
          <StatCard
            label="Championships"
            value={totalChampionships}
            change={`${leagues.filter((l) => l.championships.some((c) => c.status === 'ACTIVE')).length} active`}
            trend="neutral"
            icon={Medal}
            color="#F59E0B"
          />
          <StatCard
            label="Races"
            value={`${completedRaces}/${totalRaces}`}
            change={totalRaces > 0 ? `${Math.round((completedRaces / totalRaces) * 100)}% complete` : 'No races'}
            trend={completedRaces > 0 ? 'up' : 'neutral'}
            icon={Flag}
            color="#3B82F6"
          />
          <StatCard
            label="Drivers"
            value={totalDrivers}
            change="Across all championships"
            trend="neutral"
            icon={Users}
            color="#8B5CF6"
          />
        </div>

        {/* Main Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Left Column - Next Race & Standings */}
          <div className="lg:col-span-2 space-y-6">
            {/* Next Race Card */}
            <NextRaceCard race={nextRaceData} />

            {/* Championship Standings */}
            <ChampionshipStandingsChart championships={championshipsWithStandings} />
          </div>

          {/* Right Column - Leagues List */}
          <div className="space-y-6">
            <LeaguesList leagues={leaguesListData} />

            {/* Recent Activity Card */}
            <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.06] to-white/[0.02] border border-white/[0.06] p-5">
              <div className="flex items-center gap-3 mb-4">
                <div className="h-10 w-10 rounded-xl bg-green-500/20 flex items-center justify-center">
                  <Activity className="h-5 w-5 text-green-500" />
                </div>
                <h3 className="text-lg font-semibold text-white">Recent Activity</h3>
              </div>

              {completedRaces > 0 ? (
                <div className="space-y-3">
                  {allRaces
                    .filter((r) => r.status === 'COMPLETED')
                    .slice(0, 3)
                    .map((race) => (
                      <div
                        key={race.id}
                        className="flex items-center gap-3 p-3 rounded-xl bg-white/[0.02]"
                      >
                        <div className="h-8 w-8 rounded-lg bg-white/[0.06] flex items-center justify-center">
                          <Flag className="h-4 w-4 text-gray-400" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm text-white truncate">
                            {race.name || race.track?.name || 'Race'} completed
                          </p>
                          <p className="text-xs text-gray-500">Round {race.roundNumber}</p>
                        </div>
                      </div>
                    ))}
                </div>
              ) : (
                <div className="text-center py-4">
                  <p className="text-gray-400 text-sm">No recent activity</p>
                  <p className="text-xs text-gray-500 mt-1">Complete races to see activity here</p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </AppLayout>
  );
}
