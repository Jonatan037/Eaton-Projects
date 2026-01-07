'use client';

import { useState } from 'react';
import Link from 'next/link';
import { 
  Search, 
  Bell, 
  Plus,
  Trophy,
  Flag,
  Users,
  Calendar,
  TrendingUp,
  TrendingDown,
  MapPin,
  Clock,
  ChevronDown,
  Crown,
  Medal,
} from 'lucide-react';

interface DashboardContentProps {
  user: { email: string; name?: string };
  stats: {
    leagues: number;
    championships: number;
    completedRaces: number;
    totalRaces: number;
    drivers: number;
  };
  nextRace: {
    name: string;
    trackName: string;
    country: string;
    scheduledDate: string | null;
    scheduledTime: string | null;
    roundNumber: number;
  } | null;
  championships: Array<{
    id: string;
    name: string;
    leagueName: string;
    standings: Array<{ name: string; teamName: string; points: number }>;
  }>;
  leagues: Array<{
    id: string;
    name: string;
    slug: string;
    role: string;
    memberCount: number;
    championshipCount: number;
  }>;
}

export function DashboardContent({
  user,
  stats,
  nextRace,
  championships,
  leagues,
}: DashboardContentProps) {
  const [selectedChampionship, setSelectedChampionship] = useState(championships[0]?.id || '');

  const currentChampionship = championships.find((c) => c.id === selectedChampionship);

  const raceDate = nextRace?.scheduledDate ? new Date(nextRace.scheduledDate) : null;
  const daysUntil = raceDate
    ? Math.ceil((raceDate.getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24))
    : null;

  return (
    <div className="min-h-screen bg-[#0a0a0a]">
      {/* Header */}
      <header className="h-16 px-6 flex items-center justify-between border-b border-white/5">
        <div>
          <h1 className="text-xl font-semibold text-white">Dashboard</h1>
          <p className="text-xs text-gray-500">Manage your leagues and track your championships</p>
        </div>

        <div className="flex items-center gap-4">
          {/* Search */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-500" />
            <input
              type="text"
              placeholder="Search..."
              className="w-64 h-9 pl-9 pr-4 bg-white/5 border border-white/10 rounded-lg text-sm text-white placeholder:text-gray-500 focus:outline-none focus:border-white/20"
            />
          </div>

          {/* Notifications */}
          <button className="relative h-9 w-9 rounded-lg bg-white/5 flex items-center justify-center text-gray-400 hover:text-white hover:bg-white/10 transition-colors">
            <Bell className="h-4 w-4" />
            <span className="absolute top-2 right-2 h-2 w-2 bg-[#DC2626] rounded-full" />
          </button>

          {/* Add New */}
          <Link
            href="/dashboard"
            className="h-9 px-4 bg-[#DC2626] hover:bg-[#B91C1C] text-white text-sm font-medium rounded-lg flex items-center gap-2 transition-colors"
          >
            <Plus className="h-4 w-4" />
            Create League
          </Link>
        </div>
      </header>

      {/* Content */}
      <div className="p-6">
        <div className="grid grid-cols-12 gap-6">
          {/* Left Column - Stats & Chart */}
          <div className="col-span-8 space-y-6">
            {/* Stats Cards Row */}
            <div className="grid grid-cols-4 gap-4">
              {/* Leagues */}
              <div className="bg-[#111111] rounded-xl p-4 border border-white/5">
                <div className="flex items-start justify-between">
                  <div className="h-10 w-10 rounded-lg bg-[#DC2626]/10 flex items-center justify-center">
                    <Trophy className="h-5 w-5 text-[#DC2626]" />
                  </div>
                  <div className="flex items-center gap-1 text-xs text-green-400">
                    <TrendingUp className="h-3 w-3" />
                    Active
                  </div>
                </div>
                <div className="mt-3">
                  <p className="text-2xl font-bold text-white">{stats.leagues}</p>
                  <p className="text-xs text-gray-500 mt-1">Total Leagues</p>
                </div>
              </div>

              {/* Championships */}
              <div className="bg-[#111111] rounded-xl p-4 border border-white/5">
                <div className="flex items-start justify-between">
                  <div className="h-10 w-10 rounded-lg bg-amber-500/10 flex items-center justify-center">
                    <Medal className="h-5 w-5 text-amber-500" />
                  </div>
                  <div className="flex items-center gap-1 text-xs text-gray-400">
                    Running
                  </div>
                </div>
                <div className="mt-3">
                  <p className="text-2xl font-bold text-white">{stats.championships}</p>
                  <p className="text-xs text-gray-500 mt-1">Championships</p>
                </div>
              </div>

              {/* Races */}
              <div className="bg-[#111111] rounded-xl p-4 border border-white/5">
                <div className="flex items-start justify-between">
                  <div className="h-10 w-10 rounded-lg bg-blue-500/10 flex items-center justify-center">
                    <Flag className="h-5 w-5 text-blue-500" />
                  </div>
                  <div className="flex items-center gap-1 text-xs text-blue-400">
                    {stats.totalRaces > 0 ? `${Math.round((stats.completedRaces / stats.totalRaces) * 100)}%` : '0%'}
                  </div>
                </div>
                <div className="mt-3">
                  <p className="text-2xl font-bold text-white">{stats.completedRaces}/{stats.totalRaces}</p>
                  <p className="text-xs text-gray-500 mt-1">Races Completed</p>
                </div>
              </div>

              {/* Drivers */}
              <div className="bg-[#111111] rounded-xl p-4 border border-white/5">
                <div className="flex items-start justify-between">
                  <div className="h-10 w-10 rounded-lg bg-purple-500/10 flex items-center justify-center">
                    <Users className="h-5 w-5 text-purple-500" />
                  </div>
                </div>
                <div className="mt-3">
                  <p className="text-2xl font-bold text-white">{stats.drivers}</p>
                  <p className="text-xs text-gray-500 mt-1">Total Drivers</p>
                </div>
              </div>
            </div>

            {/* Championship Standings */}
            <div className="bg-[#111111] rounded-xl border border-white/5">
              <div className="p-4 border-b border-white/5 flex items-center justify-between">
                <h2 className="text-sm font-medium text-white">Championship Standings</h2>
                {championships.length > 0 && (
                  <div className="relative">
                    <select
                      value={selectedChampionship}
                      onChange={(e) => setSelectedChampionship(e.target.value)}
                      className="appearance-none bg-white/5 border border-white/10 rounded-lg px-3 py-1.5 pr-8 text-xs text-white focus:outline-none focus:border-white/20"
                    >
                      {championships.map((c) => (
                        <option key={c.id} value={c.id} className="bg-[#1a1a1a]">
                          {c.name}
                        </option>
                      ))}
                    </select>
                    <ChevronDown className="absolute right-2 top-1/2 -translate-y-1/2 h-3 w-3 text-gray-500 pointer-events-none" />
                  </div>
                )}
              </div>

              <div className="p-4">
                {currentChampionship && currentChampionship.standings.length > 0 ? (
                  <div className="space-y-3">
                    {currentChampionship.standings.map((driver, index) => (
                      <div
                        key={index}
                        className="flex items-center gap-4 p-3 bg-white/[0.02] rounded-lg"
                      >
                        <div
                          className={`h-7 w-7 rounded-lg flex items-center justify-center text-xs font-bold ${
                            index === 0
                              ? 'bg-yellow-500/20 text-yellow-500'
                              : index === 1
                              ? 'bg-gray-400/20 text-gray-400'
                              : index === 2
                              ? 'bg-amber-700/20 text-amber-600'
                              : 'bg-white/5 text-gray-500'
                          }`}
                        >
                          {index + 1}
                        </div>
                        <div className="flex-1">
                          <p className="text-sm font-medium text-white">{driver.name}</p>
                          <p className="text-xs text-gray-500">{driver.teamName}</p>
                        </div>
                        <div className="text-right">
                          <p className="text-sm font-bold text-white">{driver.points}</p>
                          <p className="text-xs text-gray-500">pts</p>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <Trophy className="h-10 w-10 text-gray-700 mx-auto mb-2" />
                    <p className="text-sm text-gray-500">No standings available</p>
                    <p className="text-xs text-gray-600 mt-1">Complete races to see standings</p>
                  </div>
                )}
              </div>
            </div>

            {/* My Leagues */}
            <div className="bg-[#111111] rounded-xl border border-white/5">
              <div className="p-4 border-b border-white/5 flex items-center justify-between">
                <h2 className="text-sm font-medium text-white">My Leagues</h2>
                <span className="text-xs text-gray-500">{leagues.length} leagues</span>
              </div>

              <div className="p-4">
                {leagues.length > 0 ? (
                  <div className="space-y-3">
                    {leagues.map((league) => (
                      <div
                        key={league.id}
                        className="flex items-center gap-4 p-3 bg-white/[0.02] rounded-lg hover:bg-white/[0.04] transition-colors cursor-pointer"
                      >
                        <div className="h-10 w-10 rounded-lg bg-[#DC2626]/10 flex items-center justify-center">
                          <Trophy className="h-5 w-5 text-[#DC2626]" />
                        </div>
                        <div className="flex-1">
                          <div className="flex items-center gap-2">
                            <p className="text-sm font-medium text-white">{league.name}</p>
                            {league.role === 'OWNER' && (
                              <span className="flex items-center gap-1 text-[10px] bg-[#DC2626]/20 text-[#DC2626] px-1.5 py-0.5 rounded">
                                <Crown className="h-2.5 w-2.5" />
                                Owner
                              </span>
                            )}
                          </div>
                          <p className="text-xs text-gray-500">
                            {league.memberCount} members · {league.championshipCount} championships
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <Trophy className="h-10 w-10 text-gray-700 mx-auto mb-2" />
                    <p className="text-sm text-gray-500">No leagues yet</p>
                    <p className="text-xs text-gray-600 mt-1">Create your first league to get started</p>
                    <Link
                      href="/dashboard"
                      className="inline-flex items-center gap-2 mt-4 px-4 py-2 bg-[#DC2626] hover:bg-[#B91C1C] text-white text-sm rounded-lg transition-colors"
                    >
                      <Plus className="h-4 w-4" />
                      Create League
                    </Link>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Right Column - Next Race & Upgrade */}
          <div className="col-span-4 space-y-6">
            {/* Next Race Card */}
            <div className="bg-[#111111] rounded-xl border border-white/5 overflow-hidden">
              <div className="p-4 border-b border-white/5">
                <div className="flex items-center justify-between">
                  <h2 className="text-sm font-medium text-white">Next Race</h2>
                  {daysUntil !== null && (
                    <span className="text-xs bg-[#DC2626]/20 text-[#DC2626] px-2 py-1 rounded-full">
                      {daysUntil === 0 ? 'Today' : daysUntil === 1 ? 'Tomorrow' : `${daysUntil} days`}
                    </span>
                  )}
                </div>
              </div>

              {nextRace ? (
                <div className="p-4">
                  {/* Track visual placeholder */}
                  <div className="h-32 bg-gradient-to-br from-white/5 to-transparent rounded-lg flex items-center justify-center mb-4">
                    <span className="text-4xl font-bold text-white/10">R{nextRace.roundNumber}</span>
                  </div>

                  <div className="space-y-3">
                    <div>
                      <p className="text-xs text-gray-500 mb-1">Round {nextRace.roundNumber}</p>
                      <p className="text-lg font-semibold text-white">{nextRace.name}</p>
                    </div>

                    <div className="flex items-center gap-4 text-sm">
                      <div className="flex items-center gap-2 text-gray-400">
                        <MapPin className="h-4 w-4 text-gray-500" />
                        {nextRace.country}
                      </div>
                      <div className="flex items-center gap-2 text-gray-400">
                        <Calendar className="h-4 w-4 text-gray-500" />
                        {raceDate?.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) || 'TBD'}
                      </div>
                    </div>

                    <div className="flex items-center gap-2 pt-2 border-t border-white/5">
                      <Clock className="h-4 w-4 text-[#DC2626]" />
                      <span className="text-sm text-white">{nextRace.scheduledTime || 'Time TBD'}</span>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="p-6 text-center">
                  <Calendar className="h-10 w-10 text-gray-700 mx-auto mb-2" />
                  <p className="text-sm text-gray-500">No upcoming races</p>
                  <p className="text-xs text-gray-600 mt-1">Join a league to see scheduled races</p>
                </div>
              )}
            </div>

            {/* Upgrade Card */}
            <div className="bg-gradient-to-br from-[#DC2626]/20 to-[#DC2626]/5 rounded-xl border border-[#DC2626]/20 p-5">
              <div className="h-10 w-10 rounded-lg bg-[#DC2626]/20 flex items-center justify-center mb-4">
                <Trophy className="h-5 w-5 text-[#DC2626]" />
              </div>
              <h3 className="text-lg font-semibold text-white mb-1">Upgrade to Pro</h3>
              <p className="text-sm text-gray-400 mb-4">
                Get unlimited leagues, advanced analytics, and priority support.
              </p>
              <button className="w-full py-2.5 bg-[#DC2626] hover:bg-[#B91C1C] text-white text-sm font-medium rounded-lg transition-colors">
                Try It Now
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
