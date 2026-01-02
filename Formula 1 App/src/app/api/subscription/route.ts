import { NextRequest, NextResponse } from 'next/server';
import { getSubscriptionInfo } from '@/lib/feature-gate';

/**
 * Get subscription info for a user
 */
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const userId = searchParams.get('userId');

  if (!userId) {
    return NextResponse.json(
      { error: 'User ID is required' },
      { status: 400 }
    );
  }

  try {
    const info = await getSubscriptionInfo(userId);

    if (!info) {
      return NextResponse.json(
        { tier: 'FREE', plan: null },
        { status: 200 }
      );
    }

    return NextResponse.json(info);
  } catch (error) {
    console.error('Subscription API error:', error);
    return NextResponse.json(
      { error: 'Failed to get subscription info' },
      { status: 500 }
    );
  }
}
