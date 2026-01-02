import { Metadata } from "next";
import { notFound, redirect } from "next/navigation";
import Link from "next/link";
import { getTranslations } from "next-intl/server";
import {
  ArrowLeft,
  Trophy,
  Clock,
  Zap,
  Flag,
  Timer,
  MapPin,
  Calendar,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { DashboardLayout } from "@/components/layout/dashboard-layout";
import { createClient } from "@/lib/supabase/server";
import prisma from "@/lib/db";
import { formatRaceDateTime } from "@/lib/date-utils";

interface ResultsPageProps {
  params: Promise<{ slug: string; roundNumber: string }>;
}

export async function generateMetadata({
  params,
}: ResultsPageProps): Promise<Metadata> {
  const { slug, roundNumber } = await params;
  const league = await prisma.league.findUnique({
    where: { slug },
    include: {
      rounds: {
        where: { roundNumber: parseInt(roundNumber) },
        include: { track: true },
      },
    },
  });

  if (!league || league.rounds.length === 0) {
    return { title: "Results Not Found" };
  }

  const round = league.rounds[0];
  return {
    title: `${round.name || `Round ${round.roundNumber}`} Results - ${league.name}`,
    description: `Race results for ${round.name || `Round ${round.roundNumber}`}`,
  };
}

export default async function ResultsPage({ params }: ResultsPageProps) {
  const { slug, roundNumber } = await params;
  const roundNum = parseInt(roundNumber);

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/auth/signin");
  }

  const league = await prisma.league.findUnique({
    where: { slug },
    include: {
      rounds: {
        orderBy: { roundNumber: "asc" },
        include: { track: true },
      },
    },
  });

  if (!league) {
    notFound();
  }

  const round = await prisma.round.findFirst({
    where: {
      leagueId: league.id,
      roundNumber: roundNum,
    },
    include: {
      track: true,
      results: {
        orderBy: { position: "asc" },
        include: {
          driver: true,
          team: true,
        },
      },
    },
  });

  if (!round) {
    notFound();
  }

  const raceResults = round.results.filter((r) => r.sessionType === "RACE");
  const sprintResults = round.results.filter((r) => r.sessionType === "SPRINT");

  // Find prev/next rounds
  const prevRound = league.rounds.find(
    (r) => r.roundNumber === roundNum - 1 && r.status === "COMPLETED"
  );
  const nextRound = league.rounds.find(
    (r) => r.roundNumber === roundNum + 1 && r.status === "COMPLETED"
  );

  const getMedalIcon = (position: number | null) => {
    switch (position) {
      case 1:
        return "🥇";
      case 2:
        return "🥈";
      case 3:
        return "🥉";
      default:
        return null;
    }
  };

  const getPositionColor = (position: number | null) => {
    switch (position) {
      case 1:
        return "text-yellow-400";
      case 2:
        return "text-gray-300";
      case 3:
        return "text-amber-600";
      default:
        return "text-gray-400";
    }
  };

  return (
    <DashboardLayout user={{ email: user.email || "" }}>
      <div className="space-y-6">
        {/* Back link */}
        <Link
          href={`/leagues/${slug}?tab=results`}
          className="inline-flex items-center gap-2 text-gray-400 hover:text-white transition-colors"
        >
          <ArrowLeft className="h-4 w-4" />
          Back to League
        </Link>

        {/* Header */}
        <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10 p-6">
          <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-[#2ECC71] to-[#27AE60]" />

          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
            <div>
              <div className="flex items-center gap-3 mb-2">
                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-[#2ECC71]/20 text-[#2ECC71] font-bold text-xl">
                  {round.roundNumber}
                </div>
                <div>
                  <h1 className="text-2xl md:text-3xl font-bold text-white">
                    {round.name || `Round ${round.roundNumber}`}
                  </h1>
                  <div className="flex items-center gap-2 text-gray-400">
                    <MapPin className="h-4 w-4" />
                    {round.track.name}, {round.track.country}
                  </div>
                </div>
              </div>
              <div className="flex items-center gap-2 text-gray-500 mt-2">
                <Calendar className="h-4 w-4" />
                {formatRaceDateTime(round.scheduledAt, league.timezone)}
              </div>
            </div>

            <div className="flex items-center gap-2">
              {prevRound ? (
                <Button
                  asChild
                  variant="outline"
                  size="sm"
                  className="border-white/10 text-gray-400 hover:text-white hover:bg-white/5"
                >
                  <Link href={`/leagues/${slug}/results/${prevRound.roundNumber}`}>
                    <ChevronLeft className="h-4 w-4 mr-1" />
                    R{prevRound.roundNumber}
                  </Link>
                </Button>
              ) : (
                <div className="w-20" />
              )}
              {nextRound && (
                <Button
                  asChild
                  variant="outline"
                  size="sm"
                  className="border-white/10 text-gray-400 hover:text-white hover:bg-white/5"
                >
                  <Link href={`/leagues/${slug}/results/${nextRound.roundNumber}`}>
                    R{nextRound.roundNumber}
                    <ChevronRight className="h-4 w-4 ml-1" />
                  </Link>
                </Button>
              )}
            </div>
          </div>

          {/* Session badges */}
          <div className="flex gap-2 mt-4">
            {round.hasSprint && (
              <Badge className="bg-orange-500/20 text-orange-400 border-orange-500/30">
                <Zap className="h-3 w-3 mr-1" />
                Sprint Weekend
              </Badge>
            )}
            <Badge className="bg-[#2ECC71]/20 text-[#2ECC71] border-[#2ECC71]/30">
              <Flag className="h-3 w-3 mr-1" />
              Completed
            </Badge>
          </div>
        </div>

        {/* Race Results */}
        <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10">
          <div className="p-6 border-b border-white/10">
            <div className="flex items-center gap-2">
              <Trophy className="h-5 w-5 text-[#F59E0B]" />
              <h2 className="text-xl font-semibold text-white">Race Results</h2>
            </div>
          </div>

          {raceResults.length === 0 ? (
            <div className="p-8 text-center">
              <p className="text-gray-500">No race results available.</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-white/5">
                  <tr className="text-left text-sm text-gray-400">
                    <th className="px-6 py-4 font-medium">Pos</th>
                    <th className="px-6 py-4 font-medium">Driver</th>
                    <th className="px-6 py-4 font-medium">Team</th>
                    <th className="px-6 py-4 font-medium text-center">Points</th>
                    <th className="px-6 py-4 font-medium text-center">Status</th>
                    <th className="px-6 py-4 font-medium text-center">Bonus</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-white/5">
                  {raceResults.map((result) => (
                    <tr
                      key={result.id}
                      className="hover:bg-white/[0.02] transition-colors"
                    >
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          {getMedalIcon(result.position) && (
                            <span className="text-xl">
                              {getMedalIcon(result.position)}
                            </span>
                          )}
                          <span
                            className={`font-bold text-lg ${getPositionColor(result.position)}`}
                          >
                            P{result.position}
                          </span>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div
                            className="flex h-10 w-10 items-center justify-center rounded-lg text-sm font-bold"
                            style={{
                              backgroundColor: `${result.team.primaryColor || "#2ECC71"}30`,
                              color: result.team.primaryColor || "#2ECC71",
                            }}
                          >
                            {result.driver.number || result.driver.shortName}
                          </div>
                          <div>
                            <p className="font-medium text-white">
                              {result.driver.fullName}
                            </p>
                            <p className="text-xs text-gray-500">
                              {result.driver.gamertag}
                            </p>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          <div
                            className="h-3 w-3 rounded-full"
                            style={{
                              backgroundColor:
                                result.team.primaryColor || "#2ECC71",
                            }}
                          />
                          <span className="text-gray-300">{result.team.name}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <span
                          className={`font-bold text-lg ${result.points > 0 ? "text-[#2ECC71]" : "text-gray-500"}`}
                        >
                          {result.points}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-center">
                        {result.status === "DNF" ? (
                          <Badge className="bg-red-500/20 text-red-400 border-red-500/30">
                            DNF
                          </Badge>
                        ) : result.status === "DSQ" ? (
                          <Badge className="bg-red-500/20 text-red-400 border-red-500/30">
                            DSQ
                          </Badge>
                        ) : (
                          <Badge className="bg-[#2ECC71]/20 text-[#2ECC71] border-[#2ECC71]/30">
                            Finished
                          </Badge>
                        )}
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center justify-center gap-1">
                          {result.pole && (
                            <Badge className="bg-purple-500/20 text-purple-400 border-purple-500/30 text-xs">
                              <Flag className="h-3 w-3 mr-1" />
                              Pole
                            </Badge>
                          )}
                          {result.fastestLap && (
                            <Badge className="bg-[#F59E0B]/20 text-[#F59E0B] border-[#F59E0B]/30 text-xs">
                              <Timer className="h-3 w-3 mr-1" />
                              FL
                            </Badge>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Sprint Results (if applicable) */}
        {sprintResults.length > 0 && (
          <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10">
            <div className="p-6 border-b border-white/10">
              <div className="flex items-center gap-2">
                <Zap className="h-5 w-5 text-orange-400" />
                <h2 className="text-xl font-semibold text-white">
                  Sprint Results
                </h2>
              </div>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-white/5">
                  <tr className="text-left text-sm text-gray-400">
                    <th className="px-6 py-4 font-medium">Pos</th>
                    <th className="px-6 py-4 font-medium">Driver</th>
                    <th className="px-6 py-4 font-medium">Team</th>
                    <th className="px-6 py-4 font-medium text-center">Points</th>
                    <th className="px-6 py-4 font-medium text-center">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-white/5">
                  {sprintResults.map((result) => (
                    <tr
                      key={result.id}
                      className="hover:bg-white/[0.02] transition-colors"
                    >
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          {getMedalIcon(result.position) && (
                            <span className="text-xl">
                              {getMedalIcon(result.position)}
                            </span>
                          )}
                          <span
                            className={`font-bold text-lg ${getPositionColor(result.position)}`}
                          >
                            P{result.position}
                          </span>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div
                            className="flex h-10 w-10 items-center justify-center rounded-lg text-sm font-bold"
                            style={{
                              backgroundColor: `${result.team.primaryColor || "#2ECC71"}30`,
                              color: result.team.primaryColor || "#2ECC71",
                            }}
                          >
                            {result.driver.number || result.driver.shortName}
                          </div>
                          <div>
                            <p className="font-medium text-white">
                              {result.driver.fullName}
                            </p>
                            <p className="text-xs text-gray-500">
                              {result.driver.gamertag}
                            </p>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          <div
                            className="h-3 w-3 rounded-full"
                            style={{
                              backgroundColor:
                                result.team.primaryColor || "#2ECC71",
                            }}
                          />
                          <span className="text-gray-300">{result.team.name}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <span
                          className={`font-bold text-lg ${result.points > 0 ? "text-orange-400" : "text-gray-500"}`}
                        >
                          {result.points}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-center">
                        {result.status === "DNF" ? (
                          <Badge className="bg-red-500/20 text-red-400 border-red-500/30">
                            DNF
                          </Badge>
                        ) : (
                          <Badge className="bg-[#2ECC71]/20 text-[#2ECC71] border-[#2ECC71]/30">
                            Finished
                          </Badge>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
