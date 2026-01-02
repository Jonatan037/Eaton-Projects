import { Metadata } from 'next';
import Link from 'next/link';
import { getTranslations } from 'next-intl/server';
import { Plus, Search, Users, Trophy, Globe, Lock, Calendar, Sparkles, ArrowRight, Flag } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Header } from '@/components/layout/header';
import { Footer } from '@/components/layout/footer';
import prisma from '@/lib/db';

export const metadata: Metadata = {
  title: 'Leagues',
  description: 'Browse and join F1 racing leagues',
};

export default async function LeaguesPage() {
  const t = await getTranslations('league');
  const tHome = await getTranslations('home');

  // Fetch public leagues
  const leagues = await prisma.league.findMany({
    where: {
      visibility: 'PUBLIC',
      isActive: true,
    },
    include: {
      _count: {
        select: { memberships: true, rounds: true },
      },
    },
    orderBy: { createdAt: 'desc' },
    take: 20,
  });

  return (
    <div className="min-h-screen flex flex-col bg-black">
      <Header />
      
      <main className="flex-1">
        {/* Hero Section with Carbon Fiber Background */}
        <section className="relative py-16 overflow-hidden">
          {/* Background Effects */}
          <div className="absolute inset-0 bg-gradient-to-b from-[#2ECC71]/10 via-transparent to-transparent" />
          <div className="absolute inset-0 bg-grid-pattern opacity-30" />
          
          <div className="container mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
            {/* AI Badge */}
            <div className="flex justify-center mb-6">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[#2ECC71]/10 border border-[#2ECC71]/30">
                <Sparkles className="h-4 w-4 text-[#2ECC71]" />
                <span className="text-sm font-medium text-[#2ECC71]">AI-Powered Racing Leagues</span>
              </div>
            </div>
            
            {/* Title */}
            <div className="text-center max-w-3xl mx-auto">
              <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight text-white mb-4">
                Your Racing
                <span className="block text-[#2ECC71]">Community</span>
              </h1>
              <p className="text-lg text-gray-400 mb-8">
                Join competitive F1 leagues, track standings in real-time, and leverage AI insights to dominate the championship.
              </p>
            </div>

            {/* Search Bar - Modern Style */}
            <div className="max-w-2xl mx-auto">
              <div className="relative">
                <Search className="absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-gray-500" />
                <Input
                  placeholder="Search for leagues..."
                  className="w-full h-14 pl-12 pr-4 bg-white/5 border-white/10 text-white placeholder:text-gray-500 rounded-2xl text-lg focus:border-[#2ECC71]/50 focus:ring-[#2ECC71]/20"
                />
              </div>
            </div>

            {/* Stats Bar */}
            <div className="flex justify-center gap-8 mt-12">
              <div className="text-center">
                <div className="text-3xl font-bold text-white">{leagues.length}</div>
                <div className="text-sm text-gray-500">Active Leagues</div>
              </div>
              <div className="w-px bg-white/10" />
              <div className="text-center">
                <div className="text-3xl font-bold text-[#2ECC71]">
                  {leagues.reduce((acc, l) => acc + l._count.memberships, 0)}
                </div>
                <div className="text-sm text-gray-500">Total Racers</div>
              </div>
              <div className="w-px bg-white/10" />
              <div className="text-center">
                <div className="text-3xl font-bold text-white">
                  {leagues.reduce((acc, l) => acc + l._count.rounds, 0)}
                </div>
                <div className="text-sm text-gray-500">Scheduled Rounds</div>
              </div>
            </div>
          </div>
        </section>

        {/* Leagues Grid Section */}
        <section className="py-12">
          <div className="container mx-auto px-4 sm:px-6 lg:px-8">
            {/* Section Header */}
            <div className="flex items-center justify-between mb-8">
              <div>
                <h2 className="text-2xl font-bold text-white">{tHome('publicLeagues')}</h2>
                <p className="text-gray-500 mt-1">Discover and join competitive racing leagues</p>
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

            {/* Leagues Grid */}
            {leagues.length === 0 ? (
              <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-white/5 to-white/[0.02] border border-white/10 p-12 text-center">
                <div className="absolute inset-0 bg-grid-pattern opacity-10" />
                <div className="relative z-10">
                  <div className="mx-auto mb-6 h-20 w-20 rounded-full bg-gradient-to-br from-[#2ECC71]/20 to-[#2ECC71]/5 flex items-center justify-center">
                    <Trophy className="h-10 w-10 text-[#2ECC71]" />
                  </div>
                  <h3 className="text-xl font-semibold text-white mb-2">No leagues yet</h3>
                  <p className="text-gray-400 mb-6 max-w-md mx-auto">
                    Be the pioneer! Create the first league and start building your racing community.
                  </p>
                  <Button 
                    asChild 
                    className="bg-gradient-to-r from-[#2ECC71] to-[#27AE60] text-white font-semibold"
                  >
                    <Link href="/leagues/create">
                      <Plus className="mr-2 h-4 w-4" />
                      Create First League
                    </Link>
                  </Button>
                </div>
              </div>
            ) : (
              <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
                {leagues.map((league) => (
                  <Link 
                    key={league.id}
                    href={`/leagues/${league.slug}`}
                    className="group relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10 transition-all duration-300 hover:border-[#2ECC71]/50 hover:shadow-lg hover:shadow-[#2ECC71]/10 hover:-translate-y-1"
                  >
                    {/* Top Accent Bar */}
                    <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-[#2ECC71] via-[#58D68D] to-[#2ECC71] opacity-0 group-hover:opacity-100 transition-opacity" />
                    
                    {/* Card Content */}
                    <div className="p-6">
                      {/* Header */}
                      <div className="flex items-start justify-between mb-4">
                        <div className="flex items-center gap-3">
                          <div className="h-12 w-12 rounded-xl bg-gradient-to-br from-[#2ECC71]/20 to-[#2ECC71]/5 flex items-center justify-center border border-[#2ECC71]/20">
                            <Flag className="h-6 w-6 text-[#2ECC71]" />
                          </div>
                          <div>
                            <h3 className="font-semibold text-white group-hover:text-[#2ECC71] transition-colors line-clamp-1">
                              {league.name}
                            </h3>
                            <Badge 
                              variant="outline" 
                              className={`mt-1 text-xs ${
                                league.visibility === 'PUBLIC' 
                                  ? 'border-[#2ECC71]/30 text-[#2ECC71] bg-[#2ECC71]/10' 
                                  : 'border-gray-600 text-gray-400'
                              }`}
                            >
                              {league.visibility === 'PUBLIC' ? (
                                <><Globe className="mr-1 h-3 w-3" /> Public</>
                              ) : (
                                <><Lock className="mr-1 h-3 w-3" /> Private</>
                              )}
                            </Badge>
                          </div>
                        </div>
                      </div>

                      {/* Description */}
                      <p className="text-sm text-gray-400 line-clamp-2 mb-4 min-h-[40px]">
                        {league.description || 'Join this league and compete for championship glory!'}
                      </p>

                      {/* Stats */}
                      <div className="flex items-center gap-4 mb-4">
                        <div className="flex items-center gap-1.5 text-sm">
                          <Users className="h-4 w-4 text-gray-500" />
                          <span className="text-gray-400">{league._count.memberships}</span>
                          <span className="text-gray-600">members</span>
                        </div>
                        <div className="flex items-center gap-1.5 text-sm">
                          <Calendar className="h-4 w-4 text-gray-500" />
                          <span className="text-gray-400">{league._count.rounds}</span>
                          <span className="text-gray-600">rounds</span>
                        </div>
                      </div>

                      {/* Footer */}
                      <div className="flex items-center justify-between pt-4 border-t border-white/5">
                        <span className="text-xs text-gray-500">
                          Created {new Date(league.createdAt).toLocaleDateString()}
                        </span>
                        <div className="flex items-center gap-1 text-sm text-[#2ECC71] opacity-0 group-hover:opacity-100 transition-opacity">
                          <span>View League</span>
                          <ArrowRight className="h-4 w-4" />
                        </div>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            )}
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-16">
          <div className="container mx-auto px-4 sm:px-6 lg:px-8">
            <div className="relative overflow-hidden rounded-3xl bg-gradient-to-r from-[#2ECC71]/10 to-[#27AE60]/10 border border-[#2ECC71]/20 p-8 md:p-12">
              <div className="absolute inset-0 bg-grid-pattern opacity-10" />
              <div className="relative z-10 flex flex-col md:flex-row items-center justify-between gap-6">
                <div>
                  <h3 className="text-2xl font-bold text-white mb-2">Ready to start your own league?</h3>
                  <p className="text-gray-400">Create a league, invite friends, and compete for championship glory.</p>
                </div>
                <Button 
                  asChild 
                  size="lg"
                  className="bg-gradient-to-r from-[#2ECC71] to-[#27AE60] text-white font-semibold hover:from-[#27AE60] hover:to-[#229954] shadow-lg shadow-[#2ECC71]/20 whitespace-nowrap"
                >
                  <Link href="/leagues/create">
                    <Plus className="mr-2 h-5 w-5" />
                    Create League
                  </Link>
                </Button>
              </div>
            </div>
          </div>
        </section>
      </main>

      <Footer />
    </div>
  );
}
