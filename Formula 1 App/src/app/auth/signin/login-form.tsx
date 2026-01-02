'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useTranslations } from 'next-intl';
import { Loader2, Mail } from 'lucide-react';
import { z } from 'zod';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { createClient } from '@/lib/supabase/client';
import { LoginSchema, MagicLinkSchema } from '@/schemas';

type LoginFormData = z.infer<typeof LoginSchema>;

export function LoginForm() {
  const t = useTranslations('auth');
  const tCommon = useTranslations('common');
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [isMagicLinkLoading, setIsMagicLinkLoading] = useState(false);
  const [magicLinkSent, setMagicLinkSent] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
    watch,
  } = useForm<LoginFormData>({
    resolver: zodResolver(LoginSchema),
  });

  const email = watch('email');
  const supabase = createClient();

  async function onSubmit(data: LoginFormData) {
    setIsLoading(true);
    setError(null);

    try {
      const { error } = await supabase.auth.signInWithPassword({
        email: data.email,
        password: data.password!,
      });

      if (error) {
        setError(t('signInError'));
        return;
      }

      router.push('/');
      router.refresh();
    } catch {
      setError(t('signInError'));
    } finally {
      setIsLoading(false);
    }
  }

  async function sendMagicLink() {
    if (!email || !MagicLinkSchema.safeParse({ email }).success) {
      return;
    }

    setIsMagicLinkLoading(true);
    setError(null);

    try {
      const { error } = await supabase.auth.signInWithOtp({
        email,
        options: {
          emailRedirectTo: `${window.location.origin}/auth/callback`,
        },
      });

      if (error) {
        setError(error.message);
        return;
      }

      setMagicLinkSent(true);
    } catch {
      setError('Failed to send magic link');
    } finally {
      setIsMagicLinkLoading(false);
    }
  }

  if (magicLinkSent) {
    return (
      <Card>
        <CardHeader className="text-center">
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-green-100 dark:bg-green-900">
            <Mail className="h-6 w-6 text-green-600 dark:text-green-400" />
          </div>
          <CardTitle>{t('magicLinkSent')}</CardTitle>
          <CardDescription>
            We sent a sign-in link to <strong>{email}</strong>
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Button
            variant="outline"
            className="w-full"
            onClick={() => setMagicLinkSent(false)}
          >
            {tCommon('back')}
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardContent className="pt-6">
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          {error && (
            <div className="rounded-md bg-destructive/10 p-3 text-sm text-destructive">
              {error}
            </div>
          )}

          <div className="space-y-2">
            <Label htmlFor="email">{t('email')}</Label>
            <Input
              id="email"
              type="email"
              placeholder="you@example.com"
              autoComplete="email"
              error={!!errors.email}
              {...register('email')}
            />
            {errors.email && (
              <p className="text-sm text-destructive">{errors.email.message}</p>
            )}
          </div>

          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <Label htmlFor="password">{t('password')}</Label>
              <a
                href="/auth/forgot-password"
                className="text-sm text-muted-foreground hover:text-foreground"
              >
                {t('forgotPassword')}
              </a>
            </div>
            <Input
              id="password"
              type="password"
              placeholder="••••••••"
              autoComplete="current-password"
              error={!!errors.password}
              {...register('password')}
            />
            {errors.password && (
              <p className="text-sm text-destructive">{errors.password.message}</p>
            )}
          </div>

          <Button type="submit" className="w-full" disabled={isLoading}>
            {isLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
            {t('signInTitle')}
          </Button>

          <div className="relative">
            <div className="absolute inset-0 flex items-center">
              <span className="w-full border-t" />
            </div>
            <div className="relative flex justify-center text-xs uppercase">
              <span className="bg-card px-2 text-muted-foreground">
                {t('orContinueWith')}
              </span>
            </div>
          </div>

          <Button
            type="button"
            variant="outline"
            className="w-full"
            onClick={sendMagicLink}
            disabled={isMagicLinkLoading || !email}
          >
            {isMagicLinkLoading && (
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            )}
            <Mail className="mr-2 h-4 w-4" />
            {t('magicLink')}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
