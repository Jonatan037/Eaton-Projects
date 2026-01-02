import { Metadata } from 'next';
import Link from 'next/link';
import { getTranslations } from 'next-intl/server';
import { Plus, Search, Users, Trophy, Globe, Lock } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
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
    <div className="min-h-screen flex flex-col">
      <Header />
      
      <main className="flex-1 py-12">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          {/* Page Header */}
          <div className="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h1 className="text-3xl font-bold tracking-tight">{tHome('publicLeagues')}</h1>
              <p className="mt-1 text-muted-foreground">
                Discover and join public F1 leagues
              </p>
            </div>
            <Button asChild variant="f1">
              <Link href="/leagues/create">
                <Plus className="mr-2 h-4 w-4" />
                {t('create')}
              </Link>
            </Button>
          </div>

          {/* Search and Filters */}
          <div className="mb-8 flex flex-col gap-4 sm:flex-row">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                placeholder="Search leagues..."
                className="pl-10"
              />
            </div>
          </div>

          {/* Leagues Grid */}
          {leagues.length === 0 ? (
            <Card className="text-center">
              <CardContent className="py-12">
                <Trophy className="mx-auto mb-4 h-12 w-12 text-muted-foreground" />
                <h3 className="mb-2 text-lg font-semibold">No leagues found</h3>
                <p className="mb-4 text-muted-foreground">
                  Be the first to create a public league!
                </p>
                <Button asChild variant="f1">
                  <Link href="/leagues/create">
                    <Plus className="mr-2 h-4 w-4" />
                    Create League
                  </Link>
                </Button>
              </CardContent>
            </Card>
          ) : (
            <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
              {leagues.map((league) => (
                <Card key={league.id} className="card-hover">
                  <CardHeader>
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <CardTitle className="text-xl">
                          <Link 
                            href={`/leagues/${league.slug}`}
                            className="hover:text-primary transition-colors"
                          >
                            {league.name}
                          </Link>
                        </CardTitle>
                        <CardDescription className="mt-1 line-clamp-2">
                          {league.description || 'No description'}
                        </CardDescription>
                      </div>
                      <Badge variant={league.visibility === 'PUBLIC' ? 'outline' : 'secondary'}>
                        {league.visibility === 'PUBLIC' ? (
                          <Globe className="mr-1 h-3 w-3" />
                        ) : (
                          <Lock className="mr-1 h-3 w-3" />
                        )}
                        {league.visibility === 'PUBLIC' ? t('public') : t('private')}
                      </Badge>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-4 text-sm text-muted-foreground">
                        <span className="flex items-center">
                          <Users className="mr-1.5 h-4 w-4" />
                          {league._count.memberships} {t('members').toLowerCase()}
                        </span>
                        <span className="flex items-center">
                          <Trophy className="mr-1.5 h-4 w-4" />
                          {league._count.rounds} rounds
                        </span>
                      </div>
                      <Button asChild size="sm">
                        <Link href={`/leagues/${league.slug}`}>
                          View
                        </Link>
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </div>
      </main>

      <Footer />
    </div>
  );
}
