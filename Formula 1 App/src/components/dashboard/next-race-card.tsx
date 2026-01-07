'use client';

import { Flag, Clock, MapPin, Calendar } from 'lucide-react';
import Image from 'next/image';

interface NextRaceCardProps {
  race: {
    name: string;
    trackName: string;
    country: string;
    scheduledDate: Date | string | null;
    scheduledTime: string | null;
    roundNumber: number;
    leagueName: string;
    championshipName: string;
    trackSlug?: string;
  } | null;
}

export function NextRaceCard({ race }: NextRaceCardProps) {
  if (!race) {
    return (
      <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.06] to-white/[0.02] border border-white/[0.06] p-6">
        <div className="flex items-center gap-3 mb-4">
          <div className="h-10 w-10 rounded-xl bg-[#DC2626]/20 flex items-center justify-center">
            <Flag className="h-5 w-5 text-[#DC2626]" />
          </div>
          <h3 className="text-lg font-semibold text-white">Next Race</h3>
        </div>
        <div className="text-center py-8">
          <Calendar className="h-12 w-12 text-gray-600 mx-auto mb-3" />
          <p className="text-gray-400">No upcoming races</p>
          <p className="text-sm text-gray-500 mt-1">Join a league to see scheduled races</p>
        </div>
      </div>
    );
  }

  const raceDate = race.scheduledDate ? new Date(race.scheduledDate) : null;
  const daysUntil = raceDate 
    ? Math.ceil((raceDate.getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24))
    : null;

  return (
    <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.06] to-white/[0.02] border border-white/[0.06]">
      {/* Header */}
      <div className="p-5 border-b border-white/[0.06]">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="h-10 w-10 rounded-xl bg-[#DC2626]/20 flex items-center justify-center">
              <Flag className="h-5 w-5 text-[#DC2626]" />
            </div>
            <div>
              <h3 className="text-lg font-semibold text-white">Next Race</h3>
              <p className="text-xs text-gray-500">{race.leagueName}</p>
            </div>
          </div>
          {daysUntil !== null && (
            <div className="bg-[#DC2626]/20 text-[#EF4444] px-3 py-1.5 rounded-full text-sm font-medium">
              {daysUntil === 0 ? 'Today' : daysUntil === 1 ? 'Tomorrow' : `${daysUntil} days`}
            </div>
          )}
        </div>
      </div>

      {/* Track Preview */}
      <div className="relative h-32 bg-gradient-to-br from-[#1a1a1a] to-[#0d0d0d] flex items-center justify-center">
        {race.trackSlug ? (
          <Image
            src={`/images/tracks/layout/${race.trackSlug}.avif`}
            alt={race.trackName}
            width={200}
            height={100}
            className="h-24 w-auto opacity-60"
            onError={(e) => {
              (e.target as HTMLImageElement).style.display = 'none';
            }}
          />
        ) : (
          <div className="text-6xl font-bold text-white/10">R{race.roundNumber}</div>
        )}
        {/* Gradient overlay */}
        <div className="absolute inset-0 bg-gradient-to-t from-[#0d0d0d] via-transparent to-transparent" />
      </div>

      {/* Race Info */}
      <div className="p-5 space-y-4">
        <div>
          <div className="flex items-center gap-2 text-xs text-gray-500 mb-1">
            <span className="bg-white/[0.06] px-2 py-0.5 rounded">Round {race.roundNumber}</span>
            <span>{race.championshipName}</span>
          </div>
          <h4 className="text-xl font-bold text-white">{race.name || race.trackName}</h4>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div className="flex items-center gap-2 text-gray-400">
            <MapPin className="h-4 w-4 text-gray-500" />
            <span className="text-sm">{race.country}</span>
          </div>
          <div className="flex items-center gap-2 text-gray-400">
            <Calendar className="h-4 w-4 text-gray-500" />
            <span className="text-sm">
              {raceDate 
                ? raceDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
                : 'TBD'}
            </span>
          </div>
        </div>

        <div className="flex items-center gap-2 pt-2 border-t border-white/[0.06]">
          <Clock className="h-4 w-4 text-[#DC2626]" />
          <span className="text-sm text-white font-medium">
            {race.scheduledTime || 'Time TBD'}
          </span>
        </div>
      </div>
    </div>
  );
}
