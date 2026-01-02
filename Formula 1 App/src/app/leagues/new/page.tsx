"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import {
  ArrowLeft,
  Trophy,
  Globe,
  Clock,
  Flag,
  Route,
  Calendar,
  Plus,
  X,
  GripVertical,
  Check,
  Loader2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { DashboardLayout } from "@/components/layout/dashboard-layout";

interface Track {
  id: string;
  name: string;
  shortName: string | null;
  country: string;
  countryCode: string | null;
  city: string | null;
  length: number;
  defaultLaps: number;
  miniImageUrl: string | null;
  layoutImageUrl: string | null;
}

interface SelectedTrack extends Track {
  roundNumber: number;
  scheduledAt?: Date;
  hasSprint?: boolean;
}

// Country code to flag emoji mapping
const countryFlags: Record<string, string> = {
  BH: "🇧🇭", SA: "🇸🇦", AU: "🇦🇺", JP: "🇯🇵", CN: "🇨🇳",
  US: "🇺🇸", IT: "🇮🇹", MC: "🇲🇨", CA: "🇨🇦", ES: "🇪🇸",
  AT: "🇦🇹", GB: "🇬🇧", HU: "🇭🇺", BE: "🇧🇪", NL: "🇳🇱",
  AZ: "🇦🇿", SG: "🇸🇬", MX: "🇲🇽", BR: "🇧🇷", QA: "🇶🇦",
  AE: "🇦🇪",
};

function getCountryFlag(countryCode: string | null): string {
  if (!countryCode) return "🏁";
  return countryFlags[countryCode] || "🏁";
}

const TIMEZONES = [
  { value: "America/New_York", label: "Eastern Time (ET)" },
  { value: "America/Chicago", label: "Central Time (CT)" },
  { value: "America/Denver", label: "Mountain Time (MT)" },
  { value: "America/Los_Angeles", label: "Pacific Time (PT)" },
  { value: "Europe/London", label: "London (GMT/BST)" },
  { value: "Europe/Paris", label: "Central European (CET)" },
  { value: "Asia/Tokyo", label: "Japan (JST)" },
  { value: "Australia/Sydney", label: "Sydney (AEST)" },
  { value: "UTC", label: "UTC" },
];

