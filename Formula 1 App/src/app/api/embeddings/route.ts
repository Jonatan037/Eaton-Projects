import { NextRequest, NextResponse } from 'next/server';
import { indexLeagueData } from '@/lib/embeddings';
import prisma from '@/lib/db';

/**
 * League Indexing API
 * Triggers embedding generation for a league's data
 */

export async function POST(request: NextRequest) {
  try {
    const { leagueId } = await request.json();

    if (!leagueId) {
      return NextResponse.json(
        { error: 'League ID is required' },
        { status: 400 }
      );
    }

    // Verify league exists
    const league = await prisma.league.findUnique({
      where: { id: leagueId },
      select: { id: true, name: true },
    });

    if (!league) {
      return NextResponse.json(
        { error: 'League not found' },
        { status: 404 }
      );
    }

    // Index league data
    const result = await indexLeagueData(leagueId);

    return NextResponse.json({
      success: result.success,
      leagueId,
      leagueName: league.name,
      documentsIndexed: result.documentsIndexed,
      errors: result.errors.length > 0 ? result.errors : undefined,
      message: result.success
        ? `Successfully indexed ${result.documentsIndexed} documents for ${league.name}`
        : `Indexing completed with ${result.errors.length} errors`,
    });
  } catch (error) {
    console.error('Indexing API error:', error);
    return NextResponse.json(
      { error: 'An error occurred during indexing' },
      { status: 500 }
    );
  }
}

// Get indexing status
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const leagueId = searchParams.get('leagueId');

  if (!leagueId) {
    return NextResponse.json(
      { error: 'League ID is required' },
      { status: 400 }
    );
  }

  try {
    const embeddings = await prisma.leagueEmbedding.findMany({
      where: { leagueId },
      select: {
        documentType: true,
        documentId: true,
        updatedAt: true,
      },
      orderBy: { updatedAt: 'desc' },
    });

    const documentsByType: Record<string, number> = {};
    let lastUpdated: Date | null = null;

    for (const emb of embeddings) {
      documentsByType[emb.documentType] = (documentsByType[emb.documentType] || 0) + 1;
      if (!lastUpdated || emb.updatedAt > lastUpdated) {
        lastUpdated = emb.updatedAt;
      }
    }

    return NextResponse.json({
      leagueId,
      indexed: embeddings.length > 0,
      documentCount: embeddings.length,
      documentsByType,
      lastUpdated: lastUpdated?.toISOString(),
    });
  } catch (error) {
    console.error('Indexing status error:', error);
    return NextResponse.json(
      { error: 'Failed to get indexing status' },
      { status: 500 }
    );
  }
}
