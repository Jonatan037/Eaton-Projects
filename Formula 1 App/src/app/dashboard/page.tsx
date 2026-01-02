import { Metadata } from 'next';
import { redirect } from 'next/navigation';
import Link from 'next/link';
import { getTranslations } from 'next-intl/server';
import {
  Trophy,
  Calendar,
  Users,
  TrendingUp,
  ArrowUpRight,
  ArrowDownRight,
  Clock,
  Flag,
  Sparkles,
  ChevronRight,
  Activity,
  Target,
  Zap,
  BarChart3,
} from 'lucide-react';
import { DashboardLayout } from '@/components/layout/dashboard-layout';
import { Button } from '@/components/ui/button';
import { createClient } from '@/lib/supabase/server';
import prisma from '@/lib/db';

export const metadata: Metadata = {
  title: 'Dashboard | ApexGrid AI',
  description: 'Your F1 League Management Dashboard',
};

export default async function DashboardPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    redirect('/auth/signin');
  }

  // Fetch user's leagues and stats
  const memberships = await prisma.membership.findMany({
    where: { userId: user.id },
    include: {
      league: {
        include: {
          rounds: {
            orderBy: { scheduledAt: 'asc' },
            include: { track: true },
          },
          _count: {
            select: { memberships: true, teams: true },
          },
        },
      },
    },
  });

  const leagues = memberships.map((m: typeof memberships[0]) => m.league);
  const totalRaces = leagues.reduce((acc: number, l) => acc + l.rounds.length, 0);
  const completedRaces = leagues.reduce((acc: number, l) => acc + l.rounds.filter((r: { status: string }) => r.status === 'COMPLETED').length, 0);
  
  // Get upcoming races across all leagues
  type Round = typeof leagues[0]['rounds'][0];
  const upcomingRaces = leagues
    .flatMap((l) => l.rounds.filter((r: Round) => r.status === 'SCHEDULED' && new Date(r.scheduledAt) > new Date()))
    .sort((a: Round, b: Round) => new Date(a.scheduledAt).getTime() - new Date(b.scheduledAt).getTime())
    .slice(0, 5);

  const stats = [
    { 
      label: 'Active Leagues', 
      value: leagues.length, 
      change: '+12%',
      trend: 'up',
      icon: Trophy,
      color: '#2ECC71',
    },
    { 
      label: 'Upcoming Races', 
      value: upcomingRaces.length, 
      change: 'This week',
      trend: 'neutral',
      icon: Calendar,
      color: '#3B82F6',
    },
    { 
      label: 'Total Races', 
      value: `${completedRaces}/${totalRaces}`, 
      change: `${totalRaces > 0 ? Math.round((completedRaces / totalRaces) * 100) : 0}%`,
      trend: 'up',
      icon: Flag,
      color: '#F59E0B',
    },
    { 
      label: 'AI Insights', 
      value: '23', 
      change: 'New',
      trend: 'up',
      icon: Sparkles,
      color: '#8B5CF6',
    },
  ];

  return (
    <DashboardLayout user={{ email: user.email || '' }}>
      <div className="space-y-8">
        {/* Welcome Header */}
        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-3xl font-bold text-white">
              Welcome back, {user.email?.split('@')[0]}
            </h1>
            <p className="text-gray-400 mt-1">
              Here&apos;s what&apos;s happening in your leagues today.
            </p>
          </div>
          <Button className="bg-gradient-to-r from-[#2ECC71] to-[#27AE60] text-white font-semibold hover:from-[#27AE60] hover:to-[#229954] shadow-lg shadow-[#2ECC71]/20">
            <Sparkles className="mr-2 h-4 w-4" />
            Ask AI
          </Button>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {stats.map((stat, i) => {
            const Icon = stat.icon;
            return (
              <div 
                key={i}
                className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10 p-5 hover:border-white/20 transition-colors group"
              >
                <div className="flex items-start justify-between">
                  <div>
                    <p className="text-sm text-gray-400">{stat.label}</p>
                    <p className="text-3xl font-bold text-white mt-1">{stat.value}</p>
                    <div className="flex items-center gap-1 mt-2">
                      {stat.trend === 'up' ? (
                        <ArrowUpRight className="h-4 w-4 text-[#2ECC71]" />
                      ) : stat.trend === 'down' ? (
                        <ArrowDownRight className="h-4 w-4 text-red-400" />
                      ) : (
                        <Activity className="h-4 w-4 text-gray-400" />
                      )}
                      <span className={`text-sm ${stat.trend === 'up' ? 'text-[#2ECC71]' : stat.trend === 'down' ? 'text-red-400' : 'text-gray-400'}`}>
                        {stat.change}
                      </span>
                    </div>
                  </div>
                  <div 
                    className="h-12 w-12 rounded-xl flex items-center justify-center"
                    style={{ backgroundColor: `${stat.color}20` }}
                  >
                    <Icon className="h-6 w-6" style={{ color: stat.color }} />
                  </div>
                </div>
                {/* Decorative gradient */}
                <div 
                  className="absolute bottom-0 left-0 right-0 h-1 opacity-0 group-hover:opacity-100 transition-opacity"
                  style={{ background: `linear-gradient(to right, ${stat.color}, transparent)` }}
                />
              </div>
            );
          })}
        </div>

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Upcoming Races */}
          <div className="lg:col-span-2 relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10">
            <div className="p-5 border-b border-white/10 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Calendar className="h-5 w-5 text-[#2ECC71]" />
                <h2 className="text-lg font-semibold text-white">Upcoming Races</h2>
              </div>
              <Link href="/calendar" className="text-sm text-gray-400 hover:text-white flex items-center gap-1">
                View All <ChevronRight className="h-4 w-4" />
              </Link>
            </div>
            <div className="divide-y divide-white/5">
              {upcomingRaces.length > 0 ? (
                upcomingRaces.map((race: Round, i: number) => (
                  <div key={race.id} className="flex items-center justify-between p-5 hover:bg-white/[0.02] transition-colors">
                    <div className="flex items-center gap-4">
                      <div className={`flex h-12 w-12 items-center justify-center rounded-xl font-bold text-lg ${
                        i === 0 ? 'bg-[#2ECC71]/20 text-[#2ECC71]' : 'bg-white/10 text-gray-400'
                      }`}>
                        R{race.roundNumber}
                      </div>
                      <div>
                        <h3 className="font-semibold text-white">
                          {race.name || race.track.name}
                        </h3>
                        <p className="text-sm text-gray-500 flex items-center gap-1">
                          <Flag className="h-3 w-3" />
                          {race.track.country}
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-medium text-white">
                        {new Date(race.scheduledAt).toLocaleDateString('en-US', { 
                          month: 'short', 
                          day: 'numeric' 
                        })}
                      </p>
                      <p className="text-xs text-gray-500 flex items-center gap-1 justify-end">
                        <Clock className="h-3 w-3" />
                        {new Date(race.scheduledAt).toLocaleTimeString('en-US', { 
                          hour: '2-digit', 
                          minute: '2-digit' 
                        })}
                      </p>
                    </div>
                  </div>
                ))
              ) : (
                <div className="p-10 text-center">
                  <Calendar className="h-12 w-12 text-gray-600 mx-auto mb-3" />
                  <p className="text-gray-500">No upcoming races</p>
                  <p className="text-sm text-gray-600">Join a league to see scheduled races</p>
                </div>
              )}
            </div>
          </div>

          {/* Quick Actions & AI Insights */}
          <div className="space-y-6">
            {/* Quick Actions */}
            <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10 p-5">
              <h2 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
                <Zap className="h-5 w-5 text-[#F59E0B]" />
                Quick Actions
              </h2>
              <div className="space-y-2">
                <Link 
                  href="/leagues/new"
                  className="flex items-center gap-3 p-3 rounded-xl bg-white/5 hover:bg-white/10 transition-colors group"
                >
                  <div className="h-10 w-10 rounded-lg bg-[#2ECC71]/20 flex items-center justify-center">
                    <Trophy className="h-5 w-5 text-[#2ECC71]" />
                  </div>
                  <div className="flex-1">
                    <p className="font-medium text-white group-hover:text-[#2ECC71] transition-colors">Create League</p>
                    <p className="text-xs text-gray-500">Start a new championship</p>
                  </div>
                  <ChevronRight className="h-4 w-4 text-gray-600 group-hover:text-[#2ECC71]" />
                </Link>
                <Link 
                  href="/ai-chat"
                  className="flex items-center gap-3 p-3 rounded-xl bg-white/5 hover:bg-white/10 transition-colors group"
                >
                  <div className="h-10 w-10 rounded-lg bg-[#8B5CF6]/20 flex items-center justify-center">
                    <Sparkles className="h-5 w-5 text-[#8B5CF6]" />
                  </div>
                  <div className="flex-1">
                    <p className="font-medium text-white group-hover:text-[#8B5CF6] transition-colors">AI Assistant</p>
                    <p className="text-xs text-gray-500">Get race predictions</p>
                  </div>
                  <ChevronRight className="h-4 w-4 text-gray-600 group-hover:text-[#8B5CF6]" />
                </Link>
                <Link 
                  href="/analytics"
                  className="flex items-center gap-3 p-3 rounded-xl bg-white/5 hover:bg-white/10 transition-colors group"
                >
                  <div className="h-10 w-10 rounded-lg bg-[#3B82F6]/20 flex items-center justify-center">
                    <BarChart3 className="h-5 w-5 text-[#3B82F6]" />
                  </div>
                  <div className="flex-1">
                    <p className="font-medium text-white group-hover:text-[#3B82F6] transition-colors">View Analytics</p>
                    <p className="text-xs text-gray-500">Performance insights</p>
                  </div>
                  <ChevronRight className="h-4 w-4 text-gray-600 group-hover:text-[#3B82F6]" />
                </Link>
              </div>
            </div>

            {/* AI Insights Card */}
            <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-[#8B5CF6]/20 to-[#8B5CF6]/5 border border-[#8B5CF6]/30 p-5">
              <div className="absolute top-0 right-0 w-32 h-32 bg-[#8B5CF6]/10 rounded-full blur-3xl" />
              <div className="relative">
                <div className="flex items-center gap-2 mb-3">
                  <Sparkles className="h-5 w-5 text-[#8B5CF6]" />
                  <h2 className="text-lg font-semibold text-white">AI Insight</h2>
                </div>
                <p className="text-gray-300 text-sm leading-relaxed">
                  Based on recent form, your leagues show strong competition with 3 drivers within 10 points of the lead. Consider reviewing penalty systems for closer finishes.
                </p>
                <Button 
                  variant="ghost" 
                  size="sm" 
                  className="mt-4 text-[#8B5CF6] hover:text-white hover:bg-[#8B5CF6]/20"
                >
                  View All Insights
                  <ChevronRight className="ml-1 h-4 w-4" />
                </Button>
              </div>
            </div>
          </div>
        </div>

        {/* My Leagues */}
        <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10">
          <div className="p-5 border-b border-white/10 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Trophy className="h-5 w-5 text-[#2ECC71]" />
              <h2 className="text-lg font-semibold text-white">My Leagues</h2>
            </div>
            <Link href="/leagues" className="text-sm text-gray-400 hover:text-white flex items-center gap-1">
              View All <ChevronRight className="h-4 w-4" />
            </Link>
          </div>
          
          {leagues.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 p-5">
              {leagues.slice(0, 3).map((league: typeof leagues[0]) => {
                const completedRounds = league.rounds.filter((r: { status: string }) => r.status === 'COMPLETED').length;
                const progress = league.rounds.length > 0 ? (completedRounds / league.rounds.length) * 100 : 0;
                
                return (
                  <Link 
                    key={league.id}
                    href={`/leagues/${league.slug}`}
                    className="relative overflow-hidden rounded-xl bg-white/[0.03] border border-white/10 p-5 hover:border-[#2ECC71]/50 transition-all group"
                  >
                    <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-[#2ECC71] to-[#27AE60]" />
                    <h3 className="font-semibold text-white group-hover:text-[#2ECC71] transition-colors">
                      {league.name}
                    </h3>
                    <div className="flex items-center gap-4 mt-3 text-sm text-gray-500">
                      <span className="flex items-center gap-1">
                        <Users className="h-4 w-4" />
                        {league._count.memberships}
                      </span>
                      <span className="flex items-center gap-1">
                        <Flag className="h-4 w-4" />
                        {league._count.teams}
                      </span>
                    </div>
                    <div className="mt-4">
                      <div className="flex justify-between text-xs mb-1.5">
                        <span className="text-gray-500">Season Progress</span>
                        <span className="text-gray-400">{completedRounds}/{league.rounds.length}</span>
                      </div>
                      <div className="h-2 rounded-full bg-white/10 overflow-hidden">
                        <div 
                          className="h-full rounded-full bg-gradient-to-r from-[#2ECC71] to-[#27AE60]"
                          style={{ width: `${progress}%` }}
                        />
                      </div>
                    </div>
                  </Link>
                );
              })}
            </div>
          ) : (
            <div className="p-10 text-center">
              <Trophy className="h-12 w-12 text-gray-600 mx-auto mb-3" />
              <p className="text-gray-500">No leagues yet</p>
              <p className="text-sm text-gray-600 mb-4">Create your first league to get started</p>
              <Button asChild className="bg-[#2ECC71] hover:bg-[#27AE60] text-white">
                <Link href="/leagues/new">
                  Create League
                </Link>
              </Button>
            </div>
          )}
        </div>
      </div>
    </DashboardLayout>
  );
}
