'use client';

import { useState } from 'react';
import { Trophy, ChevronDown, TrendingUp, TrendingDown, Minus } from 'lucide-react';

interface ChampionshipStanding {
  position: number;
  driverName: string;
  teamName: string;
  points: number;
  previousPosition?: number;
  wins?: number;
}

interface Championship {
  id: string;
  name: string;
  leagueName: string;
  standings: ChampionshipStanding[];
}

interface ChampionshipStandingsChartProps {
  championships: Championship[];
}

export function ChampionshipStandingsChart({ championships }: ChampionshipStandingsChartProps) {
  const [selectedChampionship, setSelectedChampionship] = useState<string>(
    championships[0]?.id || ''
  );
  const [dropdownOpen, setDropdownOpen] = useState(false);

  const currentChampionship = championships.find((c) => c.id === selectedChampionship);
  const standings = currentChampionship?.standings || [];

  // Calculate max points for bar width
  const maxPoints = Math.max(...standings.map((s) => s.points), 1);

  const getPositionChange = (current: number, previous?: number) => {
    if (!previous) return null;
    const diff = previous - current;
    if (diff > 0) return { direction: 'up', value: diff };
    if (diff < 0) return { direction: 'down', value: Math.abs(diff) };
    return { direction: 'same', value: 0 };
  };

  const getPositionColor = (position: number) => {
    if (position === 1) return 'from-[#FFD700] to-[#FFA500]';
    if (position === 2) return 'from-[#C0C0C0] to-[#A0A0A0]';
    if (position === 3) return 'from-[#CD7F32] to-[#B87333]';
    return 'from-gray-600 to-gray-700';
  };

  if (championships.length === 0) {
    return (
      <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.06] to-white/[0.02] border border-white/[0.06] p-6">
        <div className="flex items-center gap-3 mb-4">
          <div className="h-10 w-10 rounded-xl bg-[#DC2626]/20 flex items-center justify-center">
            <Trophy className="h-5 w-5 text-[#DC2626]" />
          </div>
          <h3 className="text-lg font-semibold text-white">Championship Standings</h3>
        </div>
        <div className="text-center py-8">
          <Trophy className="h-12 w-12 text-gray-600 mx-auto mb-3" />
          <p className="text-gray-400">No active championships</p>
          <p className="text-sm text-gray-500 mt-1">Join a league to view standings</p>
        </div>
      </div>
    );
  }

  return (
    <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.06] to-white/[0.02] border border-white/[0.06]">
      {/* Header */}
      <div className="p-5 border-b border-white/[0.06]">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="h-10 w-10 rounded-xl bg-[#DC2626]/20 flex items-center justify-center">
              <Trophy className="h-5 w-5 text-[#DC2626]" />
            </div>
            <h3 className="text-lg font-semibold text-white">Championship Standings</h3>
          </div>

          {/* Championship Selector */}
          {championships.length > 1 && (
            <div className="relative">
              <button
                onClick={() => setDropdownOpen(!dropdownOpen)}
                className="flex items-center gap-2 bg-white/[0.04] hover:bg-white/[0.08] border border-white/[0.06] rounded-lg px-3 py-2 text-sm text-white transition-colors"
              >
                <span className="max-w-[150px] truncate">{currentChampionship?.name}</span>
                <ChevronDown className={`h-4 w-4 transition-transform ${dropdownOpen ? 'rotate-180' : ''}`} />
              </button>

              {dropdownOpen && (
                <div className="absolute right-0 top-full mt-2 w-64 bg-[#1a1a1a] border border-white/[0.06] rounded-lg shadow-xl z-10">
                  {championships.map((championship) => (
                    <button
                      key={championship.id}
                      onClick={() => {
                        setSelectedChampionship(championship.id);
                        setDropdownOpen(false);
                      }}
                      className={`w-full text-left px-4 py-3 hover:bg-white/[0.04] transition-colors first:rounded-t-lg last:rounded-b-lg ${
                        selectedChampionship === championship.id ? 'bg-[#DC2626]/20 text-[#EF4444]' : 'text-white'
                      }`}
                    >
                      <p className="font-medium text-sm">{championship.name}</p>
                      <p className="text-xs text-gray-500">{championship.leagueName}</p>
                    </button>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Standings List */}
      <div className="p-5 space-y-3">
        {standings.length === 0 ? (
          <div className="text-center py-6">
            <p className="text-gray-400">No standings yet</p>
            <p className="text-sm text-gray-500">Results will appear after races</p>
          </div>
        ) : (
          standings.slice(0, 6).map((standing) => {
            const change = getPositionChange(standing.position, standing.previousPosition);
            const barWidth = (standing.points / maxPoints) * 100;

            return (
              <div
                key={standing.position}
                className="group flex items-center gap-4 p-3 rounded-xl bg-white/[0.02] hover:bg-white/[0.04] transition-colors"
              >
                {/* Position Badge */}
                <div
                  className={`h-8 w-8 rounded-lg bg-gradient-to-br ${getPositionColor(standing.position)} flex items-center justify-center flex-shrink-0`}
                >
                  <span className="text-sm font-bold text-white">{standing.position}</span>
                </div>

                {/* Driver Info */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <span className="font-medium text-white truncate">{standing.driverName}</span>
                    {change && (
                      <span className="flex items-center">
                        {change.direction === 'up' && (
                          <TrendingUp className="h-3 w-3 text-green-500" />
                        )}
                        {change.direction === 'down' && (
                          <TrendingDown className="h-3 w-3 text-red-500" />
                        )}
                        {change.direction === 'same' && (
                          <Minus className="h-3 w-3 text-gray-500" />
                        )}
                      </span>
                    )}
                  </div>
                  <p className="text-xs text-gray-500 truncate">{standing.teamName}</p>
                </div>

                {/* Points */}
                <div className="text-right flex-shrink-0">
                  <span className="text-lg font-bold text-white">{standing.points}</span>
                  <span className="text-xs text-gray-500 ml-1">pts</span>
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* Footer */}
      {standings.length > 6 && (
        <div className="px-5 pb-5">
          <button className="w-full py-2 text-sm text-gray-400 hover:text-white transition-colors">
            View full standings →
          </button>
        </div>
      )}
    </div>
  );
}
