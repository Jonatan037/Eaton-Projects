import { Metadata } from 'next';
import { notFound } from 'next/navigation';
import Link from 'next/link';
import { getTranslations } from 'next-intl/server';
import { 
  Calendar, 
  Trophy, 
  Users, 
  Settings, 
  Flag,
  Clock,
  ChevronRight,
  Globe,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Header } from '@/components/layout/header';
import { Footer } from '@/components/layout/footer';
import prisma from '@/lib/db';
import { formatRaceDateTime } from '@/lib/date-utils';

interface LeaguePageProps {
  params: Promise<{ slug: string }>;
}

export async function generateMetadata({ params }: LeaguePageProps): Promise<Metadata> {
  const { slug } = await params;
  const league = await prisma.league.findUnique({
    where: { slug },
  });

  if (!league) {
    return { title: 'League Not Found' };
  }

  return {
    title: league.name,
    description: league.description || `F1 League: ${league.name}`,
  };
}

export default async function LeaguePage({ params }: LeaguePageProps) {
  const { slug } = await params;
  const t = await getTranslations('league');
  const tRound = await getTranslations('round');
  const tStandings = await getTranslations('standings');

  const league = await prisma.league.findUnique({
    where: { slug },
    include: {
      teams: {
        where: { isActive: true },
        include: {
          drivers: {
            where: { isActive: true },
          },
        },
      },
      rounds: {
        orderBy: { roundNumber: 'asc' },
        include: {
          track: true,
        },
      },
      memberships: {
        include: {
          user: {
            select: { id: true, name: true, email: true, avatar: true },
          },
        },
      },
    },
  });

  if (!league) {
    notFound();
  }

  const upcomingRounds = league.rounds.filter(
    (r) => r.status === 'SCHEDULED' && new Date(r.scheduledAt) > new Date()
  );
  const nextRace = upcomingRounds[0];
  const completedRounds = league.rounds.filter((r) => r.status === 'COMPLETED');
  const totalDrivers = league.teams.reduce((acc, t) => acc + t.drivers.length, 0);

  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      
      <main className="flex-1">
        {/* League Header */}
        <div className="border-b bg-muted/50">
          <div className="container mx-auto px-4 py-8 sm:px-6 lg:px-8">
            <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <div className="flex items-center gap-2 mb-2">
                  <Badge variant={league.visibility === 'PUBLIC' ? 'outline' : 'secondary'}>
                    <Globe className="mr-1 h-3 w-3" />
                    {league.visibility === 'PUBLIC' ? t('public') : t('private')}
                  </Badge>
                  <Badge variant="f1">{league.timezone}</Badge>
                </div>
                <h1 className="text-3xl font-bold tracking-tight">{league.name}</h1>
                {league.description && (
                  <p className="mt-2 text-muted-foreground max-w-2xl">
                    {league.description}
                  </p>
                )}
              </div>
              <div className="flex gap-2">
                <Button asChild variant="outline">
                  <Link href={`/leagues/${slug}/admin`}>
                    <Settings className="mr-2 h-4 w-4" />
                    {t('settings')}
                  </Link>
                </Button>
                <Button variant="f1">
                  Join League
                </Button>
              </div>
            </div>

            {/* Stats */}
            <div className="mt-6 grid grid-cols-2 gap-4 sm:grid-cols-4">
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
                  <Users className="h-5 w-5 text-primary" />
                </div>
                <div>
                  <p className="text-2xl font-bold">{league.memberships.length}</p>
                  <p className="text-sm text-muted-foreground">{t('members')}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
                  <Flag className="h-5 w-5 text-primary" />
                </div>
                <div>
                  <p className="text-2xl font-bold">{league.teams.length}</p>
                  <p className="text-sm text-muted-foreground">{t('teams')}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
                  <Trophy className="h-5 w-5 text-primary" />
                </div>
                <div>
                  <p className="text-2xl font-bold">{totalDrivers}</p>
                  <p className="text-sm text-muted-foreground">{t('drivers')}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10">
                  <Calendar className="h-5 w-5 text-primary" />
                </div>
                <div>
                  <p className="text-2xl font-bold">{completedRounds.length}/{league.rounds.length}</p>
                  <p className="text-sm text-muted-foreground">Rounds</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="container mx-auto px-4 py-8 sm:px-6 lg:px-8">
          <Tabs defaultValue="overview" className="space-y-6">
            <TabsList>
              <TabsTrigger value="overview">{t('overview')}</TabsTrigger>
              <TabsTrigger value="schedule">{t('schedule')}</TabsTrigger>
              <TabsTrigger value="standings">{t('standings')}</TabsTrigger>
              <TabsTrigger value="teams">{t('teams')}</TabsTrigger>
              <TabsTrigger value="results">{t('results')}</TabsTrigger>
            </TabsList>

            {/* Overview Tab */}
            <TabsContent value="overview" className="space-y-6">
              <div className="grid gap-6 md:grid-cols-2">
                {/* Next Race */}
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Clock className="h-5 w-5 text-brand-red" />
                      Next Race
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    {nextRace ? (
                      <div className="space-y-2">
                        <h3 className="text-xl font-semibold">
                          {nextRace.name || `Round ${nextRace.roundNumber}`}
                        </h3>
                        <p className="text-muted-foreground">
                          {nextRace.track.name}
                        </p>
                        <p className="text-sm">
                          {formatRaceDateTime(nextRace.scheduledAt, league.timezone)}
                        </p>
                        <div className="flex gap-2 mt-4">
                          {nextRace.hasQuali && (
                            <Badge variant="outline">{tRound('qualifying')}</Badge>
                          )}
                          {nextRace.hasSprint && (
                            <Badge variant="papaya">{tRound('sprint')}</Badge>
                          )}
                          <Badge variant="f1">{tRound('race')}</Badge>
                        </div>
                      </div>
                    ) : (
                      <p className="text-muted-foreground">No upcoming races</p>
                    )}
                  </CardContent>
                </Card>

                {/* Quick Stats */}
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Trophy className="h-5 w-5 text-brand-red" />
                      Season Progress
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-4">
                      <div>
                        <div className="flex justify-between text-sm mb-1">
                          <span>Races Completed</span>
                          <span>{completedRounds.length}/{league.rounds.length}</span>
                        </div>
                        <div className="h-2 rounded-full bg-muted">
                          <div 
                            className="h-full rounded-full bg-brand-red"
                            style={{ 
                              width: `${(completedRounds.length / league.rounds.length) * 100}%` 
                            }}
                          />
                        </div>
                      </div>
                      <Button asChild variant="outline" className="w-full">
                        <Link href={`/leagues/${slug}/standings`}>
                          View Full Standings
                          <ChevronRight className="ml-2 h-4 w-4" />
                        </Link>
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </div>

              {/* Teams Preview */}
              <Card>
                <CardHeader className="flex flex-row items-center justify-between">
                  <CardTitle>{t('teams')}</CardTitle>
                  <Button asChild variant="ghost" size="sm">
                    <Link href={`/leagues/${slug}/teams`}>
                      View All
                      <ChevronRight className="ml-1 h-4 w-4" />
                    </Link>
                  </Button>
                </CardHeader>
                <CardContent>
                  <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                    {league.teams.slice(0, 4).map((team) => (
                      <div 
                        key={team.id} 
                        className="p-4 rounded-lg border"
                        style={{ borderLeftColor: team.primaryColor || '#E10600', borderLeftWidth: 4 }}
                      >
                        <h4 className="font-semibold">{team.name}</h4>
                        <p className="text-sm text-muted-foreground">
                          {team.drivers.length} drivers
                        </p>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Schedule Tab */}
            <TabsContent value="schedule">
              <Card>
                <CardHeader>
                  <CardTitle>{t('schedule')}</CardTitle>
                  <CardDescription>
                    All rounds for this championship
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {league.rounds.map((round) => (
                      <div 
                        key={round.id}
                        className="flex items-center justify-between p-4 rounded-lg border"
                      >
                        <div className="flex items-center gap-4">
                          <div className="flex h-10 w-10 items-center justify-center rounded-full bg-muted font-bold">
                            {round.roundNumber}
                          </div>
                          <div>
                            <h4 className="font-semibold">
                              {round.name || `Round ${round.roundNumber}`}
                            </h4>
                            <p className="text-sm text-muted-foreground">
                              {round.track.name}, {round.track.country}
                            </p>
                          </div>
                        </div>
                        <div className="flex items-center gap-4">
                          <div className="text-right">
                            <p className="text-sm">
                              {formatRaceDateTime(round.scheduledAt, league.timezone)}
                            </p>
                            <div className="flex gap-1 mt-1">
                              {round.hasSprint && (
                                <Badge variant="papaya" className="text-xs">Sprint</Badge>
                              )}
                            </div>
                          </div>
                          <Badge 
                            variant={
                              round.status === 'COMPLETED' ? 'success' :
                              round.status === 'ANNULLED' ? 'destructive' : 'outline'
                            }
                          >
                            {round.status === 'COMPLETED' ? tRound('completed') :
                             round.status === 'ANNULLED' ? tRound('annulled') : tRound('scheduled')}
                          </Badge>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Standings Tab */}
            <TabsContent value="standings">
              <div className="grid gap-6 md:grid-cols-2">
                <Card>
                  <CardHeader>
                    <CardTitle>{tStandings('driverStandings')}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-muted-foreground">
                      Standings will appear here once results are entered.
                    </p>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader>
                    <CardTitle>{tStandings('constructorStandings')}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-muted-foreground">
                      Standings will appear here once results are entered.
                    </p>
                  </CardContent>
                </Card>
              </div>
            </TabsContent>

            {/* Teams Tab */}
            <TabsContent value="teams">
              <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
                {league.teams.map((team) => (
                  <Card key={team.id}>
                    <CardHeader>
                      <div className="flex items-center gap-3">
                        <div 
                          className="h-12 w-2 rounded-full"
                          style={{ backgroundColor: team.primaryColor || '#E10600' }}
                        />
                        <div>
                          <CardTitle className="text-lg">{team.name}</CardTitle>
                          {team.country && (
                            <CardDescription>{team.country}</CardDescription>
                          )}
                        </div>
                      </div>
                    </CardHeader>
                    <CardContent>
                      <div className="space-y-2">
                        {team.drivers.map((driver) => (
                          <div 
                            key={driver.id}
                            className="flex items-center justify-between py-2"
                          >
                            <div className="flex items-center gap-2">
                              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-muted text-sm font-bold">
                                {driver.number || driver.shortName || '?'}
                              </div>
                              <div>
                                <p className="font-medium">{driver.fullName}</p>
                                <p className="text-xs text-muted-foreground">
                                  {driver.gamertag}
                                </p>
                              </div>
                            </div>
                            {driver.isReserve && (
                              <Badge variant="outline" className="text-xs">Reserve</Badge>
                            )}
                          </div>
                        ))}
                        {team.drivers.length === 0 && (
                          <p className="text-sm text-muted-foreground">No drivers assigned</p>
                        )}
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </TabsContent>

            {/* Results Tab */}
            <TabsContent value="results">
              <Card>
                <CardHeader>
                  <CardTitle>{t('results')}</CardTitle>
                  <CardDescription>
                    Race results for completed rounds
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  {completedRounds.length === 0 ? (
                    <p className="text-muted-foreground">
                      No results available yet.
                    </p>
                  ) : (
                    <div className="space-y-4">
                      {completedRounds.map((round) => (
                        <Link 
                          key={round.id}
                          href={`/leagues/${slug}/results/${round.roundNumber}`}
                          className="block p-4 rounded-lg border hover:bg-muted/50 transition-colors"
                        >
                          <div className="flex items-center justify-between">
                            <div>
                              <h4 className="font-semibold">
                                Round {round.roundNumber}: {round.name || round.track.name}
                              </h4>
                              <p className="text-sm text-muted-foreground">
                                {round.track.country}
                              </p>
                            </div>
                            <ChevronRight className="h-5 w-5 text-muted-foreground" />
                          </div>
                        </Link>
                      ))}
                    </div>
                  )}
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </div>
      </main>

      <Footer />
    </div>
  );
}
