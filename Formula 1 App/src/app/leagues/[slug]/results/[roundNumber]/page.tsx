import { Metadata } from "next";
import { notFound, redirect } from "next/navigation";
import Link from "next/link";
import {
  ArrowLeft,
  Trophy,
  Calendar,
  MapPin,
  Construction,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { DashboardLayout } from "@/components/layout/dashboard-layout";
import { createClient } from "@/lib/supabase/server";
import prisma from "@/lib/db";

interface ResultsPageProps {
  params: Promise<{ slug: string; roundNumber: string }>;
}

export async function generateMetadata({
  params,
}: ResultsPageProps): Promise<Metadata> {
  const { slug, roundNumber } = await params;
  
  const league = await prisma.league.findUnique({
    where: { slug },
  });

  if (!league) {
    return { title: "Results Not Found" };
  }

  return {
    title: `Round ${roundNumber} Results - ${league.name}`,
    description: `Race results for Round ${roundNumber}`,
  };
}

export default async function ResultsPage({ params }: ResultsPageProps) {
  const { slug, roundNumber } = await params;
  const roundNum = parseInt(roundNumber);

  let user = null;
  try {
    const supabase = await createClient();
    const { data } = await supabase.auth.getUser();
    user = data?.user;
  } catch (error) {
    console.error('Error getting user:', error);
  }

  if (!user) {
    redirect("/auth/signin");
  }

  const league = await prisma.league.findUnique({
    where: { slug },
    include: {
      championships: {
        where: { status: { in: ['ACTIVE', 'DRAFT'] } },
        include: {
          races: {
            where: { roundNumber: roundNum },
            include: {
              track: true,
              raceResults: {
                orderBy: { position: 'asc' },
                include: {
                  driver: true,
                  team: true,
                },
              },
            },
          },
        },
        take: 1,
        orderBy: { createdAt: 'desc' },
      },
    },
  });

  if (!league) {
    notFound();
  }

  const championship = league.championships[0];
  const race = championship?.races[0];

  return (
    <DashboardLayout user={{ email: user.email || "" }}>
      <div className="space-y-6">
        {/* Back link */}
        <Link
          href={`/leagues/${slug}`}
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
                  {roundNum}
                </div>
                <div>
                  <h1 className="text-2xl md:text-3xl font-bold text-white">
                    {race?.name || `Round ${roundNum}`}
                  </h1>
                  {race?.track && (
                    <div className="flex items-center gap-2 text-gray-400">
                      <MapPin className="h-4 w-4" />
                      {race.track.name}, {race.track.country}
                    </div>
                  )}
                </div>
              </div>
              {race?.scheduledDate && (
                <div className="flex items-center gap-2 text-gray-500 mt-2">
                  <Calendar className="h-4 w-4" />
                  {new Date(race.scheduledDate).toLocaleDateString()}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Results Content */}
        {!race || race.raceResults.length === 0 ? (
          <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10 p-12 text-center">
            <div className="mx-auto mb-6 h-20 w-20 rounded-full bg-gradient-to-br from-[#F59E0B]/20 to-[#F59E0B]/5 flex items-center justify-center">
              <Construction className="h-10 w-10 text-[#F59E0B]" />
            </div>
            <h3 className="text-xl font-semibold text-white mb-2">
              Results Coming Soon
            </h3>
            <p className="text-gray-400 mb-6 max-w-md mx-auto">
              Race results will be displayed here once the race is completed and results are entered.
            </p>
            <Button asChild variant="outline" className="border-white/10">
              <Link href={`/leagues/${slug}`}>
                Return to League
              </Link>
            </Button>
          </div>
        ) : (
          <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10">
            <div className="p-6 border-b border-white/10">
              <div className="flex items-center gap-2">
                <Trophy className="h-5 w-5 text-[#F59E0B]" />
                <h2 className="text-xl font-semibold text-white">Race Results</h2>
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
                  {race.raceResults.map((result) => (
                    <tr
                      key={result.id}
                      className="hover:bg-white/[0.02] transition-colors"
                    >
                      <td className="px-6 py-4">
                        <span className={`font-bold text-lg ${
                          result.position === 1 ? 'text-yellow-400' :
                          result.position === 2 ? 'text-gray-300' :
                          result.position === 3 ? 'text-amber-600' : 'text-gray-400'
                        }`}>
                          {result.position === 1 && '🥇 '}
                          {result.position === 2 && '🥈 '}
                          {result.position === 3 && '🥉 '}
                          P{result.position}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div
                            className="flex h-10 w-10 items-center justify-center rounded-lg text-sm font-bold"
                            style={{
                              backgroundColor: `${result.team?.primaryColor || "#2ECC71"}30`,
                              color: result.team?.primaryColor || "#2ECC71",
                            }}
                          >
                            {result.driver?.number || result.driver?.shortName || '?'}
                          </div>
                          <div>
                            <p className="font-medium text-white">
                              {result.driver?.fullName || 'Unknown Driver'}
                            </p>
                            <p className="text-xs text-gray-500">
                              {result.driver?.gamertag}
                            </p>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          <div
                            className="h-3 w-3 rounded-full"
                            style={{
                              backgroundColor: result.team?.primaryColor || "#2ECC71",
                            }}
                          />
                          <span className="text-gray-300">{result.team?.name || 'Unknown Team'}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <span className={`font-bold text-lg ${result.points > 0 ? "text-[#2ECC71]" : "text-gray-500"}`}>
                          {result.points}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <span className={`px-2 py-1 rounded text-xs ${
                          result.status === 'FINISHED' ? 'bg-[#2ECC71]/20 text-[#2ECC71]' :
                          'bg-red-500/20 text-red-400'
                        }`}>
                          {result.status}
                        </span>
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
