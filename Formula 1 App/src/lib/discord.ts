/**
 * Discord Webhook Helper Functions
 */

// Helper function to send a webhook from server actions
export async function sendDiscordWebhook(
  leagueId: string,
  eventType: string,
  data: Record<string, unknown>
) {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000';
  
  try {
    await fetch(`${baseUrl}/api/webhooks/discord`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ leagueId, eventType, data }),
    });
  } catch (error) {
    console.error('Failed to send Discord webhook:', error);
  }
}
