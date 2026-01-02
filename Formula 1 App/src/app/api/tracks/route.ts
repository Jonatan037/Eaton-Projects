import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/db';

export async function GET(req: NextRequest) {
  try {
    const tracks = await prisma.track.findMany({
      orderBy: { name: 'asc' },
    });

    return NextResponse.json(tracks);
  } catch (error) {
    console.error('Tracks API error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
