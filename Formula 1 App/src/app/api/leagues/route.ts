import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/db";
import { createClient } from "@/lib/supabase/server";
import { LeagueRole, ChampionshipStatus, RaceStatus } from "@prisma/client";

// Helper to get or create DB user from Supabase auth
async function getOrCreateDbUser(authUser: { id: string; email?: string }) {
  let dbUser = await prisma.user.findUnique({
    where: { supabaseAuthId: authUser.id },
  });

  if (!dbUser && authUser.email) {
    dbUser = await prisma.user.findUnique({
      where: { email: authUser.email.toLowerCase() },
    });

    if (dbUser) {
      dbUser = await prisma.user.update({
        where: { id: dbUser.id },
        data: { supabaseAuthId: authUser.id },
      });
    }
  }

  if (!dbUser && authUser.email) {
    dbUser = await prisma.user.create({
      data: {
        email: authUser.email.toLowerCase(),
        fullName: authUser.email.split("@")[0],
        supabaseAuthId: authUser.id,
      },
    });
  }

  return dbUser;
}

export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    const dbUser = await getOrCreateDbUser(user);
    if (!dbUser) {
      return NextResponse.json(
        { message: "Could not create user" },
        { status: 500 }
      );
    }

    const formData = await request.formData();

    const name = formData.get("name") as string;
    const slug = formData.get("slug") as string;
    const description = formData.get("description") as string | null;
    const timezone = (formData.get("timezone") as string) || "America/Chicago";
    const isPublic = formData.get("visibility") !== "PRIVATE";

    if (!name || !slug) {
      return NextResponse.json(
        { message: "Name and slug are required" },
        { status: 400 }
      );
    }

    // Check slug availability
    const existingLeague = await prisma.league.findUnique({
      where: { slug },
    });

    if (existingLeague) {
      return NextResponse.json(
        { message: "This slug is already taken" },
        { status: 400 }
      );
    }

    // Parse selected tracks
    const tracksJson = formData.get("tracks") as string;
    const selectedTracks = tracksJson ? JSON.parse(tracksJson) : [];

    // Create the league with owner
    const league = await prisma.league.create({
      data: {
        name,
        slug,
        description,
        timezone,
        isPublic,
        ownerId: dbUser.id,
        members: {
          create: {
            userId: dbUser.id,
            role: LeagueRole.OWNER,
          },
        },
      },
    });

    // If tracks selected, create a championship with those tracks
    if (selectedTracks.length > 0) {
      // Create default championship
      const championship = await prisma.championship.create({
        data: {
          leagueId: league.id,
          name: "Season 1",
          createdById: dbUser.id,
          status: ChampionshipStatus.DRAFT,
          assists: { create: {} },
          scoring: { create: { useF1Default: true } },
          members: {
            create: {
              userId: dbUser.id,
              role: "ADMIN",
            },
          },
        },
      });

      // Create championship tracks and races
      const startDate = new Date();
      startDate.setDate(startDate.getDate() + 7);
      startDate.setHours(21, 0, 0, 0);

      for (const track of selectedTracks) {
        // Create championship track
        const championshipTrack = await prisma.championshipTrack.create({
          data: {
            championshipId: championship.id,
            trackId: track.id,
            roundNumber: track.roundNumber,
            customName: track.name.includes("Grand Prix")
              ? track.name
              : `${track.name} Grand Prix`,
          },
        });

        // Calculate race date
        const scheduledDate = new Date(startDate);
        scheduledDate.setDate(
          startDate.getDate() + (track.roundNumber - 1) * 7
        );

        // Create race
        await prisma.race.create({
          data: {
            championshipId: championship.id,
            championshipTrackId: championshipTrack.id,
            trackId: track.id,
            roundNumber: track.roundNumber,
            name: championshipTrack.customName,
            scheduledDate,
            scheduledTime: "21:00",
            status: RaceStatus.SCHEDULED,
          },
        });
      }
    }

    // Log the action
    await prisma.auditLog.create({
      data: {
        leagueId: league.id,
        userId: dbUser.id,
        action: "CREATED_LEAGUE",
        metadata: {
          leagueName: league.name,
          tracksCount: selectedTracks.length,
        },
      },
    });

    return NextResponse.json({
      success: true,
      league: {
        id: league.id,
        slug: league.slug,
        name: league.name,
      },
    });
  } catch (error) {
    console.error("Error creating league:", error);
    return NextResponse.json(
      { message: "Failed to create league" },
      { status: 500 }
    );
  }
}

export async function GET(request: NextRequest) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    const { searchParams } = new URL(request.url);
    const includePublic = searchParams.get("public") === "true";

    // Build query
    const whereClause: {
      OR?: Array<{ isPublic: boolean } | { ownerId: string } | { members: { some: { userId: string } } }>;
      isPublic?: boolean;
    } = {};

    if (user) {
      const dbUser = await getOrCreateDbUser(user);
      if (dbUser) {
        if (includePublic) {
          whereClause.OR = [
            { isPublic: true },
            { ownerId: dbUser.id },
            { members: { some: { userId: dbUser.id } } },
          ];
        } else {
          whereClause.OR = [
            { ownerId: dbUser.id },
            { members: { some: { userId: dbUser.id } } },
          ];
        }
      }
    } else {
      // Only public leagues for anonymous users
      whereClause.isPublic = true;
    }

    const leagues = await prisma.league.findMany({
      where: whereClause,
      include: {
        owner: {
          select: { id: true, fullName: true, avatar: true },
        },
        _count: {
          select: { members: true, championships: true },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    return NextResponse.json({ leagues });
  } catch (error) {
    console.error("Error fetching leagues:", error);
    return NextResponse.json(
      { message: "Failed to fetch leagues" },
      { status: 500 }
    );
  }
}
