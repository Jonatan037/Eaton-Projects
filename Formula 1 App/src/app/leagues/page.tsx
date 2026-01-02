import { Metadata } from 'next';
import Link from 'next/link';
import { redirect } from 'next/navigation';
import { getTranslations } from 'next-intl/server';
import { Plus, Search, Users, Trophy, Globe, Lock, Calendar, Sparkles, ArrowRight, Flag, Filter } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { DashboardLayout } from '@/components/layout/dashboard-layout';
import { createClient } from '@/lib/supabase/server';
import prisma from '@/lib/db';

export const metadata: Metadata = {
  title: 'My Leagues | ApexGrid AI',
  description: 'Manage your F1 racing leagues',
};

export default async function LeaguesPage() {
  const t = await getTranslations('league');
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    redirect('/auth/signin');
  }

  // Fetch user's leagues
  const memberships = await prisma.membership.findMany({
    where: { userId: user.id },
    include: {
      league: {
        include: {
          _count: {
            select: { memberships: true, rounds: true, teams: true },
          },
          rounds: {
            where: { status: 'COMPLETED' },
            select: { id: true },
          },
        },
      },
    },
  });

  const myLeagues = memberships.map((m: typeof memberships[0]) => ({
    ...m.league,
    role: m.role,
  }));

  // Fetch public leagues for discovery
  const publicLeagues = await prisma.league.findMany({
    where: {
      visibility: 'PUBLIC',
      isActive: true,
      NOT: {
        id: { in: myLeagues.map((l: { id: string }) => l.id) },
      },
    },
    include: {
      _count: {
        select: { memberships: true, rounds: true },
      },
    },
    orderBy: { createdAt: 'desc' },
    take: 6,
  });

  return (
    <DashboardLayout user={{ email: user.email || '' }}>
      <div className="space-y-8">
        {/* Page Header */}
        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-3xl font-bold text-white">My Leagues</h1>
            <p className="text-gray-400 mt-1">
              Manage your championships and track your progress
            </p>
          </div>
          <Button 
            asChild
            className="bg-gradient-to-r from-[#2ECC71] to-[#27AE60] text-white font-semibold hover:from-[#27AE60] hover:to-[#229954] shadow-lg shadow-[#2ECC71]/20"
          >
            <Link href="/leagues/create">
              <Plus className="mr-2 h-4 w-4" />
              {t('create')}
            </Link>
          </Button>
        </div>

        {/* Search & Filter Bar */}
        <div className="flex items-center gap-4">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-500" />
            <Input
              placeholder="Search leagues..."
              className="pl-10 bg-white/5 border-white/10 text-white placeholder:text-gray-500 focus:border-[#2ECC71]/50"
            />
          </div>
          <Button variant="outline" className="border-white/10 text-gray-400 hover:text-white hover:bg-white/5">
            <Filter className="mr-2 h-4 w-4" />
            Filter
          </Button>
        </div>

        {/* My Leagues Grid */}
        {myLeagues.length === 0 ? (
          <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10 p-12 text-center">
            <div className="absolute inset-0 bg-grid-pattern opacity-10" />
            <div className="relative z-10">
              <div className="mx-auto mb-6 h-20 w-20 rounded-full bg-gradient-to-br from-[#2ECC71]/20 to-[#2ECC71]/5 flex items-center justify-center">
                <Trophy className="h-10 w-10 text-[#2ECC71]" />
              </div>
              <h3 className="text-xl font-semibold text-white mb-2">No leagues yet</h3>
              <p className="text-gray-400 mb-6 max-w-md mx-auto">
                Create your first league or join an existing one to start competing!
              </p>
              <Button 
                asChild 
                className="bg-gradient-to-r from-[#2ECC71] to-[#27AE60] text-white font-semibold"
              >
                <Link href="/leagues/create">
                  <Plus className="mr-2 h-4 w-4" />
                  Create Your First League
                </Link>
              </Button>
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
            {myLeagues.map((league) => {
              const completedRounds = league.rounds.length;
              const totalRounds = league._count.rounds;
              const progress = totalRounds > 0 ? (completedRounds / totalRounds) * 100 : 0;
              
              return (
                <Link 
                  key={league.id}
                  href={`/leagues/${league.slug}`}
                  className="group relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10 transition-all duration-300 hover:border-[#2ECC71]/50 hover:shadow-lg hover:shadow-[#2ECC71]/10"
                >
                  {/* Top Accent Bar */}
                  <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-[#2ECC71] to-[#27AE60]" />
                  
                  <div className="p-5">
                    {/* Header */}
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex items-center gap-3">
                        <div className="h-11 w-11 rounded-xl bg-gradient-to-br from-[#2ECC71]/20 to-[#2ECC71]/5 flex items-center justify-center border border-[#2ECC71]/20">
                          <Flag className="h-5 w-5 text-[#2ECC71]" />
                        </div>
                        <div>
                          <h3 className="font-semibold text-white group-hover:text-[#2ECC71] transition-colors line-clamp-1">
                            {league.name}
                          </h3>
                          <div className="flex items-center gap-2 mt-0.5">
                            <Badge className="text-xs bg-[#2ECC71]/10 text-[#2ECC71] border-[#2ECC71]/30">
                              {league.role}
                            </Badge>
                          </div>
                        </div>
                      </div>
                    </div>

                    {/* Stats */}
                    <div className="flex items-center gap-4 mb-4 text-sm">
                      <div className="flex items-center gap-1.5">
                        <Users className="h-4 w-4 text-gray-500" />
                        <span className="text-gray-400">{league._count.memberships}</span>
                      </div>
                      <div className="flex items-center gap-1.5">
                        <Trophy className="h-4 w-4 text-gray-500" />
                        <span className="text-gray-400">{league._count.teams} teams</span>
                      </div>
                    </div>

                    {/* Progress Bar */}
                    <div>
                      <div className="flex justify-between text-xs mb-1.5">
                        <span className="text-gray-500">Season Progress</span>
                        <span className="text-gray-400">{completedRounds}/{totalRounds}</span>
                      </div>
                      <div className="h-2 rounded-full bg-white/10 overflow-hidden">
                        <div 
                          className="h-full rounded-full bg-gradient-to-r from-[#2ECC71] to-[#27AE60]"
                          style={{ width: `${progress}%` }}
                        />
                      </div>
                    </div>
                  </div>
                </Link>
              );
            })}
          </div>
        )}

        {/* Discover Leagues Section */}
        {publicLeagues.length > 0 && (
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-xl font-semibold text-white">Discover Leagues</h2>
                <p className="text-sm text-gray-500">Join public leagues and compete with others</p>
              </div>
              <Button variant="ghost" className="text-gray-400 hover:text-white">
                View All
                <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
            </div>
            
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
              {publicLeagues.map((league) => (
                <Link 
                  key={league.id}
                  href={`/leagues/${league.slug}`}
                  className="group relative overflow-hidden rounded-xl bg-white/[0.03] border border-white/10 p-5 transition-all duration-300 hover:border-white/20 hover:bg-white/[0.05]"
                >
                  <div className="flex items-start gap-3 mb-3">
                    <div className="h-10 w-10 rounded-lg bg-white/10 flex items-center justify-center">
                      <Globe className="h-5 w-5 text-gray-400" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="font-medium text-white group-hover:text-[#2ECC71] transition-colors truncate">
                        {league.name}
                      </h3>
                      <p className="text-xs text-gray-500 truncate">
                        {league.description || 'Public league'}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3 text-xs text-gray-500">
                    <span className="flex items-center gap-1">
                      <Users className="h-3 w-3" />
                      {league._count.memberships}
                    </span>
                    <span className="flex items-center gap-1">
                      <Calendar className="h-3 w-3" />
                      {league._count.rounds} rounds
                    </span>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
