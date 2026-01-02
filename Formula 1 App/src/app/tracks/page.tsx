"use client"

import { useEffect, useState } from "react"
import Link from "next/link"
import Image from "next/image"
import { ChevronRight, MapPin, Flag, Calendar, Timer, Route } from "lucide-react"

// Country code to flag emoji mapping
const countryFlags: Record<string, string> = {
  BH: "🇧🇭", SA: "🇸🇦", AU: "🇦🇺", JP: "🇯🇵", CN: "🇨🇳",
  US: "🇺🇸", IT: "🇮🇹", MC: "🇲🇨", CA: "🇨🇦", ES: "🇪🇸",
  AT: "🇦🇹", GB: "🇬🇧", HU: "🇭🇺", BE: "🇧🇪", NL: "🇳🇱",
  AZ: "🇦🇿", SG: "🇸🇬", MX: "🇲🇽", BR: "🇧🇷", QA: "🇶🇦",
  AE: "🇦🇪",
}

interface Track {
  id: string
  name: string
  location: string
  country: string
  countryCode: string | null
  length: number
  turns: number | null
  raceDistance: number | null
  firstGrandPrix: number | null
  lapRecord: string | null
  lapRecordHolder: string | null
  lapRecordYear: number | null
  miniImageUrl: string | null
  layoutImageUrl: string | null
}

export default function TracksPage() {
  const [tracks, setTracks] = useState<Track[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")

  useEffect(() => {
    async function fetchTracks() {
      try {
        const res = await fetch("/api/tracks")
        if (res.ok) {
          const data = await res.json()
          setTracks(data)
        }
      } catch (error) {
        console.error("Failed to fetch tracks:", error)
      } finally {
        setLoading(false)
      }
    }
    fetchTracks()
  }, [])

  const filteredTracks = tracks.filter(track =>
    track.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    track.country.toLowerCase().includes(searchQuery.toLowerCase()) ||
    track.location.toLowerCase().includes(searchQuery.toLowerCase())
  )

  const getFlag = (countryCode: string | null) => {
    if (!countryCode) return "🏁"
    return countryFlags[countryCode] || "🏁"
  }

  return (
    <div className="min-h-screen bg-[#0a0a0a]">
      {/* Header */}
      <div className="bg-gradient-to-r from-red-600 to-red-800 px-8 py-12">
        <div className="max-w-7xl mx-auto">
          <div className="flex items-center text-sm text-red-200 mb-4">
            <Link href="/dashboard" className="hover:text-white">Dashboard</Link>
            <ChevronRight className="w-4 h-4 mx-2" />
            <span className="text-white">Circuits</span>
          </div>
          <h1 className="text-4xl font-bold text-white mb-2">F1 Circuits</h1>
            <p className="text-red-100">
              Explore all Formula 1 circuits around the world
            </p>
          </div>
        </div>

        {/* Search */}
        <div className="max-w-7xl mx-auto px-8 py-6">
          <div className="relative">
            <input
              type="text"
              placeholder="Search circuits by name, country, or location..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full md:w-96 bg-gray-900 border border-gray-700 rounded-lg px-4 py-3 text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent"
            />
          </div>
        </div>

        {/* Tracks Grid */}
        <div className="max-w-7xl mx-auto px-8 pb-12">
          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[...Array(6)].map((_, i) => (
                <div key={i} className="bg-gray-900 rounded-xl overflow-hidden animate-pulse">
                  <div className="h-48 bg-gray-800" />
                  <div className="p-6 space-y-3">
                    <div className="h-6 bg-gray-800 rounded w-3/4" />
                    <div className="h-4 bg-gray-800 rounded w-1/2" />
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredTracks.map((track) => (
                <Link 
                  key={track.id} 
                  href={`/tracks/${track.id}`}
                  className="group bg-gray-900 rounded-xl overflow-hidden border border-gray-800 hover:border-red-500 transition-all duration-300 hover:shadow-lg hover:shadow-red-500/10"
                >
                  {/* Track Image */}
                  <div className="relative h-48 bg-gray-800 overflow-hidden">
                    {track.layoutImageUrl ? (
                      <Image
                        src={track.layoutImageUrl}
                        alt={track.name}
                        fill
                        className="object-cover group-hover:scale-105 transition-transform duration-300"
                        unoptimized
                      />
                    ) : track.miniImageUrl ? (
                      <Image
                        src={track.miniImageUrl}
                        alt={track.name}
                        fill
                        className="object-contain p-6 group-hover:scale-105 transition-transform duration-300"
                        unoptimized
                      />
                    ) : (
                      <div className="flex items-center justify-center h-full">
                        <Route className="w-16 h-16 text-gray-700" />
                      </div>
                    )}
                    {/* Country Flag Overlay */}
                    <div className="absolute top-4 left-4 bg-black/70 backdrop-blur-sm rounded-lg px-3 py-1.5 flex items-center gap-2">
                      <span className="text-2xl">{getFlag(track.countryCode)}</span>
                      <span className="text-white font-medium">{track.countryCode}</span>
                    </div>
                  </div>

                  {/* Track Info */}
                  <div className="p-6">
                    <h3 className="text-xl font-bold text-white mb-2 group-hover:text-red-400 transition-colors">
                      {track.name}
                    </h3>
                    <div className="flex items-center gap-1 text-gray-400 mb-4">
                      <MapPin className="w-4 h-4" />
                      <span>{track.location}, {track.country}</span>
                    </div>

                    {/* Stats */}
                    <div className="grid grid-cols-3 gap-4 text-center">
                      <div className="bg-gray-800 rounded-lg p-2">
                        <div className="text-white font-bold">{track.length.toFixed(3)}</div>
                        <div className="text-xs text-gray-500">km</div>
                      </div>
                      <div className="bg-gray-800 rounded-lg p-2">
                        <div className="text-white font-bold">{track.turns || "-"}</div>
                        <div className="text-xs text-gray-500">Turns</div>
                      </div>
                      <div className="bg-gray-800 rounded-lg p-2">
                        <div className="text-white font-bold">{track.firstGrandPrix || "-"}</div>
                        <div className="text-xs text-gray-500">First GP</div>
                      </div>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          )}

          {!loading && filteredTracks.length === 0 && (
            <div className="text-center py-12">
              <Route className="w-16 h-16 text-gray-700 mx-auto mb-4" />
              <h3 className="text-xl font-bold text-white mb-2">No circuits found</h3>
              <p className="text-gray-400">Try adjusting your search query</p>
            </div>
          )}
        </div>
    </div>
  )
}
