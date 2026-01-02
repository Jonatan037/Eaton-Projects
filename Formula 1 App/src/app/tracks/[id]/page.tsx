"use client"

import { useEffect, useState } from "react"
import { useParams } from "next/navigation"
import Link from "next/link"
import Image from "next/image"
import { 
  ChevronRight, 
  MapPin, 
  Calendar, 
  Timer, 
  Route, 
  Ruler,
  RotateCcw,
  Trophy,
  Clock,
  Globe
} from "lucide-react"

// Country code to flag emoji mapping
const countryFlags: Record<string, string> = {
  BH: "🇧🇭", SA: "🇸🇦", AU: "🇦🇺", JP: "🇯🇵", CN: "🇨🇳",
  US: "🇺🇸", IT: "🇮🇹", MC: "🇲🇨", CA: "🇨🇦", ES: "🇪🇸",
  AT: "🇦🇹", GB: "🇬🇧", HU: "🇭🇺", BE: "🇧🇪", NL: "🇳🇱",
  AZ: "🇦🇿", SG: "🇸🇬", MX: "🇲🇽", BR: "🇧🇷", QA: "🇶🇦",
  AE: "🇦🇪",
}

// Country code to full name
const countryNames: Record<string, string> = {
  BH: "Bahrain", SA: "Saudi Arabia", AU: "Australia", JP: "Japan", CN: "China",
  US: "United States", IT: "Italy", MC: "Monaco", CA: "Canada", ES: "Spain",
  AT: "Austria", GB: "Great Britain", HU: "Hungary", BE: "Belgium", NL: "Netherlands",
  AZ: "Azerbaijan", SG: "Singapore", MX: "Mexico", BR: "Brazil", QA: "Qatar",
  AE: "United Arab Emirates",
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
  timezone: string | null
}

