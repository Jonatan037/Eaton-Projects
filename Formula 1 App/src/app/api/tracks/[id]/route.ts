import { NextRequest, NextResponse } from "next/server"
import prisma from "@/lib/db"

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    
    const track = await prisma.track.findUnique({
      where: { id },
    })

    if (!track) {
      return NextResponse.json(
        { error: "Track not found" },
        { status: 404 }
      )
    }

    return NextResponse.json(track)
  } catch (error) {
    console.error("Track API error:", error)
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    )
  }
}
