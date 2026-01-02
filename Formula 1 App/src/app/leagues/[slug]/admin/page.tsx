import { Metadata } from 'next';
import { notFound, redirect } from 'next/navigation';
import Link from 'next/link';
import { getTranslations } from 'next-intl/server';
import { 
  Settings, 
  Calendar, 
  Trophy, 
  Users, 
  Flag, 
  ClipboardList,
  Bell,
  BarChart3,
  MessageSquare,
  ChevronLeft,
  Save,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Header } from '@/components/layout/header';
import { Footer } from '@/components/layout/footer';
import prisma from '@/lib/db';
import { createClient } from '@/lib/supabase/server';

interface AdminPageProps {
  params: Promise<{ slug: string }>;
}

export async function generateMetadata({ params }: AdminPageProps): Promise<Metadata> {
  const { slug } = await params;
  const league = await prisma.league.findUnique({
    where: { slug },
    select: { name: true },
  });

  return {
    title: league ? `Admin - ${league.name}` : 'Admin',
  };
}

export default async function LeagueAdminPage({ params }: AdminPageProps) {
  const { slug } = await params;
  const t = await getTranslations('admin');
  
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    redirect('/auth/signin');
  }

  const league = await prisma.league.findUnique({
    where: { slug },
    include: {
      teams: {
        include: {
          drivers: true,
        },
        orderBy: { name: 'asc' },
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

  // Fetch scoring configuration separately
  const scoring = await prisma.scoring.findUnique({
    where: { leagueId: league.id },
  });

  // Check if user is admin or owner
  const membership = league.memberships.find(m => m.userId === user.id);
  const isAdmin = membership?.role === 'ADMIN' || membership?.role === 'OWNER';

  if (!isAdmin) {
    redirect(`/leagues/${slug}`);
  }

  const totalDrivers = league.teams.reduce((acc: number, t: { drivers: unknown[] }) => acc + t.drivers.length, 0);

  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      
      <main className="flex-1">
        {/* Admin Header */}
        <div className="border-b bg-muted/50">
          <div className="container mx-auto px-4 py-6 sm:px-6 lg:px-8">
            <div className="flex items-center gap-4">
              <Button asChild variant="ghost" size="sm">
                <Link href={`/leagues/${slug}`}>
                  <ChevronLeft className="mr-1 h-4 w-4" />
                  Back
                </Link>
              </Button>
              <div>
                <h1 className="text-2xl font-bold tracking-tight flex items-center gap-2">
                  <Settings className="h-6 w-6" />
                  {t('title')}
                </h1>
                <p className="text-muted-foreground">{league.name}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Admin Content */}
        <div className="container mx-auto px-4 py-8 sm:px-6 lg:px-8">
          <Tabs defaultValue="general" className="space-y-6">
            <TabsList className="flex-wrap">
              <TabsTrigger value="general">
                <Settings className="mr-2 h-4 w-4" />
                {t('general')}
              </TabsTrigger>
              <TabsTrigger value="calendar">
                <Calendar className="mr-2 h-4 w-4" />
                {t('calendar')}
              </TabsTrigger>
              <TabsTrigger value="scoring">
                <Trophy className="mr-2 h-4 w-4" />
                {t('scoring')}
              </TabsTrigger>
              <TabsTrigger value="teams">
                <Flag className="mr-2 h-4 w-4" />
                {t('teams')}
              </TabsTrigger>
              <TabsTrigger value="drivers">
                <Users className="mr-2 h-4 w-4" />
                {t('drivers')}
              </TabsTrigger>
              <TabsTrigger value="results">
                <ClipboardList className="mr-2 h-4 w-4" />
                {t('results')}
              </TabsTrigger>
              <TabsTrigger value="webhooks">
                <Bell className="mr-2 h-4 w-4" />
                {t('webhooks')}
              </TabsTrigger>
              <TabsTrigger value="analytics">
                <BarChart3 className="mr-2 h-4 w-4" />
                {t('analytics')}
              </TabsTrigger>
              <TabsTrigger value="ai">
                <MessageSquare className="mr-2 h-4 w-4" />
                {t('aiAssistant')}
              </TabsTrigger>
            </TabsList>

            {/* General Settings Tab */}
            <TabsContent value="general">
              <Card>
                <CardHeader>
                  <CardTitle>{t('general')}</CardTitle>
                  <CardDescription>
                    Basic league settings and configuration
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                  <div className="grid gap-4 md:grid-cols-2">
                    <div className="space-y-2">
                      <Label htmlFor="name">League Name</Label>
                      <Input 
                        id="name" 
                        defaultValue={league.name}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="slug">URL Slug</Label>
                      <Input 
                        id="slug" 
                        defaultValue={league.slug}
                      />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="description">Description</Label>
                    <textarea 
                      id="description"
                      className="flex min-h-[100px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                      defaultValue={league.description || ''}
                    />
                  </div>
                  <div className="grid gap-4 md:grid-cols-2">
                    <div className="space-y-2">
                      <Label htmlFor="timezone">Timezone</Label>
                      <Input 
                        id="timezone" 
                        defaultValue={league.timezone}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="visibility">Visibility</Label>
                      <select 
                        id="visibility"
                        className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                        defaultValue={league.visibility}
                      >
                        <option value="PUBLIC">Public</option>
                        <option value="PRIVATE">Private</option>
                      </select>
                    </div>
                  </div>
                  <Button variant="f1">
                    <Save className="mr-2 h-4 w-4" />
                    Save Changes
                  </Button>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Calendar Tab */}
            <TabsContent value="calendar">
              <Card>
                <CardHeader className="flex flex-row items-center justify-between">
                  <div>
                    <CardTitle>{t('calendar')}</CardTitle>
                    <CardDescription>
                      Manage your championship calendar
                    </CardDescription>
                  </div>
                  <Button variant="f1">
                    Add Round
                  </Button>
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
                              {round.track.name}
                            </p>
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <Badge variant={round.status === 'COMPLETED' ? 'success' : 'outline'}>
                            {round.status}
                          </Badge>
                          <Button variant="outline" size="sm">Edit</Button>
                        </div>
                      </div>
                    ))}
                    {league.rounds.length === 0 && (
                      <p className="text-center text-muted-foreground py-8">
                        No rounds in the calendar yet.
                      </p>
                    )}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Scoring Tab */}
            <TabsContent value="scoring">
              <Card>
                <CardHeader>
                  <CardTitle>{t('scoring')}</CardTitle>
                  <CardDescription>
                    Configure points distribution for each session type
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  {scoring ? (
                    <div className="space-y-6">
                      <div>
                        <h4 className="font-semibold mb-2">Race Points</h4>
                        <div className="flex flex-wrap gap-2">
                          {Object.entries(scoring.racePoints as Record<string, number>).map(([pos, points]) => (
                            <div 
                              key={pos}
                              className="flex items-center gap-1 px-3 py-1 rounded-lg bg-muted"
                            >
                              <span className="font-medium">P{pos}:</span>
                              <span>{points}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                      <div>
                        <h4 className="font-semibold mb-2">Sprint Points</h4>
                        <div className="flex flex-wrap gap-2">
                          {Object.entries(scoring.sprintPoints as Record<string, number>).map(([pos, points]) => (
                            <div 
                              key={pos}
                              className="flex items-center gap-1 px-3 py-1 rounded-lg bg-muted"
                            >
                              <span className="font-medium">P{pos}:</span>
                              <span>{points}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                      <div>
                        <h4 className="font-semibold mb-2">Bonus Points</h4>
                        <div className="flex flex-wrap gap-4">
                          <div className="px-3 py-1 rounded-lg bg-muted">
                            <span className="font-medium">Fastest Lap:</span>{' '}
                            {scoring.fastestLapPoints}
                          </div>
                          <div className="px-3 py-1 rounded-lg bg-muted">
                            <span className="font-medium">Pole Position:</span>{' '}
                            {scoring.polePositionPoints}
                          </div>
                        </div>
                      </div>
                      <Button variant="outline">Edit Scoring</Button>
                    </div>
                  ) : (
                    <div className="text-center py-8">
                      <p className="text-muted-foreground mb-4">
                        No scoring configuration set up yet.
                      </p>
                      <Button variant="f1">Set Up Scoring</Button>
                    </div>
                  )}
                </CardContent>
              </Card>
            </TabsContent>

            {/* Teams Tab */}
            <TabsContent value="teams">
              <Card>
                <CardHeader className="flex flex-row items-center justify-between">
                  <div>
                    <CardTitle>{t('teams')}</CardTitle>
                    <CardDescription>
                      Manage teams in your league ({league.teams.length} teams)
                    </CardDescription>
                  </div>
                  <Button variant="f1">Add Team</Button>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {league.teams.map((team) => (
                      <div 
                        key={team.id}
                        className="flex items-center justify-between p-4 rounded-lg border"
                        style={{ borderLeftColor: team.primaryColor || '#E10600', borderLeftWidth: 4 }}
                      >
                        <div className="flex items-center gap-4">
                          <div>
                            <h4 className="font-semibold">{team.name}</h4>
                            <p className="text-sm text-muted-foreground">
                              {team.drivers.length} drivers
                            </p>
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <Badge variant={team.isActive ? 'success' : 'secondary'}>
                            {team.isActive ? 'Active' : 'Inactive'}
                          </Badge>
                          <Button variant="outline" size="sm">Edit</Button>
                        </div>
                      </div>
                    ))}
                    {league.teams.length === 0 && (
                      <p className="text-center text-muted-foreground py-8">
                        No teams added yet.
                      </p>
                    )}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Drivers Tab */}
            <TabsContent value="drivers">
              <Card>
                <CardHeader className="flex flex-row items-center justify-between">
                  <div>
                    <CardTitle>{t('drivers')}</CardTitle>
                    <CardDescription>
                      Manage drivers across all teams ({totalDrivers} drivers)
                    </CardDescription>
                  </div>
                  <Button variant="f1">Add Driver</Button>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {league.teams.flatMap(team => 
                      team.drivers.map(driver => (
                        <div 
                          key={driver.id}
                          className="flex items-center justify-between p-4 rounded-lg border"
                        >
                          <div className="flex items-center gap-4">
                            <div 
                              className="flex h-10 w-10 items-center justify-center rounded-full text-white font-bold"
                              style={{ backgroundColor: team.primaryColor || '#E10600' }}
                            >
                              {driver.number || driver.shortName?.slice(0, 2) || '?'}
                            </div>
                            <div>
                              <h4 className="font-semibold">{driver.fullName}</h4>
                              <p className="text-sm text-muted-foreground">
                                {team.name} • {driver.gamertag}
                              </p>
                            </div>
                          </div>
                          <div className="flex items-center gap-2">
                            {driver.isReserve && (
                              <Badge variant="outline">Reserve</Badge>
                            )}
                            <Badge variant={driver.isActive ? 'success' : 'secondary'}>
                              {driver.isActive ? 'Active' : 'Inactive'}
                            </Badge>
                            <Button variant="outline" size="sm">Edit</Button>
                          </div>
                        </div>
                      ))
                    )}
                    {totalDrivers === 0 && (
                      <p className="text-center text-muted-foreground py-8">
                        No drivers added yet.
                      </p>
                    )}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Results Tab */}
            <TabsContent value="results">
              <Card>
                <CardHeader className="flex flex-row items-center justify-between">
                  <div>
                    <CardTitle>{t('results')}</CardTitle>
                    <CardDescription>
                      Enter and manage race results
                    </CardDescription>
                  </div>
                  <div className="flex gap-2">
                    <Button variant="outline">Import CSV</Button>
                    <Button variant="f1">Add Result</Button>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {league.rounds.map((round) => (
                      <div 
                        key={round.id}
                        className="flex items-center justify-between p-4 rounded-lg border"
                      >
                        <div>
                          <h4 className="font-semibold">
                            Round {round.roundNumber}: {round.name || round.track.name}
                          </h4>
                          <p className="text-sm text-muted-foreground">
                            {round.track.country}
                          </p>
                        </div>
                        <div className="flex items-center gap-2">
                          <Badge variant={round.status === 'COMPLETED' ? 'success' : 'outline'}>
                            {round.status}
                          </Badge>
                          <Button variant="outline" size="sm">
                            {round.status === 'COMPLETED' ? 'View Results' : 'Enter Results'}
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Webhooks Tab */}
            <TabsContent value="webhooks">
              <Card>
                <CardHeader>
                  <CardTitle>{t('webhooks')}</CardTitle>
                  <CardDescription>
                    Configure Discord notifications
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="discord">Discord Webhook URL</Label>
                    <Input 
                      id="discord" 
                      type="url"
                      placeholder="https://discord.com/api/webhooks/..."
                      defaultValue={league.discordWebhookUrl || ''}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>Notification Events</Label>
                    <div className="space-y-2">
                      <label className="flex items-center gap-2">
                        <input type="checkbox" defaultChecked={league.discordNotifyResults} />
                        <span>Race results posted</span>
                      </label>
                      <label className="flex items-center gap-2">
                        <input type="checkbox" defaultChecked={league.discordNotifyRaces} />
                        <span>Race schedule reminders</span>
                      </label>
                      <label className="flex items-center gap-2">
                        <input type="checkbox" />
                        <span>New member joined</span>
                      </label>
                    </div>
                  </div>
                  <Button variant="f1">
                    <Save className="mr-2 h-4 w-4" />
                    Save Webhook Settings
                  </Button>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Analytics Tab */}
            <TabsContent value="analytics">
              <Card>
                <CardHeader>
                  <CardTitle>{t('analytics')}</CardTitle>
                  <CardDescription>
                    League statistics and insights
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="grid gap-4 md:grid-cols-3">
                    <div className="p-4 rounded-lg border text-center">
                      <p className="text-3xl font-bold">{league.memberships.length}</p>
                      <p className="text-muted-foreground">Members</p>
                    </div>
                    <div className="p-4 rounded-lg border text-center">
                      <p className="text-3xl font-bold">{league.teams.length}</p>
                      <p className="text-muted-foreground">Teams</p>
                    </div>
                    <div className="p-4 rounded-lg border text-center">
                      <p className="text-3xl font-bold">{totalDrivers}</p>
                      <p className="text-muted-foreground">Drivers</p>
                    </div>
                  </div>
                  <div className="mt-6 p-8 rounded-lg border text-center text-muted-foreground">
                    <BarChart3 className="h-12 w-12 mx-auto mb-4 opacity-50" />
                    <p>Charts and detailed analytics will appear here once you have more race data.</p>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* AI Assistant Tab */}
            <TabsContent value="ai">
              <Card>
                <CardHeader>
                  <CardTitle>{t('aiAssistant')}</CardTitle>
                  <CardDescription>
                    AI-powered assistance for league management
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="p-4 rounded-lg border bg-muted/50">
                      <p className="text-sm text-muted-foreground mb-2">
                        Ask the AI assistant about your league:
                      </p>
                      <ul className="text-sm space-y-1 list-disc list-inside text-muted-foreground">
                        <li>"Who has the most wins this season?"</li>
                        <li>"What are our league rules?"</li>
                        <li>"Predict the next race winner based on recent form"</li>
                        <li>"Generate a summary of Round 5 results"</li>
                      </ul>
                    </div>
                    <div className="flex gap-2">
                      <Input 
                        placeholder="Ask the AI assistant..."
                        className="flex-1"
                      />
                      <Button variant="f1">
                        <MessageSquare className="mr-2 h-4 w-4" />
                        Ask
                      </Button>
                    </div>
                    <div className="p-8 rounded-lg border text-center text-muted-foreground">
                      <MessageSquare className="h-12 w-12 mx-auto mb-4 opacity-50" />
                      <p>AI responses will appear here.</p>
                    </div>
                  </div>
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
