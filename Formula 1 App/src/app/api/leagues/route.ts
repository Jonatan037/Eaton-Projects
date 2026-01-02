import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/db";
import { createClient } from "@/lib/supabase/server";
import { LeagueCreateSchema } from "@/schemas";

export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    const formData = await request.formData();

    const rawData = {
      name: formData.get("name") as string,
      slug: formData.get("slug") as string,
      description: formData.get("description") as string,
      timezone: formData.get("timezone") as string || "UTC",
      visibility: formData.get("visibility") as string || "PUBLIC",
    };

    // Parse selected tracks
    const tracksJson = formData.get("tracks") as string;
    const selectedTracks = tracksJson ? JSON.parse(tracksJson) : [];

    const validatedData = LeagueCreateSchema.parse(rawData);

    // Create the league with membership
    const league = await prisma.league.create({
      data: {
        ...validatedData,
        memberships: {
          create: {
            userId: user.id,
            role: "OWNER",
          },
        },
      },
    });

    // Create rounds from selected tracks
    if (selectedTracks.length > 0) {
      // Calculate schedule starting from next week
      const startDate = new Date();
      startDate.setDate(startDate.getDate() + 7); // Start next week
      startDate.setHours(21, 0, 0, 0); // 9 PM

      for (const track of selectedTracks) {
        const scheduledDate = new Date(startDate);
        scheduledDate.setDate(startDate.getDate() + (track.roundNumber - 1) * 7); // Weekly

        await prisma.round.create({
          data: {
            leagueId: league.id,
            trackId: track.id,
            roundNumber: track.roundNumber,
            name: track.name.includes("Grand Prix") ? track.name : `${track.name} Grand Prix`,
            scheduledAt: scheduledDate,
            hasQuali: true,
            hasSprint: track.hasSprint || false,
            status: "SCHEDULED",
          },
        });

        // Also create the LeagueTrack association
        await prisma.leagueTrack.upsert({
          where: {
            leagueId_trackId: {
              leagueId: league.id,
              trackId: track.id,
            },
          },
          update: {},
          create: {
            leagueId: league.id,
            trackId: track.id,
            customLaps: track.defaultLaps,
          },
        });
      }
    }

    // Log the action
    await prisma.auditLog.create({
      data: {
        leagueId: league.id,
        userId: user.id,
        action: "CREATED_LEAGUE",
        metadata: {
          leagueName: league.name,
          tracksCount: selectedTracks.length,
        },
      },
    });

    return NextResponse.json(league);
  } catch (error) {
    console.error("Error creating league:", error);
    return NextResponse.json(
      { message: "Failed to create league" },
      { status: 500 }
    );
  }
}

export async function GET() {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
    }

    // Get leagues the user is a member of
    const leagues = await prisma.league.findMany({
      where: {
        memberships: {
          some: {
            userId: user.id,
          },
        },
      },
      include: {
        _count: {
          select: {
            memberships: true,
            teams: true,
            rounds: true,
          },
        },
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return NextResponse.json(leagues);
  } catch (error) {
    console.error("Error fetching leagues:", error);
    return NextResponse.json(
      { message: "Failed to fetch leagues" },
      { status: 500 }
    );
  }
}
