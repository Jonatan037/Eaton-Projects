'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { 
  Bell, 
  Save, 
  Loader2, 
  Send, 
  CheckCircle2, 
  XCircle,
  AlertCircle,
  ExternalLink,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { DiscordWebhookSchema } from '@/schemas';

// Extended schema for the settings form
const WebhookSettingsSchema = z.object({
  webhookUrl: z.string()
    .url('Must be a valid URL')
    .startsWith('https://discord.com/api/webhooks/', 'Must be a Discord webhook URL')
    .or(z.literal('')),
  notifyRaces: z.boolean().default(false),
  notifyResults: z.boolean().default(false),
  notifyNewMembers: z.boolean().default(false),
  notifyStandings: z.boolean().default(false),
});

type WebhookSettingsData = z.infer<typeof WebhookSettingsSchema>;

interface WebhookSettingsProps {
  leagueId: string;
  leagueName: string;
  initialData?: {
    webhookUrl?: string | null;
    notifyRaces?: boolean;
    notifyResults?: boolean;
  };
  onSave: (data: WebhookSettingsData) => Promise<void>;
}

type TestStatus = 'idle' | 'testing' | 'success' | 'error';

export function WebhookSettings({
  leagueId,
  leagueName,
  initialData,
  onSave,
}: WebhookSettingsProps) {
  const [isSaving, setIsSaving] = useState(false);
  const [testStatus, setTestStatus] = useState<TestStatus>('idle');
  const [testError, setTestError] = useState<string | null>(null);

  const form = useForm<WebhookSettingsData>({
    resolver: zodResolver(WebhookSettingsSchema),
    defaultValues: {
      webhookUrl: initialData?.webhookUrl || '',
      notifyRaces: initialData?.notifyRaces ?? false,
      notifyResults: initialData?.notifyResults ?? false,
      notifyNewMembers: false,
      notifyStandings: false,
    },
  });

  const webhookUrl = form.watch('webhookUrl');
  const hasWebhook = webhookUrl && webhookUrl.length > 0;

  // Handle save
  const handleSubmit = async (data: WebhookSettingsData) => {
    setIsSaving(true);
    try {
      await onSave(data);
    } finally {
      setIsSaving(false);
    }
  };

  // Test webhook
  const testWebhook = async () => {
    if (!webhookUrl) return;

    setTestStatus('testing');
    setTestError(null);

    try {
      const response = await fetch('/api/webhooks/discord', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          webhookUrl,
          eventType: 'TEST',
          data: {
            title: '🔔 Test Notification',
            message: `This is a test notification from ${leagueName}. If you can see this, your webhook is configured correctly!`,
            leagueName,
          },
        }),
      });

      if (response.ok) {
        setTestStatus('success');
        setTimeout(() => setTestStatus('idle'), 5000);
      } else {
        const data = await response.json();
        throw new Error(data.error || 'Failed to send test notification');
      }
    } catch (error) {
      setTestStatus('error');
      setTestError(error instanceof Error ? error.message : 'Unknown error');
      setTimeout(() => setTestStatus('idle'), 10000);
    }
  };

  return (
    <div className="space-y-6">
      {/* Webhook Configuration */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Bell className="h-5 w-5 text-[#5865F2]" />
            Discord Webhook
          </CardTitle>
          <CardDescription>
            Connect your Discord server to receive league notifications
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-6">
            {/* Webhook URL */}
            <div className="space-y-2">
              <Label htmlFor="webhookUrl">Webhook URL</Label>
              <div className="flex gap-2">
                <Input
                  id="webhookUrl"
                  type="url"
                  placeholder="https://discord.com/api/webhooks/..."
                  {...form.register('webhookUrl')}
                  className="flex-1"
                />
                <Button
                  type="button"
                  variant="outline"
                  onClick={testWebhook}
                  disabled={!hasWebhook || testStatus === 'testing'}
                >
                  {testStatus === 'testing' ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : testStatus === 'success' ? (
                    <CheckCircle2 className="h-4 w-4 text-green-500" />
                  ) : testStatus === 'error' ? (
                    <XCircle className="h-4 w-4 text-red-500" />
                  ) : (
                    <Send className="h-4 w-4" />
                  )}
                  <span className="ml-2">Test</span>
                </Button>
              </div>
              {form.formState.errors.webhookUrl && (
                <p className="text-sm text-destructive">
                  {form.formState.errors.webhookUrl.message}
                </p>
              )}
              <p className="text-sm text-muted-foreground">
                Create a webhook in your Discord server settings → Integrations → Webhooks
              </p>
            </div>

            {/* Test Result */}
            {testStatus === 'success' && (
              <Alert className="border-green-500/50 bg-green-500/10">
                <CheckCircle2 className="h-4 w-4 text-green-500" />
                <AlertTitle>Success!</AlertTitle>
                <AlertDescription>
                  Test notification sent. Check your Discord channel.
                </AlertDescription>
              </Alert>
            )}

            {testStatus === 'error' && (
              <Alert variant="destructive">
                <XCircle className="h-4 w-4" />
                <AlertTitle>Failed to send test</AlertTitle>
                <AlertDescription>
                  {testError || 'Could not send notification. Check if the webhook URL is valid.'}
                </AlertDescription>
              </Alert>
            )}

            {/* Notification Toggles */}
            {hasWebhook && (
              <div className="space-y-4 pt-4 border-t">
                <h4 className="font-medium">Notification Settings</h4>
                
                <div className="space-y-4">
                  {/* Race Announcements */}
                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label htmlFor="notifyRaces" className="font-normal">
                        Race Announcements
                      </Label>
                      <p className="text-sm text-muted-foreground">
                        Notify when a new round is scheduled or race day reminders
                      </p>
                    </div>
                    <Switch
                      id="notifyRaces"
                      checked={form.watch('notifyRaces')}
                      onCheckedChange={(checked: boolean) => form.setValue('notifyRaces', checked)}
                    />
                  </div>

                  {/* Result Posts */}
                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label htmlFor="notifyResults" className="font-normal">
                        Race Results
                      </Label>
                      <p className="text-sm text-muted-foreground">
                        Post results automatically after each race is completed
                      </p>
                    </div>
                    <Switch
                      id="notifyResults"
                      checked={form.watch('notifyResults')}
                      onCheckedChange={(checked: boolean) => form.setValue('notifyResults', checked)}
                    />
                  </div>

                  {/* New Members */}
                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label htmlFor="notifyNewMembers" className="font-normal">
                        New Members
                      </Label>
                      <p className="text-sm text-muted-foreground">
                        Announce when someone joins the league
                      </p>
                    </div>
                    <Switch
                      id="notifyNewMembers"
                      checked={form.watch('notifyNewMembers')}
                      onCheckedChange={(checked: boolean) => form.setValue('notifyNewMembers', checked)}
                    />
                  </div>

                  {/* Standings Updates */}
                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label htmlFor="notifyStandings" className="font-normal">
                        Standings Updates
                      </Label>
                      <p className="text-sm text-muted-foreground">
                        Post championship standings after each race
                      </p>
                    </div>
                    <Switch
                      id="notifyStandings"
                      checked={form.watch('notifyStandings')}
                      onCheckedChange={(checked: boolean) => form.setValue('notifyStandings', checked)}
                    />
                  </div>
                </div>
              </div>
            )}

            {/* Save Button */}
            <div className="flex justify-end pt-4">
              <Button type="submit" variant="f1" disabled={isSaving}>
                {isSaving ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Saving...
                  </>
                ) : (
                  <>
                    <Save className="h-4 w-4 mr-2" />
                    Save Settings
                  </>
                )}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>

      {/* Help Section */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">How to set up Discord Webhooks</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3 text-sm text-muted-foreground">
          <ol className="list-decimal list-inside space-y-2">
            <li>Open your Discord server settings</li>
            <li>Go to <strong>Integrations</strong> → <strong>Webhooks</strong></li>
            <li>Click <strong>New Webhook</strong></li>
            <li>Choose the channel where notifications should be posted</li>
            <li>Copy the <strong>Webhook URL</strong> and paste it above</li>
            <li>Click <strong>Test</strong> to verify it works</li>
          </ol>
          <div className="pt-2">
            <a 
              href="https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-1 text-brand-neon hover:underline"
            >
              Learn more about Discord webhooks
              <ExternalLink className="h-3 w-3" />
            </a>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
