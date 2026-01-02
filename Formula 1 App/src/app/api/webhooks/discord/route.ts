import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/db';
import { DiscordWebhookSchema } from '@/schemas';

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { leagueId, eventType, data, webhookUrl: providedUrl } = body;

    // If webhook URL is provided directly, use it
    // Otherwise, fetch from the league
    let webhookUrl = providedUrl;
    
    if (!webhookUrl && leagueId) {
      const league = await prisma.league.findUnique({
        where: { id: leagueId },
        select: { discordWebhookUrl: true, name: true },
      });

      if (!league || !league.discordWebhookUrl) {
        return NextResponse.json(
          { error: 'No webhook configured for this league' },
          { status: 400 }
        );
      }
      webhookUrl = league.discordWebhookUrl;
    }

    if (!webhookUrl) {
      return NextResponse.json(
        { error: 'No webhook URL provided' },
        { status: 400 }
      );
    }

    // Build Discord embed based on event type
    let embed;

    switch (eventType) {
      case 'RACE_RESULTS':
        embed = {
          title: `🏁 Race Results: ${data.roundName}`,
          description: data.trackName,
          color: 0xE10600, // F1 Red
          fields: [
            {
              name: '🥇 Winner',
              value: data.winner || 'TBD',
              inline: true,
            },
            {
              name: '🥈 Second',
              value: data.second || 'TBD',
              inline: true,
            },
            {
              name: '🥉 Third',
              value: data.third || 'TBD',
              inline: true,
            },
            ...(data.fastestLap ? [{
              name: '⚡ Fastest Lap',
              value: data.fastestLap,
              inline: true,
            }] : []),
          ],
          timestamp: new Date().toISOString(),
          footer: {
            text: data.leagueName || 'ApexGrid AI',
          },
        };
        break;

      case 'STANDINGS_UPDATE':
        const standingsFields = data.standings?.slice(0, 10).map((s: { position: number; name: string; points: number }, i: number) => ({
          name: `${i + 1}. ${s.name}`,
          value: `${s.points} pts`,
          inline: true,
        })) || [];

        embed = {
          title: `🏆 Championship Standings Update`,
          description: `After ${data.roundsCompleted} rounds`,
          color: 0xFF8700, // Papaya
          fields: standingsFields,
          timestamp: new Date().toISOString(),
          footer: {
            text: data.leagueName || 'ApexGrid AI',
          },
        };
        break;

      case 'NEW_ROUND':
        embed = {
          title: `📅 New Round Scheduled`,
          description: `Round ${data.roundNumber}: ${data.roundName}`,
          color: 0x00D4AA, // Teal
          fields: [
            {
              name: '🏎️ Track',
              value: data.trackName,
              inline: true,
            },
            {
              name: '📍 Country',
              value: data.country,
              inline: true,
            },
            {
              name: '🗓️ Date',
              value: data.scheduledAt,
              inline: true,
            },
            ...(data.hasSprint ? [{
              name: '⚡ Format',
              value: 'Sprint Weekend',
              inline: true,
            }] : []),
          ],
          timestamp: new Date().toISOString(),
          footer: {
            text: data.leagueName || 'ApexGrid AI',
          },
        };
        break;

      case 'MEMBER_JOINED':
        embed = {
          title: `👋 New Member`,
          description: `${data.memberName} has joined the league!`,
          color: 0x5865F2, // Discord Blurple
          timestamp: new Date().toISOString(),
          footer: {
            text: data.leagueName || 'ApexGrid AI',
          },
        };
        break;

      case 'RACE_REMINDER':
        embed = {
          title: `⏰ Race Reminder`,
          description: `${data.roundName} starts soon!`,
          color: 0xFFD700, // Gold
          fields: [
            {
              name: '🏎️ Track',
              value: data.trackName,
              inline: true,
            },
            {
              name: '⏰ Time',
              value: data.scheduledAt,
              inline: true,
            },
          ],
          timestamp: new Date().toISOString(),
          footer: {
            text: data.leagueName || 'ApexGrid AI',
          },
        };
        break;

      default:
        embed = {
          title: data.title || 'Notification',
          description: data.message || '',
          color: 0xE10600,
          timestamp: new Date().toISOString(),
          footer: {
            text: data.leagueName || 'ApexGrid AI',
          },
        };
    }

    // Send to Discord
    const discordPayload = {
      username: 'ApexGrid AI',
      avatar_url: 'https://apexgrid.ai/logo.png', // Update with actual logo URL
      embeds: [embed],
    };

    const validated = DiscordWebhookSchema.parse({
      webhookUrl: webhookUrl,
      notifyRaces: false,
      notifyResults: true,
    });

    const discordResponse = await fetch(validated.webhookUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(discordPayload),
    });

    if (!discordResponse.ok) {
      const errorText = await discordResponse.text();
      console.error('Discord webhook error:', errorText);
      return NextResponse.json(
        { error: 'Failed to send Discord notification', metadata: errorText },
        { status: 500 }
      );
    }

    // Log the webhook call
    if (leagueId) {
      await prisma.auditLog.create({
        data: {
          leagueId,
          action: 'DISCORD_WEBHOOK_SENT',
          metadata: { eventType },
        },
      });
    }

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Webhook error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
