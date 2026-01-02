import { Metadata } from "next";
import { notFound, redirect } from "next/navigation";
import Link from "next/link";
import { getTranslations } from "next-intl/server";
import {
  Calendar,
  Trophy,
  Users,
  Settings,
  Flag,
  Clock,
  ChevronRight,
  Globe,
  Sparkles,
  Bot,
  MapPin,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { DashboardLayout } from "@/components/layout/dashboard-layout";
import { createClient } from "@/lib/supabase/server";
import prisma from "@/lib/db";
import { formatRaceDateTime } from "@/lib/date-utils";

interface LeaguePageProps {
  params: Promise<{ slug: string }>;
}

export async function generateMetadata({
  params,
}: LeaguePageProps): Promise<Metadata> {
  const { slug } = await params;
  const league = await prisma.league.findUnique({
    where: { slug },
  });

  if (!league) {
    return { title: "League Not Found" };
  }

  return {
    title: league.name,
    description: league.description || `F1 League: ${league.name}`,
  };
}

export default async function LeaguePage({ params }: LeaguePageProps) {
  const { slug } = await params;
  const t = await getTranslations("league");
  const tRound = await getTranslations("round");
  const tStandings = await getTranslations("standings");

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
        orderBy: { roundNumber: "asc" },
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

  // Calculate Driver Standings
  const driverStandings = await prisma.result.groupBy({
    by: ["driverId"],
    where: {
      round: {
        leagueId: league.id,
        status: "COMPLETED",
      },
    },
    _sum: {
      points: true,
    },
    orderBy: {
      _sum: {
        points: "desc",
      },
    },
  });

  // Get driver details for standings
  const driverIds = driverStandings.map((d) => d.driverId);
  const drivers = await prisma.driver.findMany({
    where: { id: { in: driverIds } },
    include: { team: true },
  });
  const driverMap = new Map(drivers.map((d) => [d.id, d]));

  const driverStandingsWithDetails = driverStandings.map((standing, index) => ({
    position: index + 1,
    driver: driverMap.get(standing.driverId),
    points: standing._sum.points || 0,
  }));

  // Calculate Constructor Standings
  const constructorStandings = await prisma.result.groupBy({
    by: ["teamId"],
    where: {
      round: {
        leagueId: league.id,
        status: "COMPLETED",
      },
    },
    _sum: {
      points: true,
    },
    orderBy: {
      _sum: {
        points: "desc",
      },
    },
  });

  // Get team details for standings
  const teamIds = constructorStandings.map((t) => t.teamId);
  const teams = await prisma.team.findMany({
    where: { id: { in: teamIds } },
  });
  const teamMap = new Map(teams.map((t) => [t.id, t]));

  const constructorStandingsWithDetails = constructorStandings.map(
    (standing, index) => ({
      position: index + 1,
      team: teamMap.get(standing.teamId),
      points: standing._sum.points || 0,
    })
  );

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/auth/signin");
  }

  const upcomingRounds = league.rounds.filter(
    (r) => r.status === "SCHEDULED" && new Date(r.scheduledAt) > new Date(),
  );
  const nextRace = upcomingRounds[0];
  const completedRounds = league.rounds.filter((r) => r.status === "COMPLETED");
  const totalDrivers = league.teams.reduce(
    (acc, t) => acc + t.drivers.length,
    0,
  );

  return (
    <DashboardLayout user={{ email: user.email || "" }}>
      <div className="space-y-6">
        {/* League Header */}
        <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10 p-6">
          <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-[#2ECC71] to-[#27AE60]" />
          <div className="flex flex-col gap-6 lg:flex-row lg:items-start lg:justify-between">
            <div className="flex-1">
              <div className="flex items-center gap-2 mb-4">
                <Badge
                  className={
                    league.visibility === "PUBLIC"
                      ? "bg-[#2ECC71]/10 text-[#2ECC71] border-[#2ECC71]/30"
                      : "bg-gray-800 text-gray-400 border-gray-700"
                  }
                >
                  <Globe className="mr-1 h-3 w-3" />
                  {league.visibility === "PUBLIC" ? t("public") : t("private")}
                </Badge>
                <Badge className="bg-white/5 text-gray-400 border-white/10">
                  <Clock className="mr-1 h-3 w-3" />
                  {league.timezone}
                </Badge>
              </div>
              <h1 className="text-3xl md:text-4xl font-bold tracking-tight text-white mb-3">
                {league.name}
              </h1>
              {league.description && (
                <p className="text-gray-400 max-w-2xl text-lg">
                  {league.description}
                </p>
              )}
            </div>
            <div className="flex gap-3">
              <Button
                asChild
                variant="outline"
                className="border-white/10 text-gray-300 hover:text-white hover:bg-white/5 hover:border-white/20"
              >
                <Link href={`/leagues/${slug}/admin`}>
                  <Settings className="mr-2 h-4 w-4" />
                  Admin
                </Link>
              </Button>
              <Button className="bg-gradient-to-r from-[#2ECC71] to-[#27AE60] text-white font-semibold hover:from-[#27AE60] hover:to-[#229954] shadow-lg shadow-[#2ECC71]/20">
                Join League
              </Button>
            </div>
          </div>
          <div className="mt-8 grid grid-cols-2 gap-4 sm:grid-cols-4">
            {[
              {
                icon: Users,
                value: league.memberships.length,
                label: t("members"),
                color: "#2ECC71",
              },
              {
                icon: Flag,
                value: league.teams.length,
                label: t("teams"),
                color: "#3B82F6",
              },
              {
                icon: Trophy,
                value: totalDrivers,
                label: t("drivers"),
                color: "#F59E0B",
              },
              {
                icon: Calendar,
                value: `${completedRounds.length}/${league.rounds.length}`,
                label: "Rounds",
                color: "#8B5CF6",
              },
            ].map((stat, i) => (
              <div
                key={i}
                className="relative overflow-hidden rounded-xl bg-white/[0.03] border border-white/10 p-4"
              >
                <div className="flex items-center gap-3">
                  <div
                    className="flex h-10 w-10 items-center justify-center rounded-lg"
                    style={{ backgroundColor: `${stat.color}20` }}
                  >
                    <stat.icon
                      className="h-5 w-5"
                      style={{ color: stat.color }}
                    />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-white">
                      {stat.value}
                    </p>
                    <p className="text-sm text-gray-500">{stat.label}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Tabs */}
        <Tabs defaultValue="overview" className="space-y-6">
          <TabsList className="bg-white/5 border border-white/10 p-1">
            <TabsTrigger
              value="overview"
              className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white"
            >
              {t("overview")}
            </TabsTrigger>
            <TabsTrigger
              value="schedule"
              className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white"
            >
              {t("schedule")}
            </TabsTrigger>
            <TabsTrigger
              value="standings"
              className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white"
            >
              {t("standings")}
            </TabsTrigger>
            <TabsTrigger
              value="teams"
              className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white"
            >
              {t("teams")}
            </TabsTrigger>
            <TabsTrigger
              value="results"
              className="data-[state=active]:bg-[#2ECC71] data-[state=active]:text-white"
            >
              {t("results")}
            </TabsTrigger>
          </TabsList>

          <TabsContent value="overview" className="space-y-6">
            <div className="grid gap-6 md:grid-cols-2">
              <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10 p-6">
                <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-[#2ECC71] to-[#27AE60]" />
                <div className="flex items-center gap-2 mb-4">
                  <Clock className="h-5 w-5 text-[#2ECC71]" />
                  <h3 className="text-lg font-semibold text-white">
                    Next Race
                  </h3>
                </div>
                {nextRace ? (
                  <div className="space-y-3">
                    <h4 className="text-2xl font-bold text-white">
                      {nextRace.name || `Round ${nextRace.roundNumber}`}
                    </h4>
                    <div className="flex items-center gap-2 text-gray-400">
                      <MapPin className="h-4 w-4" />
                      <span>{nextRace.track.name}</span>
                    </div>
                    <p className="text-sm text-gray-500">
                      {formatRaceDateTime(
                        nextRace.scheduledAt,
                        league.timezone,
                      )}
                    </p>
                    <div className="flex gap-2 mt-4">
                      {nextRace.hasQuali && (
                        <Badge className="bg-blue-500/20 text-blue-400 border-blue-500/30">
                          {tRound("qualifying")}
                        </Badge>
                      )}
                      {nextRace.hasSprint && (
                        <Badge className="bg-orange-500/20 text-orange-400 border-orange-500/30">
                          {tRound("sprint")}
                        </Badge>
                      )}
                      <Badge className="bg-[#2ECC71]/20 text-[#2ECC71] border-[#2ECC71]/30">
                        {tRound("race")}
                      </Badge>
                    </div>
                  </div>
                ) : (
                  <p className="text-gray-500">No upcoming races scheduled</p>
                )}
              </div>

              <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10 p-6">
                <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-[#F59E0B] to-[#D97706]" />
                <div className="flex items-center gap-2 mb-4">
                  <Trophy className="h-5 w-5 text-[#F59E0B]" />
                  <h3 className="text-lg font-semibold text-white">
                    Season Progress
                  </h3>
                </div>
                <div className="space-y-4">
                  <div>
                    <div className="flex justify-between text-sm mb-2">
                      <span className="text-gray-400">Races Completed</span>
                      <span className="text-white font-medium">
                        {completedRounds.length}/{league.rounds.length}
                      </span>
                    </div>
                    <div className="h-3 rounded-full bg-white/10 overflow-hidden">
                      <div
                        className="h-full rounded-full bg-gradient-to-r from-[#2ECC71] to-[#27AE60]"
                        style={{
                          width: `${league.rounds.length > 0 ? (completedRounds.length / league.rounds.length) * 100 : 0}%`,
                        }}
                      />
                    </div>
                  </div>
                  <Button
                    asChild
                    variant="outline"
                    className="w-full border-white/10 text-gray-300 hover:text-white hover:bg-white/5"
                  >
                    <Link href={`/leagues/${slug}/standings`}>
                      View Full Standings
                      <ChevronRight className="ml-2 h-4 w-4" />
                    </Link>
                  </Button>
                </div>
              </div>
            </div>

            <div className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-[#2ECC71]/10 to-[#27AE60]/5 border border-[#2ECC71]/20 p-6">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <div className="h-12 w-12 rounded-xl bg-[#2ECC71]/20 flex items-center justify-center">
                    <Bot className="h-6 w-6 text-[#2ECC71]" />
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold text-white flex items-center gap-2">
                      AI Assistant
                      <Sparkles className="h-4 w-4 text-[#2ECC71]" />
                    </h3>
                    <p className="text-sm text-gray-400">
                      Get insights, predictions, and stats powered by AI
                    </p>
                  </div>
                </div>
                <Button className="bg-[#2ECC71] text-white hover:bg-[#27AE60]">
                  Ask AI
                </Button>
              </div>
            </div>

            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <h3 className="text-xl font-semibold text-white">
                  {t("teams")}
                </h3>
                <Button
                  asChild
                  variant="ghost"
                  size="sm"
                  className="text-gray-400 hover:text-white"
                >
                  <Link href={`/leagues/${slug}/teams`}>
                    View All
                    <ChevronRight className="ml-1 h-4 w-4" />
                  </Link>
                </Button>
              </div>
              <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                {league.teams.slice(0, 4).map((team) => (
                  <div
                    key={team.id}
                    className="relative overflow-hidden rounded-xl bg-white/[0.03] border border-white/10 p-4 hover:border-white/20 transition-colors"
                  >
                    <div
                      className="absolute left-0 top-0 bottom-0 w-1"
                      style={{
                        backgroundColor: team.primaryColor || "#2ECC71",
                      }}
                    />
                    <h4 className="font-semibold text-white ml-2">
                      {team.name}
                    </h4>
                    <p className="text-sm text-gray-500 ml-2">
                      {team.drivers.length} drivers
                    </p>
                  </div>
                ))}
              </div>
            </div>
          </TabsContent>

          <TabsContent value="schedule">
            <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10">
              <div className="p-6 border-b border-white/10">
                <h3 className="text-xl font-semibold text-white flex items-center gap-2">
                  <Calendar className="h-5 w-5 text-[#2ECC71]" />
                  {t("schedule")}
                </h3>
                <p className="text-gray-400 mt-1">
                  All rounds for this championship
                </p>
              </div>
              <div className="divide-y divide-white/5">
                {league.rounds.map((round, idx) => (
                  <div
                    key={round.id}
                    className="flex items-center justify-between p-5 hover:bg-white/[0.02] transition-colors"
                  >
                    <div className="flex items-center gap-4">
                      <div
                        className={`flex h-12 w-12 items-center justify-center rounded-xl font-bold text-lg ${round.status === "COMPLETED" ? "bg-[#2ECC71]/20 text-[#2ECC71]" : idx === 0 ? "bg-[#F59E0B]/20 text-[#F59E0B]" : "bg-white/10 text-gray-400"}`}
                      >
                        {round.roundNumber}
                      </div>
                      <div>
                        <h4 className="font-semibold text-white">
                          {round.name || `Round ${round.roundNumber}`}
                        </h4>
                        <div className="flex items-center gap-1 text-sm text-gray-500">
                          <MapPin className="h-3 w-3" />
                          {round.track.name}, {round.track.country}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-4">
                      <div className="text-right">
                        <p className="text-sm text-gray-300">
                          {formatRaceDateTime(
                            round.scheduledAt,
                            league.timezone,
                          )}
                        </p>
                        {round.hasSprint && (
                          <Badge className="text-xs bg-orange-500/20 text-orange-400 border-orange-500/30 mt-1">
                            Sprint
                          </Badge>
                        )}
                      </div>
                      <Badge
                        className={
                          round.status === "COMPLETED"
                            ? "bg-[#2ECC71]/20 text-[#2ECC71] border-[#2ECC71]/30"
                            : round.status === "ANNULLED"
                              ? "bg-red-500/20 text-red-400 border-red-500/30"
                              : "bg-white/10 text-gray-400 border-white/10"
                        }
                      >
                        {round.status === "COMPLETED"
                          ? tRound("completed")
                          : round.status === "ANNULLED"
                            ? tRound("annulled")
                            : tRound("scheduled")}
                      </Badge>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </TabsContent>

          <TabsContent value="standings">
            <div className="grid gap-6 md:grid-cols-2">
              {/* Driver Standings */}
              <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10">
                <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-[#F59E0B] to-[#D97706]" />
                <div className="p-6 border-b border-white/10">
                  <div className="flex items-center gap-2">
                    <Trophy className="h-5 w-5 text-[#F59E0B]" />
                    <h3 className="text-lg font-semibold text-white">
                      {tStandings("driverStandings")}
                    </h3>
                  </div>
                </div>
                {driverStandingsWithDetails.length === 0 ? (
                  <div className="p-6">
                    <p className="text-gray-500">
                      Standings will appear here once results are entered.
                    </p>
                  </div>
                ) : (
                  <div className="divide-y divide-white/5 max-h-[500px] overflow-y-auto">
                    {driverStandingsWithDetails.slice(0, 20).map((standing) => (
                      <div
                        key={standing.driver?.id}
                        className="flex items-center justify-between p-4 hover:bg-white/[0.02] transition-colors"
                      >
                        <div className="flex items-center gap-3">
                          <div
                            className={`flex h-8 w-8 items-center justify-center rounded-lg font-bold text-sm ${
                              standing.position === 1
                                ? "bg-yellow-500/20 text-yellow-400"
                                : standing.position === 2
                                  ? "bg-gray-400/20 text-gray-300"
                                  : standing.position === 3
                                    ? "bg-amber-600/20 text-amber-500"
                                    : "bg-white/10 text-gray-400"
                            }`}
                          >
                            {standing.position}
                          </div>
                          <div
                            className="h-8 w-1 rounded-full"
                            style={{
                              backgroundColor:
                                standing.driver?.team?.primaryColor || "#2ECC71",
                            }}
                          />
                          <div>
                            <p className="font-medium text-white">
                              {standing.driver?.fullName}
                            </p>
                            <p className="text-xs text-gray-500">
                              {standing.driver?.team?.name}
                            </p>
                          </div>
                        </div>
                        <div className="text-right">
                          <p className="font-bold text-[#2ECC71]">
                            {standing.points}
                          </p>
                          <p className="text-xs text-gray-500">pts</p>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Constructor Standings */}
              <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10">
                <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-[#3B82F6] to-[#2563EB]" />
                <div className="p-6 border-b border-white/10">
                  <div className="flex items-center gap-2">
                    <Flag className="h-5 w-5 text-[#3B82F6]" />
                    <h3 className="text-lg font-semibold text-white">
                      {tStandings("constructorStandings")}
                    </h3>
                  </div>
                </div>
                {constructorStandingsWithDetails.length === 0 ? (
                  <div className="p-6">
                    <p className="text-gray-500">
                      Standings will appear here once results are entered.
                    </p>
                  </div>
                ) : (
                  <div className="divide-y divide-white/5">
                    {constructorStandingsWithDetails.map((standing) => (
                      <div
                        key={standing.team?.id}
                        className="flex items-center justify-between p-4 hover:bg-white/[0.02] transition-colors"
                      >
                        <div className="flex items-center gap-3">
                          <div
                            className={`flex h-8 w-8 items-center justify-center rounded-lg font-bold text-sm ${
                              standing.position === 1
                                ? "bg-yellow-500/20 text-yellow-400"
                                : standing.position === 2
                                  ? "bg-gray-400/20 text-gray-300"
                                  : standing.position === 3
                                    ? "bg-amber-600/20 text-amber-500"
                                    : "bg-white/10 text-gray-400"
                            }`}
                          >
                            {standing.position}
                          </div>
                          <div
                            className="h-8 w-1 rounded-full"
                            style={{
                              backgroundColor:
                                standing.team?.primaryColor || "#2ECC71",
                            }}
                          />
                          <div>
                            <p className="font-medium text-white">
                              {standing.team?.name}
                            </p>
                            <p className="text-xs text-gray-500">
                              {standing.team?.country}
                            </p>
                          </div>
                        </div>
                        <div className="text-right">
                          <p className="font-bold text-[#3B82F6]">
                            {standing.points}
                          </p>
                          <p className="text-xs text-gray-500">pts</p>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </TabsContent>

          <TabsContent value="teams">
            <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
              {league.teams.map((team) => (
                <div
                  key={team.id}
                  className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10 hover:border-white/20 transition-colors"
                >
                  <div
                    className="absolute top-0 left-0 right-0 h-1"
                    style={{ backgroundColor: team.primaryColor || "#2ECC71" }}
                  />
                  <div className="p-5">
                    <div className="flex items-center gap-3 mb-4">
                      <div
                        className="h-10 w-10 rounded-xl flex items-center justify-center text-white font-bold"
                        style={{
                          backgroundColor: `${team.primaryColor || "#2ECC71"}40`,
                        }}
                      >
                        {team.name.substring(0, 2).toUpperCase()}
                      </div>
                      <div>
                        <h4 className="font-semibold text-white">
                          {team.name}
                        </h4>
                        {team.country && (
                          <p className="text-sm text-gray-500">
                            {team.country}
                          </p>
                        )}
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
                                backgroundColor: `${team.primaryColor || "#2ECC71"}30`,
                                color: team.primaryColor || "#2ECC71",
                              }}
                            >
                              {driver.number || driver.shortName || "?"}
                            </div>
                            <div>
                              <p className="font-medium text-white">
                                {driver.fullName}
                              </p>
                              <p className="text-xs text-gray-500">
                                {driver.gamertag}
                              </p>
                            </div>
                          </div>
                          {driver.isReserve && (
                            <Badge className="text-xs bg-white/10 text-gray-400 border-white/10">
                              Reserve
                            </Badge>
                          )}
                        </div>
                      ))}
                      {team.drivers.length === 0 && (
                        <p className="text-sm text-gray-500 py-2">
                          No drivers assigned
                        </p>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </TabsContent>

          <TabsContent value="results">
            <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10">
              <div className="p-6 border-b border-white/10">
                <h3 className="text-xl font-semibold text-white flex items-center gap-2">
                  <Trophy className="h-5 w-5 text-[#2ECC71]" />
                  {t("results")}
                </h3>
                <p className="text-gray-400 mt-1">
                  Race results for completed rounds
                </p>
              </div>
              {completedRounds.length === 0 ? (
                <div className="p-8 text-center">
                  <div className="h-16 w-16 rounded-2xl bg-white/5 flex items-center justify-center mx-auto mb-4">
                    <Trophy className="h-8 w-8 text-gray-600" />
                  </div>
                  <p className="text-gray-500">No results available yet.</p>
                  <p className="text-sm text-gray-600 mt-1">
                    Results will appear after races are completed.
                  </p>
                </div>
              ) : (
                <div className="divide-y divide-white/5">
                  {completedRounds.map((round) => (
                    <Link
                      key={round.id}
                      href={`/leagues/${slug}/results/${round.roundNumber}`}
                      className="flex items-center justify-between p-5 hover:bg-white/[0.02] transition-colors group"
                    >
                      <div className="flex items-center gap-4">
                        <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-[#2ECC71]/20 text-[#2ECC71] font-bold">
                          {round.roundNumber}
                        </div>
                        <div>
                          <h4 className="font-semibold text-white group-hover:text-[#2ECC71] transition-colors">
                            Round {round.roundNumber}:{" "}
                            {round.name || round.track.name}
                          </h4>
                          <div className="flex items-center gap-1 text-sm text-gray-500">
                            <MapPin className="h-3 w-3" />
                            {round.track.country}
                          </div>
                        </div>
                      </div>
                      <ChevronRight className="h-5 w-5 text-gray-600 group-hover:text-[#2ECC71] transition-colors" />
                    </Link>
                  ))}
                </div>
              )}
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </DashboardLayout>
  );
}