export default function TrackDetailsPage() {
  const params = useParams()
  const [track, setTrack] = useState<Track | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchTrack() {
      try {
        const res = await fetch(`/api/tracks/${params.id}`)
        if (res.ok) {
          const data = await res.json()
          setTrack(data)
        }
      } catch (error) {
        console.error("Failed to fetch track:", error)
      } finally {
        setLoading(false)
      }
    }
    if (params.id) {
      fetchTrack()
    }
  }, [params.id])

  const getFlag = (countryCode: string | null) => {
    if (!countryCode) return "🏁"
    return countryFlags[countryCode] || "🏁"
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-[#0a0a0a]">
        <div className="animate-pulse">
          <div className="h-80 bg-gray-800" />
          <div className="max-w-7xl mx-auto px-8 py-8">
            <div className="h-10 bg-gray-800 rounded w-1/3 mb-4" />
            <div className="h-6 bg-gray-800 rounded w-1/4" />
          </div>
        </div>
      </div>
    )
  }

  if (!track) {
    return (
      <div className="min-h-screen bg-[#0a0a0a] flex items-center justify-center">
        <div className="text-center">
          <Route className="w-16 h-16 text-gray-700 mx-auto mb-4" />
          <h3 className="text-xl font-bold text-white mb-2">Circuit not found</h3>
          <Link href="/tracks" className="text-red-400 hover:text-red-300">
            ← Back to Circuits
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-[#0a0a0a]">
      <main className="flex-1">
        {/* Hero Section with Track Image */}
        <div className="relative h-96 bg-gradient-to-r from-gray-900 to-gray-800">
          {track.layoutImageUrl ? (
            <Image
              src={track.layoutImageUrl}
              alt={track.name}
              fill
              className="object-cover opacity-50"
              unoptimized
            />
          ) : null}
          <div className="absolute inset-0 bg-gradient-to-t from-gray-950 via-gray-950/50 to-transparent" />
          
          {/* Breadcrumb */}
          <div className="absolute top-8 left-8">
            <div className="flex items-center text-sm text-gray-400">
              <Link href="/" className="hover:text-white">Home</Link>
              <ChevronRight className="w-4 h-4 mx-2" />
              <Link href="/tracks" className="hover:text-white">Circuits</Link>
              <ChevronRight className="w-4 h-4 mx-2" />
              <span className="text-white">{track.name}</span>
            </div>
          </div>

          {/* Track Header */}
          <div className="absolute bottom-8 left-8 right-8">
            <div className="flex items-end justify-between">
              <div>
                <div className="flex items-center gap-3 mb-3">
                  <span className="text-5xl">{getFlag(track.countryCode)}</span>
                  <span className="text-red-400 font-mono text-lg">
                    {track.countryCode}
                  </span>
                </div>
                <h1 className="text-4xl font-bold text-white mb-2">{track.name}</h1>
                <div className="flex items-center gap-2 text-gray-300">
                  <MapPin className="w-5 h-5" />
                  <span className="text-xl">{track.location}, {track.country}</span>
                </div>
              </div>
              
              {/* Mini Track Map */}
              {track.miniImageUrl && (
                <div className="hidden lg:block bg-white/10 backdrop-blur-sm rounded-xl p-4">
                  <Image
                    src={track.miniImageUrl}
                    alt={`${track.name} layout`}
                    width={200}
                    height={150}
                    className="object-contain"
                    unoptimized
                  />
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="max-w-7xl mx-auto px-8 py-8">
          {/* Stats Cards */}
          <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4 mb-8">
            <StatCard 
              icon={<Ruler className="w-5 h-5" />}
              label="Circuit Length"
              value={`${track.length.toFixed(3)} km`}
            />
            <StatCard 
              icon={<RotateCcw className="w-5 h-5" />}
              label="Turns"
              value={track.turns?.toString() || "-"}
            />
            <StatCard 
              icon={<Route className="w-5 h-5" />}
              label="Race Distance"
              value={track.raceDistance ? `${track.raceDistance.toFixed(3)} km` : "-"}
            />
            <StatCard 
              icon={<Calendar className="w-5 h-5" />}
              label="First Grand Prix"
              value={track.firstGrandPrix?.toString() || "-"}
            />
            <StatCard 
              icon={<Timer className="w-5 h-5" />}
              label="Lap Record"
              value={track.lapRecord || "-"}
            />
            <StatCard 
              icon={<Globe className="w-5 h-5" />}
              label="Timezone"
              value={track.timezone || "-"}
            />
          </div>

          {/* Lap Record Section */}
          {track.lapRecord && track.lapRecordHolder && (
            <div className="bg-gradient-to-r from-red-900/30 to-red-800/30 border border-red-800/50 rounded-xl p-6 mb-8">
              <div className="flex items-center gap-3 mb-4">
                <Trophy className="w-6 h-6 text-yellow-400" />
                <h2 className="text-xl font-bold text-white">Lap Record</h2>
              </div>
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-3xl font-mono font-bold text-white mb-1">
                    {track.lapRecord}
                  </div>
                  <div className="text-gray-400">
                    Set by <span className="text-white font-medium">{track.lapRecordHolder}</span>
                    {track.lapRecordYear && (
                      <span className="text-gray-500"> ({track.lapRecordYear})</span>
                    )}
                  </div>
                </div>
                <Clock className="w-12 h-12 text-red-500/30" />
              </div>
            </div>
          )}

          {/* Track Layout Full Size */}
          <div className="bg-gray-900 rounded-xl border border-gray-800 overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-800">
              <h2 className="text-xl font-bold text-white">Circuit Layout</h2>
            </div>
            <div className="p-8 flex items-center justify-center min-h-[400px]">
              {track.miniImageUrl ? (
                <Image
                  src={track.miniImageUrl}
                  alt={`${track.name} layout`}
                  width={600}
                  height={400}
                  className="object-contain"
                  unoptimized
                />
              ) : (
                <div className="text-center text-gray-500">
                  <Route className="w-24 h-24 mx-auto mb-4 opacity-50" />
                  <p>No circuit layout available</p>
                </div>
              )}
            </div>
          </div>

          {/* Circuit Facts */}
          <div className="mt-8 grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="bg-gray-900 rounded-xl border border-gray-800 p-6">
              <h3 className="text-lg font-bold text-white mb-4">Circuit Facts</h3>
              <dl className="space-y-3">
                <FactItem label="Country" value={countryNames[track.countryCode || ""] || track.country} />
                <FactItem label="City" value={track.location} />
                <FactItem label="Circuit Length" value={`${track.length.toFixed(3)} km`} />
                <FactItem label="Number of Turns" value={track.turns?.toString() || "N/A"} />
                <FactItem label="Race Distance" value={track.raceDistance ? `${track.raceDistance.toFixed(3)} km` : "N/A"} />
                <FactItem label="First Grand Prix" value={track.firstGrandPrix?.toString() || "N/A"} />
              </dl>
            </div>

            <div className="bg-gray-900 rounded-xl border border-gray-800 p-6">
              <h3 className="text-lg font-bold text-white mb-4">Technical Information</h3>
              <dl className="space-y-3">
                <FactItem label="Lap Record" value={track.lapRecord || "N/A"} />
                <FactItem label="Record Holder" value={track.lapRecordHolder || "N/A"} />
                <FactItem label="Record Year" value={track.lapRecordYear?.toString() || "N/A"} />
                <FactItem label="Timezone" value={track.timezone || "N/A"} />
                <FactItem label="Track ID" value={track.id} />
              </dl>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}

function StatCard({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="bg-gray-900 border border-gray-800 rounded-xl p-4">
      <div className="flex items-center gap-2 text-gray-400 mb-2">
        {icon}
        <span className="text-xs uppercase tracking-wide">{label}</span>
      </div>
      <div className="text-xl font-bold text-white">{value}</div>
    </div>
  )
}

function FactItem({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex justify-between items-center py-2 border-b border-gray-800 last:border-0">
      <dt className="text-gray-400">{label}</dt>
      <dd className="text-white font-medium">{value}</dd>
    </div>
  )
}
