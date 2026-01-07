'use client';

import Link from 'next/link';
import { Trophy, Users, Crown, ChevronRight, Medal, Calendar } from 'lucide-react';

interface League {
  id: string;
  name: string;
  slug: string;
  role: 'OWNER' | 'ADMIN' | 'MEMBER';
  memberCount: number;
  championshipCount: number;
  activeChampionship?: {
    name: string;
    completedRaces: number;
    totalRaces: number;
  };
}

interface LeaguesListProps {
  leagues: League[];
}

export function LeaguesList({ leagues }: LeaguesListProps) {
  const getRoleBadge = (role: string) => {
    switch (role) {
      case 'OWNER':
        return (
          <span className="flex items-center gap-1 text-xs bg-[#DC2626]/20 text-[#EF4444] px-2 py-0.5 rounded-full">
            <Crown className="h-3 w-3" />
            Owner
          </span>
        );
      case 'ADMIN':
        return (
          <span className="flex items-center gap-1 text-xs bg-blue-500/20 text-blue-400 px-2 py-0.5 rounded-full">
            Admin
          </span>
        );
      default:
        return (
          <span className="text-xs bg-white/[0.06] text-gray-400 px-2 py-0.5 rounded-full">
            Member
          </span>
        );
    }
  };

  if (leagues.length === 0) {
    return (
      <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.06] to-white/[0.02] border border-white/[0.06] p-6">
        <div className="flex items-center gap-3 mb-4">
          <div className="h-10 w-10 rounded-xl bg-[#DC2626]/20 flex items-center justify-center">
            <Trophy className="h-5 w-5 text-[#DC2626]" />
          </div>
          <h3 className="text-lg font-semibold text-white">My Leagues</h3>
        </div>
        <div className="text-center py-8">
          <Trophy className="h-12 w-12 text-gray-600 mx-auto mb-3" />
          <p className="text-gray-400">No leagues yet</p>
          <p className="text-sm text-gray-500 mt-1 mb-4">Create or join a league to get started</p>
          <Link
            href="/leagues/new"
            className="inline-flex items-center gap-2 bg-[#DC2626] hover:bg-[#B91C1C] text-white px-4 py-2 rounded-lg font-medium text-sm transition-colors"
          >
            Create League
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.06] to-white/[0.02] border border-white/[0.06]">
      {/* Header */}
      <div className="p-5 border-b border-white/[0.06] flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-xl bg-[#DC2626]/20 flex items-center justify-center">
            <Trophy className="h-5 w-5 text-[#DC2626]" />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-white">My Leagues</h3>
            <p className="text-xs text-gray-500">{leagues.length} active league{leagues.length !== 1 ? 's' : ''}</p>
          </div>
        </div>
        <Link
          href="/leagues"
          className="text-sm text-gray-400 hover:text-white transition-colors flex items-center gap-1"
        >
          View All
          <ChevronRight className="h-4 w-4" />
        </Link>
      </div>

      {/* Leagues List */}
      <div className="divide-y divide-white/[0.04]">
        {leagues.slice(0, 5).map((league) => {
          const progress = league.activeChampionship
            ? (league.activeChampionship.completedRaces / league.activeChampionship.totalRaces) * 100
            : 0;

          return (
            <Link
              key={league.id}
              href={`/leagues/${league.slug}`}
              className="block p-5 hover:bg-white/[0.02] transition-colors group"
            >
              <div className="flex items-start justify-between mb-3">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <h4 className="font-semibold text-white group-hover:text-[#EF4444] transition-colors truncate">
                      {league.name}
                    </h4>
                    {getRoleBadge(league.role)}
                  </div>
                  <div className="flex items-center gap-4 text-xs text-gray-500">
                    <span className="flex items-center gap-1">
                      <Users className="h-3 w-3" />
                      {league.memberCount} members
                    </span>
                    <span className="flex items-center gap-1">
                      <Medal className="h-3 w-3" />
                      {league.championshipCount} championship{league.championshipCount !== 1 ? 's' : ''}
                    </span>
                  </div>
                </div>
                <ChevronRight className="h-5 w-5 text-gray-600 group-hover:text-[#EF4444] transition-colors flex-shrink-0" />
              </div>

              {league.activeChampionship && (
                <div className="mt-3 pt-3 border-t border-white/[0.04]">
                  <div className="flex items-center justify-between text-xs mb-2">
                    <span className="text-gray-400 flex items-center gap-1">
                      <Calendar className="h-3 w-3" />
                      {league.activeChampionship.name}
                    </span>
                    <span className="text-gray-500">
                      {league.activeChampionship.completedRaces}/{league.activeChampionship.totalRaces} races
                    </span>
                  </div>
                  <div className="h-1.5 rounded-full bg-white/[0.06] overflow-hidden">
                    <div
                      className="h-full rounded-full bg-gradient-to-r from-[#DC2626] to-[#EF4444]"
                      style={{ width: `${progress}%` }}
                    />
                  </div>
                </div>
              )}
            </Link>
          );
        })}
      </div>

      {/* Create New League Button */}
      <div className="p-4 border-t border-white/[0.06]">
        <Link
          href="/leagues/new"
          className="flex items-center justify-center gap-2 w-full py-2.5 rounded-xl bg-white/[0.04] hover:bg-[#DC2626]/20 text-gray-400 hover:text-[#EF4444] transition-colors text-sm font-medium"
        >
          <span className="text-lg">+</span>
          Create New League
        </Link>
      </div>
    </div>
  );
}