export default function CreateLeaguePage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [tracks, setTracks] = useState<Track[]>([]);
  const [selectedTracks, setSelectedTracks] = useState<SelectedTrack[]>([]);
  const [formData, setFormData] = useState({
    name: "",
    slug: "",
    description: "",
    timezone: "America/New_York",
    visibility: "PUBLIC",
  });

  // Fetch available tracks
  useEffect(() => {
    async function fetchTracks() {
      try {
        const res = await fetch("/api/tracks");
        if (res.ok) {
          const data = await res.json();
          setTracks(data);
        }
      } catch (error) {
        console.error("Failed to fetch tracks:", error);
      }
    }
    fetchTracks();
  }, []);

  // Auto-generate slug from name
  useEffect(() => {
    const slug = formData.name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "");
    setFormData((prev) => ({ ...prev, slug }));
  }, [formData.name]);

  const addTrack = (track: Track) => {
    if (selectedTracks.find((t) => t.id === track.id)) return;

    const newSelectedTrack: SelectedTrack = {
      ...track,
      roundNumber: selectedTracks.length + 1,
      hasSprint: false,
    };
    setSelectedTracks((prev) => [...prev, newSelectedTrack]);
  };

  const removeTrack = (trackId: string) => {
    setSelectedTracks((prev) => {
      const filtered = prev.filter((t) => t.id !== trackId);
      // Renumber rounds
      return filtered.map((t, idx) => ({ ...t, roundNumber: idx + 1 }));
    });
  };

  const toggleSprint = (trackId: string) => {
    setSelectedTracks((prev) =>
      prev.map((t) =>
        t.id === trackId ? { ...t, hasSprint: !t.hasSprint } : t
      )
    );
  };

  const moveTrack = (fromIndex: number, toIndex: number) => {
    setSelectedTracks((prev) => {
      const result = [...prev];
      const [removed] = result.splice(fromIndex, 1);
      result.splice(toIndex, 0, removed);
      // Renumber rounds
      return result.map((t, idx) => ({ ...t, roundNumber: idx + 1 }));
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const form = new FormData();
      form.append("name", formData.name);
      form.append("slug", formData.slug);
      form.append("description", formData.description);
      form.append("timezone", formData.timezone);
      form.append("visibility", formData.visibility);
      form.append("tracks", JSON.stringify(selectedTracks));

      const res = await fetch("/api/leagues", {
        method: "POST",
        body: form,
      });

      if (res.ok) {
        const league = await res.json();
        router.push(`/leagues/${league.slug}`);
      } else {
        const error = await res.json();
        alert(error.message || "Failed to create league");
      }
    } catch (error) {
      console.error("Failed to create league:", error);
      alert("Failed to create league");
    } finally {
      setLoading(false);
    }
  };

  const availableTracks = tracks.filter(
    (t) => !selectedTracks.find((st) => st.id === t.id)
  );

  return (
    <DashboardLayout user={{ email: "" }}>
      <div className="max-w-6xl mx-auto space-y-8">
        {/* Header */}
        <div className="flex items-center gap-4">
          <Link
            href="/dashboard"
            className="flex items-center gap-2 text-gray-400 hover:text-white transition-colors"
          >
            <ArrowLeft className="h-5 w-5" />
          </Link>
          <div>
            <h1 className="text-3xl font-bold text-white flex items-center gap-3">
              <Trophy className="h-8 w-8 text-[#2ECC71]" />
              Create New League
            </h1>
            <p className="text-gray-400 mt-1">
              Set up your F1 league with a custom calendar
            </p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-8">
          {/* Basic Info Section */}
          <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10 p-6">
            <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-[#2ECC71] to-[#27AE60]" />
            <h2 className="text-xl font-semibold text-white mb-6">
              League Details
            </h2>

            <div className="grid gap-6 md:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="name" className="text-gray-300">
                  League Name *
                </Label>
                <Input
                  id="name"
                  value={formData.name}
                  onChange={(e) =>
                    setFormData((prev) => ({ ...prev, name: e.target.value }))
                  }
                  placeholder="e.g., Amigos de America 2026"
                  required
                  className="bg-white/5 border-white/10 text-white placeholder:text-gray-500"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="slug" className="text-gray-300">
                  URL Slug
                </Label>
                <div className="flex items-center">
                  <span className="text-gray-500 text-sm mr-2">
                    /leagues/
                  </span>
                  <Input
                    id="slug"
                    value={formData.slug}
                    onChange={(e) =>
                      setFormData((prev) => ({ ...prev, slug: e.target.value }))
                    }
                    placeholder="amigos-de-america-2026"
                    className="bg-white/5 border-white/10 text-white placeholder:text-gray-500"
                  />
                </div>
              </div>

              <div className="space-y-2 md:col-span-2">
                <Label htmlFor="description" className="text-gray-300">
                  Description
                </Label>
                <Textarea
                  id="description"
                  value={formData.description}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      description: e.target.value,
                    }))
                  }
                  placeholder="Describe your league..."
                  className="bg-white/5 border-white/10 text-white placeholder:text-gray-500 min-h-[80px]"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="timezone" className="text-gray-300">
                  <Clock className="inline h-4 w-4 mr-1" />
                  Timezone
                </Label>
                <Select
                  value={formData.timezone}
                  onValueChange={(value) =>
                    setFormData((prev) => ({ ...prev, timezone: value }))
                  }
                >
                  <SelectTrigger className="bg-white/5 border-white/10 text-white">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {TIMEZONES.map((tz) => (
                      <SelectItem key={tz.value} value={tz.value}>
                        {tz.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="visibility" className="text-gray-300">
                  <Globe className="inline h-4 w-4 mr-1" />
                  Visibility
                </Label>
                <Select
                  value={formData.visibility}
                  onValueChange={(value) =>
                    setFormData((prev) => ({ ...prev, visibility: value }))
                  }
                >
                  <SelectTrigger className="bg-white/5 border-white/10 text-white">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="PUBLIC">Public</SelectItem>
                    <SelectItem value="PRIVATE">Private</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
          </div>

          {/* Track Selection Section */}
          <div className="grid gap-6 lg:grid-cols-2">
            {/* Available Tracks */}
            <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10">
              <div className="p-6 border-b border-white/10">
                <h2 className="text-xl font-semibold text-white flex items-center gap-2">
                  <Route className="h-5 w-5 text-[#3B82F6]" />
                  Available Circuits
                </h2>
                <p className="text-gray-400 text-sm mt-1">
                  Click to add to your calendar
                </p>
              </div>
              <div className="p-4 max-h-[500px] overflow-y-auto space-y-2">
                {availableTracks.length === 0 ? (
                  <p className="text-gray-500 text-center py-8">
                    All circuits have been added to your calendar
                  </p>
                ) : (
                  availableTracks.map((track) => (
                    <button
                      key={track.id}
                      type="button"
                      onClick={() => addTrack(track)}
                      className="w-full flex items-center gap-3 p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 hover:border-[#2ECC71]/50 transition-all group"
                    >
                      {/* Track Mini Image */}
                      <div className="relative w-16 h-10 bg-white/5 rounded-lg overflow-hidden flex-shrink-0">
                        {track.miniImageUrl ? (
                          <Image
                            src={track.miniImageUrl}
                            alt={track.name}
                            fill
                            className="object-contain p-1"
                            unoptimized
                          />
                        ) : (
                          <div className="flex items-center justify-center h-full">
                            <Route className="w-5 h-5 text-gray-600" />
                          </div>
                        )}
                      </div>

                      {/* Track Info */}
                      <div className="flex-1 text-left">
                        <div className="flex items-center gap-2">
                          <span className="text-lg">
                            {getCountryFlag(track.countryCode)}
                          </span>
                          <span className="font-medium text-white group-hover:text-[#2ECC71] transition-colors">
                            {track.name}
                          </span>
                        </div>
                        <p className="text-xs text-gray-500">
                          {track.city || track.country} • {track.length.toFixed(3)}km
                        </p>
                      </div>

                      {/* Add Icon */}
                      <Plus className="h-5 w-5 text-gray-500 group-hover:text-[#2ECC71] transition-colors" />
                    </button>
                  ))
                )}
              </div>
            </div>

            {/* Selected Calendar */}
            <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.08] to-white/[0.02] border border-white/10">
              <div className="p-6 border-b border-white/10">
                <h2 className="text-xl font-semibold text-white flex items-center gap-2">
                  <Calendar className="h-5 w-5 text-[#2ECC71]" />
                  Your Calendar
                  {selectedTracks.length > 0 && (
                    <Badge className="bg-[#2ECC71]/20 text-[#2ECC71] border-[#2ECC71]/30 ml-2">
                      {selectedTracks.length} Rounds
                    </Badge>
                  )}
                </h2>
                <p className="text-gray-400 text-sm mt-1">
                  Drag to reorder, click X to remove
                </p>
              </div>
              <div className="p-4 max-h-[500px] overflow-y-auto space-y-2">
                {selectedTracks.length === 0 ? (
                  <div className="text-center py-12">
                    <Calendar className="h-12 w-12 text-gray-600 mx-auto mb-4" />
                    <p className="text-gray-500">No circuits selected</p>
                    <p className="text-gray-600 text-sm mt-1">
                      Add circuits from the left panel
                    </p>
                  </div>
                ) : (
                  selectedTracks.map((track, index) => (
                    <div
                      key={track.id}
                      className="flex items-center gap-3 p-3 rounded-xl bg-white/5 border border-white/10 group"
                    >
                      {/* Drag Handle */}
                      <div className="flex flex-col gap-1">
                        {index > 0 && (
                          <button
                            type="button"
                            onClick={() => moveTrack(index, index - 1)}
                            className="text-gray-500 hover:text-white transition-colors"
                          >
                            ▲
                          </button>
                        )}
                        {index < selectedTracks.length - 1 && (
                          <button
                            type="button"
                            onClick={() => moveTrack(index, index + 1)}
                            className="text-gray-500 hover:text-white transition-colors"
                          >
                            ▼
                          </button>
                        )}
                      </div>

                      {/* Round Number */}
                      <div className="flex flex-col items-center justify-center rounded-lg bg-[#2ECC71]/20 px-2 py-1 min-w-[45px]">
                        <span className="text-[10px] uppercase tracking-wide text-[#2ECC71]">
                          R
                        </span>
                        <span className="text-lg font-bold text-[#2ECC71]">
                          {track.roundNumber}
                        </span>
                      </div>

                      {/* Flag */}
                      <span className="text-2xl">
                        {getCountryFlag(track.countryCode)}
                      </span>

                      {/* Track Info */}
                      <div className="flex-1">
                        <p className="font-medium text-white text-sm">
                          {track.name}
                        </p>
                        <p className="text-xs text-gray-500">{track.country}</p>
                      </div>

                      {/* Sprint Toggle */}
                      <button
                        type="button"
                        onClick={() => toggleSprint(track.id)}
                        className={`px-2 py-1 rounded text-xs font-medium transition-colors ${
                          track.hasSprint
                            ? "bg-orange-500/20 text-orange-400 border border-orange-500/30"
                            : "bg-white/5 text-gray-500 border border-white/10 hover:text-orange-400"
                        }`}
                      >
                        Sprint
                      </button>

                      {/* Remove */}
                      <button
                        type="button"
                        onClick={() => removeTrack(track.id)}
                        className="text-gray-500 hover:text-red-400 transition-colors p-1"
                      >
                        <X className="h-4 w-4" />
                      </button>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>

          {/* Submit */}
          <div className="flex justify-end gap-4">
            <Button
              type="button"
              variant="outline"
              onClick={() => router.back()}
              className="border-white/10 text-gray-400 hover:text-white"
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={loading || !formData.name}
              className="bg-gradient-to-r from-[#2ECC71] to-[#27AE60] text-white font-semibold hover:from-[#27AE60] hover:to-[#229954] shadow-lg shadow-[#2ECC71]/20"
            >
              {loading ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Creating...
                </>
              ) : (
                <>
                  <Check className="h-4 w-4 mr-2" />
                  Create League
                </>
              )}
            </Button>
          </div>
        </form>
      </div>
    </DashboardLayout>
  );
}
