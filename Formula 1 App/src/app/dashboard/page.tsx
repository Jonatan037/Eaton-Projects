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

export default async function DashboardPage() {
  try {
    const supabase = await createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();

    if (authError || !user) {
      redirect('/auth/signin');
    }

    // Try to get or create DB user
    let dbUser = null;
    try {
      dbUser = await prisma.user.findUnique({
        where: { supabaseAuthId: user.id },
      });

      if (!dbUser && user.email) {
        dbUser = await prisma.user.findUnique({
          where: { email: user.email.toLowerCase() },
        });

        if (dbUser) {
          // Link existing user to supabase auth
          dbUser = await prisma.user.update({
            where: { id: dbUser.id },
            data: { supabaseAuthId: user.id },
          });
        }
      }

      if (!dbUser) {
        dbUser = await prisma.user.create({
          data: {
            email: user.email?.toLowerCase() || '',
            fullName: user.email?.split('@')[0] || 'User',
            supabaseAuthId: user.id,
          },
        });
      }
    } catch (dbError) {
      console.error('Database user error:', dbError);
    }

    // Fetch user's leagues with error handling
    let leagues: any[] = [];
    let stats = {
      leagues: 0,
      championships: 0,
      completedRaces: 0,
      totalRaces: 0,
      drivers: 0,
    };

    if (dbUser) {
      try {
        const leagueMemberships = await prisma.leagueMember.findMany({
          where: { userId: dbUser.id },
          include: {
            league: {
              include: {
                championships: {
                  include: {
                    races: {
                      orderBy: { scheduledDate: 'asc' },
                      include: { track: true },
                    },
                    _count: { select: { drivers: true } },
                  },
                },
                _count: { select: { members: true, championships: true } },
              },
            },
          },
        });

        leagues = leagueMemberships.map((m) => ({
          id: m.league.id,
          name: m.league.name,
          slug: m.league.slug,
          role: m.role,
          memberCount: m.league._count.members,
          championshipCount: m.league._count.championships,
        }));

        // Calculate stats
        const allRaces = leagueMemberships.flatMap((m) =>
          m.league.championships.flatMap((c) => c.races)
        );

        stats = {
          leagues: leagues.length,
          championships: leagueMemberships.reduce((acc, m) => acc + m.league.championships.length, 0),
          completedRaces: allRaces.filter((r) => r.status === 'COMPLETED').length,
          totalRaces: allRaces.length,
          drivers: leagueMemberships.reduce(
            (acc, m) => acc + m.league.championships.reduce((a, c) => a + c._count.drivers, 0),
            0
          ),
        };
      } catch (leagueError) {
        console.error('League fetch error:', leagueError);
      }
    }

    return (
      <div className="min-h-screen bg-[#0a0a0a] flex">
        <Sidebar />
        <main className="flex-1 ml-[60px]">
          <DashboardContent
            user={{ email: user.email || '', name: dbUser?.fullName || user.email?.split('@')[0] }}
            stats={stats}
            leagues={leagues}
          />
        </main>
      </div>
    );
  } catch (error) {
    console.error('Dashboard error:', error);
    redirect('/auth/signin');
  }
}
