import { Metadata } from 'next';
import Link from 'next/link';
import { redirect } from 'next/navigation';
import { getTranslations } from 'next-intl/server';
import { Plus, Search, Users, Trophy, Globe, Calendar, ArrowRight, Flag, Filter, Crown } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { AppLayout } from '@/components/layout/app-layout';
import { createClient } from '@/lib/supabase/server';
import prisma from '@/lib/db';

export const metadata: Metadata = {
  title: 'My Leagues | ApexGrid AI',
  description: 'Manage your F1 racing leagues',
};

export default async function LeaguesPage() {
  const t = await getTranslations('league');
  
  let user = null;
  try {
    const supabase = await createClient();
    const { data } = await supabase.auth.getUser();
    user = data?.user;
  } catch (error) {
    console.error('Error getting user:', error);
  }

  if (!user) {
    redirect('/auth/signin');
  }

  // Fetch user's leagues using the new LeagueMember model
  const leagueMembers = await prisma.leagueMember.findMany({
    where: { userId: user.id },
    include: {
      league: {
        include: {
          _count: {
            select: { 
              members: true,
              championships: true,
            },
          },
          championships: {
            where: { status: { in: ['ACTIVE', 'DRAFT'] } },
            include: {
              _count: {
                select: { races: true, teams: true },
              },
              races: {
                where: { status: 'COMPLETED' },
                select: { id: true },
              },
            },
            take: 1,
            orderBy: { createdAt: 'desc' },
          },
        },
      },
    },
  });

  const myLeagues = leagueMembers.map((m) => ({
    ...m.league,
    role: m.role,
    activeChampionship: m.league.championships[0] || null,
  }));

  // Fetch public leagues for discovery
  const publicLeagues = await prisma.league.findMany({
    where: {
      isPublic: true,
      isActive: true,
      NOT: {
        id: { in: myLeagues.map((l) => l.id) },
      },
    },
    include: {
      _count: {
        select: { members: true, championships: true },
      },
    },
    orderBy: { createdAt: 'desc' },
    take: 6,
  });

  return (
    <AppLayout user={{ email: user.email || '' }}>
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
            className="bg-gradient-to-r from-[#DC2626] to-[#B91C1C] text-white font-semibold hover:from-[#B91C1C] hover:to-[#991B1B] shadow-lg shadow-red-600/20"
          >
            <Link href="/leagues/new">
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
              className="pl-10 bg-white/5 border-white/10 text-white placeholder:text-gray-500 focus:border-[#DC2626]/50"
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
              <div className="mx-auto mb-6 h-20 w-20 rounded-full bg-gradient-to-br from-[#DC2626]/20 to-[#DC2626]/5 flex items-center justify-center">
                <Trophy className="h-10 w-10 text-[#DC2626]" />
              </div>
              <h3 className="text-xl font-semibold text-white mb-2">No leagues yet</h3>
              <p className="text-gray-400 mb-6 max-w-md mx-auto">
                Create your first league or join an existing one to start competing!
              </p>
              <Button 
                asChild 
                className="bg-gradient-to-r from-[#DC2626] to-[#B91C1C] text-white font-semibold"
              >
                <Link href="/leagues/new">
                  <Plus className="mr-2 h-4 w-4" />
                  Create Your First League
                </Link>
              </Button>
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
            {myLeagues.map((league) => {
              const championship = league.activeChampionship;
              const completedRaces = championship?.races?.length || 0;
              const totalRaces = championship?._count?.races || 0;
              const progress = totalRaces > 0 ? (completedRaces / totalRaces) * 100 : 0;
              
              return (
                <Link 
                  key={league.id}
                  href={`/leagues/${league.slug}`}
                  className="group relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10 transition-all duration-300 hover:border-[#DC2626]/50 hover:shadow-lg hover:shadow-[#DC2626]/10"
                >
                  {/* Top Accent Bar */}
                  <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-[#DC2626] to-[#B91C1C]" />
                  
                  <div className="p-5">
                    {/* Header */}
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex items-center gap-3">
                        <div className="h-11 w-11 rounded-xl bg-gradient-to-br from-[#DC2626]/20 to-[#DC2626]/5 flex items-center justify-center border border-[#DC2626]/20">
                          <Flag className="h-5 w-5 text-[#DC2626]" />
                        </div>
                        <div>
                          <h3 className="font-semibold text-white group-hover:text-[#DC2626] transition-colors line-clamp-1">
                            {league.name}
                          </h3>
                          <div className="flex items-center gap-2 mt-0.5">
                            <Badge className={`text-xs ${
                              league.role === 'OWNER' 
                                ? 'bg-yellow-500/10 text-yellow-400 border-yellow-500/30' 
                                : 'bg-[#DC2626]/10 text-[#DC2626] border-[#DC2626]/30'
                            }`}>
                              {league.role === 'OWNER' && <Crown className="h-3 w-3 mr-1" />}
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
                        <span className="text-gray-400">{league._count.members}</span>
                      </div>
                      <div className="flex items-center gap-1.5">
                        <Trophy className="h-4 w-4 text-gray-500" />
                        <span className="text-gray-400">{league._count.championships} champ.</span>
                      </div>
                      {championship && (
                        <div className="flex items-center gap-1.5">
                          <Flag className="h-4 w-4 text-gray-500" />
                          <span className="text-gray-400">{championship._count.teams} teams</span>
                        </div>
                      )}
                    </div>

                    {/* Progress Bar */}
                    {championship && totalRaces > 0 && (
                      <div>
                        <div className="flex justify-between text-xs mb-1.5">
                          <span className="text-gray-500">Season Progress</span>
                          <span className="text-gray-400">{completedRaces}/{totalRaces}</span>
                        </div>
                        <div className="h-2 rounded-full bg-white/10 overflow-hidden">
                          <div 
                            className="h-full rounded-full bg-gradient-to-r from-[#DC2626] to-[#B91C1C]"
                            style={{ width: `${progress}%` }}
                          />
                        </div>
                      </div>
                    )}

                    {!championship && (
                      <p className="text-xs text-gray-500">No active championship</p>
                    )}
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
                      <h3 className="font-medium text-white group-hover:text-[#DC2626] transition-colors truncate">
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
                      {league._count.members}
                    </span>
                    <span className="flex items-center gap-1">
                      <Calendar className="h-3 w-3" />
                      {league._count.championships} championships
                    </span>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        )}
      </div>
    </AppLayout>
  );
}
