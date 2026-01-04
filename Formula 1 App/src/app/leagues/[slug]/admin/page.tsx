import { Metadata } from 'next';
import { notFound, redirect } from 'next/navigation';
import Link from 'next/link';
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
  Crown,
  Gamepad2,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { DashboardLayout } from '@/components/layout/dashboard-layout';
import prisma from '@/lib/db';
import { createClient } from '@/lib/supabase/server';
import { LeagueRole } from '@prisma/client';

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

// Helper to get DB user
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

export default async function LeagueAdminPage({ params }: AdminPageProps) {
  const { slug } = await params;
  
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    redirect('/auth/signin');
  }

  const dbUser = await getDbUser(user);

  const league = await prisma.league.findUnique({
    where: { slug },
    include: {
      members: {
        include: {
          user: {
            select: { id: true, fullName: true, email: true, avatar: true },
          },
        },
      },
      championships: {
        orderBy: { createdAt: 'desc' },
        include: {
          teams: {
            include: {
              drivers: true,
              f1Team: true,
            },
            orderBy: { createdAt: 'asc' },
          },
          races: {
            orderBy: { roundNumber: 'asc' },
            include: {
              track: true,
            },
          },
          assists: true,
          scoring: true,
          _count: {
            select: { teams: true, drivers: true, races: true },
          },
        },
      },
    },
  });

  if (!league) {
    notFound();
  }

  // Check if user is admin or owner
  const membership = dbUser ? league.members.find(m => m.userId === dbUser.id) : null;
  const isAdmin = membership?.role === LeagueRole.ADMIN || membership?.role === LeagueRole.OWNER;

  if (!isAdmin) {
    redirect(`/leagues/${slug}`);
  }

  // Get active championship
  const activeChampionship = league.championships[0];
  const totalDrivers = activeChampionship?.teams.reduce((acc, t) => acc + t.drivers.length, 0) || 0;

  return (
    <DashboardLayout user={{ email: user.email || '' }}>
      <div className="space-y-6">
        {/* Admin Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Button asChild variant="ghost" size="sm" className="text-gray-400 hover:text-white">
              <Link href={`/leagues/${slug}`}>
                <ChevronLeft className="mr-1 h-4 w-4" />
                Back
              </Link>
            </Button>
            <div>
              <h1 className="text-2xl font-bold tracking-tight text-white flex items-center gap-2">
                <Settings className="h-6 w-6" />
                League Administration
              </h1>
              <p className="text-gray-400">{league.name}</p>
            </div>
          </div>
          {activeChampionship && (
            <Badge className="bg-[#F59E0B]/20 text-[#F59E0B] border-[#F59E0B]/30">
              <Crown className="mr-1 h-3 w-3" />
              {activeChampionship.name}
            </Badge>
          )}
        </div>

        {/* Admin Content */}
        <Tabs defaultValue="general" className="space-y-6">
          <TabsList className="bg-white/5 border border-white/10 p-1 flex-wrap">
            <TabsTrigger value="general" className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white">
              <Settings className="mr-2 h-4 w-4" />
              General
            </TabsTrigger>
            <TabsTrigger value="championship" className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white">
              <Crown className="mr-2 h-4 w-4" />
              Championship
            </TabsTrigger>
            <TabsTrigger value="calendar" className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white">
              <Calendar className="mr-2 h-4 w-4" />
              Calendar
            </TabsTrigger>
            <TabsTrigger value="scoring" className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white">
              <Trophy className="mr-2 h-4 w-4" />
              Scoring
            </TabsTrigger>
            <TabsTrigger value="teams" className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white">
              <Flag className="mr-2 h-4 w-4" />
              Teams
            </TabsTrigger>
            <TabsTrigger value="assists" className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white">
              <Gamepad2 className="mr-2 h-4 w-4" />
              Assists
            </TabsTrigger>
            <TabsTrigger value="results" className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white">
              <ClipboardList className="mr-2 h-4 w-4" />
              Results
            </TabsTrigger>
            <TabsTrigger value="members" className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white">
              <Users className="mr-2 h-4 w-4" />
              Members
            </TabsTrigger>
            <TabsTrigger value="webhooks" className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white">
              <Bell className="mr-2 h-4 w-4" />
              Webhooks
            </TabsTrigger>
          </TabsList>

          {/* General Settings Tab */}
          <TabsContent value="general">
            <Card className="bg-white/[0.03] border-white/10">
              <CardHeader>
                <CardTitle className="text-white">General Settings</CardTitle>
                <CardDescription className="text-gray-400">
                  Basic league settings and configuration
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor="name" className="text-gray-300">League Name</Label>
                    <Input 
                      id="name" 
                      defaultValue={league.name}
                      className="bg-white/5 border-white/10 text-white"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="slug" className="text-gray-300">URL Slug</Label>
                    <Input 
                      id="slug" 
                      defaultValue={league.slug}
                      className="bg-white/5 border-white/10 text-white"
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="description" className="text-gray-300">Description</Label>
                  <textarea 
                    id="description"
                    className="flex min-h-[100px] w-full rounded-md border border-white/10 bg-white/5 px-3 py-2 text-sm text-white placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2ECC71]"
                    defaultValue={league.description || ''}
                  />
                </div>
                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor="timezone" className="text-gray-300">Timezone</Label>
                    <Input 
                      id="timezone" 
                      defaultValue={league.timezone}
                      className="bg-white/5 border-white/10 text-white"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="visibility" className="text-gray-300">Visibility</Label>
                    <select 
                      id="visibility"
                      className="flex h-10 w-full rounded-md border border-white/10 bg-white/5 px-3 py-2 text-sm text-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#2ECC71]"
                      defaultValue={league.isPublic ? 'PUBLIC' : 'PRIVATE'}
                    >
                      <option value="PUBLIC">Public</option>
                      <option value="PRIVATE">Private</option>
                    </select>
                  </div>
                </div>
                <Button className="bg-[#2ECC71] hover:bg-[#27AE60] text-white">
                  <Save className="mr-2 h-4 w-4" />
                  Save Changes
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Championship Tab */}
          <TabsContent value="championship">
            <Card className="bg-white/[0.03] border-white/10">
              <CardHeader className="flex flex-row items-center justify-between">
                <div>
                  <CardTitle className="text-white">Championships</CardTitle>
                  <CardDescription className="text-gray-400">
                    Manage championships in this league
                  </CardDescription>
                </div>
                <Button className="bg-[#2ECC71] hover:bg-[#27AE60] text-white">
                  Create Championship
                </Button>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {league.championships.map((championship) => (
                    <div 
                      key={championship.id}
                      className="flex items-center justify-between p-4 rounded-xl bg-white/[0.02] border border-white/10"
                    >
                      <div className="flex items-center gap-4">
                        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#F59E0B]/20">
                          <Crown className="h-5 w-5 text-[#F59E0B]" />
                        </div>
                        <div>
                          <h4 className="font-semibold text-white">
                            {championship.name}
                          </h4>
                          <p className="text-sm text-gray-500">
                            {championship._count.teams} teams • {championship._count.drivers} drivers • {championship._count.races} races
                          </p>
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        <Badge className={
                          championship.status === 'ACTIVE' 
                            ? 'bg-[#2ECC71]/20 text-[#2ECC71] border-[#2ECC71]/30'
                            : championship.status === 'COMPLETED'
                              ? 'bg-gray-500/20 text-gray-400 border-gray-500/30'
                              : 'bg-[#F59E0B]/20 text-[#F59E0B] border-[#F59E0B]/30'
                        }>
                          {championship.status}
                        </Badge>
                        <Button variant="outline" size="sm" className="border-white/10 text-gray-300 hover:text-white">
                          Manage
                        </Button>
                      </div>
                    </div>
                  ))}
                  {league.championships.length === 0 && (
                    <p className="text-center text-gray-500 py-8">
                      No championships created yet.
                    </p>
                  )}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Calendar Tab */}
          <TabsContent value="calendar">
            <Card className="bg-white/[0.03] border-white/10">
              <CardHeader className="flex flex-row items-center justify-between">
                <div>
                  <CardTitle className="text-white">Race Calendar</CardTitle>
                  <CardDescription className="text-gray-400">
                    Manage races for {activeChampionship?.name || 'active championship'}
                  </CardDescription>
                </div>
                <Button className="bg-[#2ECC71] hover:bg-[#27AE60] text-white">
                  Add Race
                </Button>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {activeChampionship?.races.map((race) => (
                    <div 
                      key={race.id}
                      className="flex items-center justify-between p-4 rounded-xl bg-white/[0.02] border border-white/10"
                    >
                      <div className="flex items-center gap-4">
                        <div className={`flex h-10 w-10 items-center justify-center rounded-xl font-bold ${
                          race.status === 'COMPLETED' ? 'bg-[#2ECC71]/20 text-[#2ECC71]' : 'bg-white/10 text-gray-300'
                        }`}>
                          R{race.roundNumber}
                        </div>
                        <div>
                          <h4 className="font-semibold text-white">
                            {race.name || `Round ${race.roundNumber}`}
                          </h4>
                          <p className="text-sm text-gray-500">
                            {race.track?.name} • {race.scheduledDate ? new Date(race.scheduledDate).toLocaleDateString() : 'TBD'}
                          </p>
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        <Badge className={
                          race.status === 'COMPLETED'
                            ? 'bg-[#2ECC71]/20 text-[#2ECC71] border-[#2ECC71]/30'
                            : race.status === 'CANCELLED'
                              ? 'bg-red-500/20 text-red-400 border-red-500/30'
                              : 'bg-white/10 text-gray-400 border-white/10'
                        }>
                          {race.status}
                        </Badge>
                        <Button variant="outline" size="sm" className="border-white/10 text-gray-300 hover:text-white">
                          Edit
                        </Button>
                      </div>
                    </div>
                  ))}
                  {(!activeChampionship || activeChampionship.races.length === 0) && (
                    <p className="text-center text-gray-500 py-8">
                      No races in the calendar yet.
                    </p>
                  )}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Scoring Tab */}
          <TabsContent value="scoring">
            <Card className="bg-white/[0.03] border-white/10">
              <CardHeader>
                <CardTitle className="text-white">Scoring System</CardTitle>
                <CardDescription className="text-gray-400">
                  Configure points distribution for {activeChampionship?.name || 'active championship'}
                </CardDescription>
              </CardHeader>
              <CardContent>
                {activeChampionship?.scoring ? (
                  <div className="space-y-6">
                    <div>
                      <h4 className="font-semibold text-white mb-3">Race Points</h4>
                      <div className="flex flex-wrap gap-2">
                        {Object.entries(activeChampionship.scoring.racePoints as Record<string, number>).map(([pos, points]) => (
                          <div 
                            key={pos}
                            className="flex items-center gap-1 px-3 py-1 rounded-lg bg-white/5 text-gray-300"
                          >
                            <span className="font-medium">P{pos}:</span>
                            <span>{points}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                    {activeChampionship.scoring.sprintPoints && (
                      <div>
                        <h4 className="font-semibold text-white mb-3">Sprint Points</h4>
                        <div className="flex flex-wrap gap-2">
                          {Object.entries(activeChampionship.scoring.sprintPoints as Record<string, number>).map(([pos, points]) => (
                            <div 
                              key={pos}
                              className="flex items-center gap-1 px-3 py-1 rounded-lg bg-white/5 text-gray-300"
                            >
                              <span className="font-medium">P{pos}:</span>
                              <span>{points}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                    <div>
                      <h4 className="font-semibold text-white mb-3">Bonus Points</h4>
                      <div className="flex flex-wrap gap-4">
                        <div className="px-3 py-1 rounded-lg bg-white/5 text-gray-300">
                          <span className="font-medium">Fastest Lap:</span>{' '}
                          {activeChampionship.scoring.fastestLapBonus}
                        </div>
                        <div className="px-3 py-1 rounded-lg bg-white/5 text-gray-300">
                          <span className="font-medium">Pole Position:</span>{' '}
                          {activeChampionship.scoring.polePositionBonus}
                        </div>
                        <div className="px-3 py-1 rounded-lg bg-white/5 text-gray-300">
                          <span className="font-medium">Driver of the Day:</span>{' '}
                          {activeChampionship.scoring.driverOfTheDayBonus}
                        </div>
                      </div>
                    </div>
                    <Button variant="outline" className="border-white/10 text-gray-300 hover:text-white">
                      Edit Scoring
                    </Button>
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <Trophy className="h-12 w-12 text-gray-600 mx-auto mb-4" />
                    <p className="text-gray-500 mb-4">
                      No scoring configuration set up yet.
                    </p>
                    <Button className="bg-[#2ECC71] hover:bg-[#27AE60] text-white">
                      Set Up Scoring
                    </Button>
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          {/* Teams Tab */}
          <TabsContent value="teams">
            <Card className="bg-white/[0.03] border-white/10">
              <CardHeader className="flex flex-row items-center justify-between">
                <div>
                  <CardTitle className="text-white">Teams & Drivers</CardTitle>
                  <CardDescription className="text-gray-400">
                    Manage teams in {activeChampionship?.name || 'active championship'} ({activeChampionship?._count.teams || 0} teams, {totalDrivers} drivers)
                  </CardDescription>
                </div>
                <Button className="bg-[#2ECC71] hover:bg-[#27AE60] text-white">
                  Add Team
                </Button>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {activeChampionship?.teams.map((team) => (
                    <div 
                      key={team.id}
                      className="relative overflow-hidden rounded-xl bg-white/[0.02] border border-white/10"
                    >
                      <div 
                        className="absolute left-0 top-0 bottom-0 w-1"
                        style={{ backgroundColor: team.f1Team?.primaryColor || '#2ECC71' }}
                      />
                      <div className="p-4 pl-5">
                        <div className="flex items-center justify-between mb-3">
                          <div className="flex items-center gap-3">
                            <div 
                              className="h-10 w-10 rounded-xl flex items-center justify-center text-white font-bold"
                              style={{ backgroundColor: `${team.f1Team?.primaryColor || '#2ECC71'}40` }}
                            >
                              {(team.name || team.f1Team?.name || '').substring(0, 2).toUpperCase()}
                            </div>
                            <div>
                              <h4 className="font-semibold text-white">{team.name || team.f1Team?.name}</h4>
                              <p className="text-sm text-gray-500">
                                {team.drivers.length} drivers
                              </p>
                            </div>
                          </div>
                          <div className="flex items-center gap-2">
                            <Badge className={
                              team.isActive 
                                ? 'bg-[#2ECC71]/20 text-[#2ECC71] border-[#2ECC71]/30'
                                : 'bg-gray-500/20 text-gray-400 border-gray-500/30'
                            }>
                              {team.isActive ? 'Active' : 'Inactive'}
                            </Badge>
                            <Button variant="outline" size="sm" className="border-white/10 text-gray-300 hover:text-white">
                              Edit
                            </Button>
                          </div>
                        </div>
                        <div className="space-y-2">
                          {team.drivers.map((driver) => (
                            <div 
                              key={driver.id}
                              className="flex items-center justify-between py-2 px-3 rounded-lg bg-white/[0.02]"
                            >
                              <div className="flex items-center gap-3">
                                <div 
                                  className="flex h-8 w-8 items-center justify-center rounded-lg text-sm font-bold"
                                  style={{ 
                                    backgroundColor: `${team.f1Team?.primaryColor || '#2ECC71'}30`,
                                    color: team.f1Team?.primaryColor || '#2ECC71'
                                  }}
                                >
                                  {driver.number || '?'}
                                </div>
                                <div>
                                  <p className="font-medium text-white">{driver.fullName}</p>
                                  <p className="text-xs text-gray-500">{driver.gamertag}</p>
                                </div>
                              </div>
                              <div className="flex items-center gap-2">
                                {driver.status === 'RESERVE' && (
                                  <Badge className="text-xs bg-white/10 text-gray-400 border-white/10">
                                    Reserve
                                  </Badge>
                                )}
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>
                  ))}
                  {(!activeChampionship || activeChampionship.teams.length === 0) && (
                    <p className="text-center text-gray-500 py-8">
                      No teams added yet.
                    </p>
                  )}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Assists Tab */}
          <TabsContent value="assists">
            <Card className="bg-white/[0.03] border-white/10">
              <CardHeader>
                <CardTitle className="text-white">Assists Configuration</CardTitle>
                <CardDescription className="text-gray-400">
                  Configure game assists for {activeChampionship?.name || 'active championship'}
                </CardDescription>
              </CardHeader>
              <CardContent>
                {activeChampionship?.assists ? (
                  <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                    {[
                      { label: 'Brake Assist', value: activeChampionship.assists.brakeAssist },
                      { label: 'Traction Control', value: activeChampionship.assists.tractionControl },
                      { label: 'Anti-Lock Brakes', value: activeChampionship.assists.antiLockBrakes ? 'On' : 'Off' },
                      { label: 'Racing Line', value: activeChampionship.assists.racingLine },
                      { label: 'Gearbox', value: activeChampionship.assists.gearbox },
                      { label: 'Pit Assist', value: activeChampionship.assists.pitAssist ? 'On' : 'Off' },
                      { label: 'Pit Release', value: activeChampionship.assists.pitReleaseAssist ? 'On' : 'Off' },
                      { label: 'ERS Assist', value: activeChampionship.assists.ersAssist ? 'On' : 'Off' },
                      { label: 'DRS Assist', value: activeChampionship.assists.drsAssist ? 'On' : 'Off' },
                      { label: 'Dynamic Racing Line', value: activeChampionship.assists.dynamicRacingLine ? 'On' : 'Off' },
                    ].map((assist) => (
                      <div 
                        key={assist.label}
                        className="flex items-center justify-between p-3 rounded-lg bg-white/5"
                      >
                        <span className="text-gray-300">{assist.label}</span>
                        <Badge className="bg-white/10 text-gray-300 border-white/10">
                          {assist.value}
                        </Badge>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <Gamepad2 className="h-12 w-12 text-gray-600 mx-auto mb-4" />
                    <p className="text-gray-500 mb-4">
                      No assists configuration set up yet.
                    </p>
                    <Button className="bg-[#2ECC71] hover:bg-[#27AE60] text-white">
                      Configure Assists
                    </Button>
                  </div>
                )}
                {activeChampionship?.assists && (
                  <Button variant="outline" className="mt-6 border-white/10 text-gray-300 hover:text-white">
                    Edit Assists
                  </Button>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          {/* Results Tab */}
          <TabsContent value="results">
            <Card className="bg-white/[0.03] border-white/10">
              <CardHeader className="flex flex-row items-center justify-between">
                <div>
                  <CardTitle className="text-white">Race Results</CardTitle>
                  <CardDescription className="text-gray-400">
                    Enter and manage race results
                  </CardDescription>
                </div>
                <div className="flex gap-2">
                  <Button variant="outline" className="border-white/10 text-gray-300 hover:text-white">
                    Import CSV
                  </Button>
                  <Button className="bg-[#2ECC71] hover:bg-[#27AE60] text-white">
                    Add Result
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {activeChampionship?.races.map((race) => (
                    <div 
                      key={race.id}
                      className="flex items-center justify-between p-4 rounded-xl bg-white/[0.02] border border-white/10"
                    >
                      <div>
                        <h4 className="font-semibold text-white">
                          Round {race.roundNumber}: {race.name || race.track?.name || 'TBD'}
                        </h4>
                        <p className="text-sm text-gray-500">
                          {race.track?.country || 'Location TBD'}
                        </p>
                      </div>
                      <div className="flex items-center gap-2">
                        <Badge className={
                          race.status === 'COMPLETED'
                            ? 'bg-[#2ECC71]/20 text-[#2ECC71] border-[#2ECC71]/30'
                            : 'bg-white/10 text-gray-400 border-white/10'
                        }>
                          {race.status}
                        </Badge>
                        <Button variant="outline" size="sm" className="border-white/10 text-gray-300 hover:text-white">
                          {race.status === 'COMPLETED' ? 'View Results' : 'Enter Results'}
                        </Button>
                      </div>
                    </div>
                  ))}
                  {(!activeChampionship || activeChampionship.races.length === 0) && (
                    <p className="text-center text-gray-500 py-8">
                      No races to show results for.
                    </p>
                  )}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Members Tab */}
          <TabsContent value="members">
            <Card className="bg-white/[0.03] border-white/10">
              <CardHeader className="flex flex-row items-center justify-between">
                <div>
                  <CardTitle className="text-white">League Members</CardTitle>
                  <CardDescription className="text-gray-400">
                    Manage member roles and permissions
                  </CardDescription>
                </div>
                <Button className="bg-[#2ECC71] hover:bg-[#27AE60] text-white">
                  Invite Member
                </Button>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {league.members.map((member) => (
                    <div 
                      key={member.id}
                      className="flex items-center justify-between p-4 rounded-xl bg-white/[0.02] border border-white/10"
                    >
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-full bg-white/10 flex items-center justify-center text-white font-bold">
                          {member.user.fullName?.charAt(0) || member.user.email?.charAt(0) || '?'}
                        </div>
                        <div>
                          <p className="font-medium text-white">
                            {member.user.fullName || member.user.email}
                          </p>
                          <p className="text-xs text-gray-500">
                            {member.user.email}
                          </p>
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        <Badge className={
                          member.role === 'OWNER'
                            ? 'bg-[#F59E0B]/20 text-[#F59E0B] border-[#F59E0B]/30'
                            : member.role === 'ADMIN'
                              ? 'bg-[#3B82F6]/20 text-[#3B82F6] border-[#3B82F6]/30'
                              : 'bg-white/10 text-gray-400 border-white/10'
                        }>
                          {member.role}
                        </Badge>
                        {member.role !== 'OWNER' && (
                          <Button variant="outline" size="sm" className="border-white/10 text-gray-300 hover:text-white">
                            Edit
                          </Button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Webhooks Tab */}
          <TabsContent value="webhooks">
            <Card className="bg-white/[0.03] border-white/10">
              <CardHeader>
                <CardTitle className="text-white">Discord Webhooks</CardTitle>
                <CardDescription className="text-gray-400">
                  Configure Discord notifications
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="discord" className="text-gray-300">Discord Webhook URL</Label>
                  <Input 
                    id="discord" 
                    type="url"
                    placeholder="https://discord.com/api/webhooks/..."
                    defaultValue={league.discordWebhookUrl || ''}
                    className="bg-white/5 border-white/10 text-white"
                  />
                </div>
                <div className="space-y-2">
                  <Label className="text-gray-300">Notification Events</Label>
                  <div className="space-y-2">
                    <label className="flex items-center gap-2 text-gray-300">
                      <input type="checkbox" defaultChecked={league.discordNotifyResults} className="rounded" />
                      <span>Race results posted</span>
                    </label>
                    <label className="flex items-center gap-2 text-gray-300">
                      <input type="checkbox" defaultChecked={league.discordNotifyRaces} className="rounded" />
                      <span>Race schedule reminders</span>
                    </label>
                    <label className="flex items-center gap-2 text-gray-300">
                      <input type="checkbox" className="rounded" />
                      <span>New member joined</span>
                    </label>
                  </div>
                </div>
                <Button className="bg-[#2ECC71] hover:bg-[#27AE60] text-white">
                  <Save className="mr-2 h-4 w-4" />
                  Save Webhook Settings
                </Button>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </DashboardLayout>
  );
}
