'use client';

import { Sparkles, Lock, Crown, ArrowRight } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { cn } from '@/lib/utils';
import { PlanFeatures, UPGRADE_PROMPTS } from '@/lib/subscription';

interface UpgradePromptProps {
  feature: keyof PlanFeatures | 'maxLeagues' | 'maxMembers';
  language?: 'en' | 'es';
  variant?: 'card' | 'inline' | 'banner';
  className?: string;
}

/**
 * Component to show upgrade prompts for gated features
 */
export function UpgradePrompt({
  feature,
  language = 'en',
  variant = 'card',
  className,
}: UpgradePromptProps) {
  const prompt = UPGRADE_PROMPTS[feature as keyof typeof UPGRADE_PROMPTS];
  const message = prompt?.[language] || prompt?.en || 'Upgrade to Pro to unlock this feature';

  const handleUpgrade = () => {
    window.location.href = '/upgrade';
  };

  if (variant === 'inline') {
    return (
      <div className={cn('flex items-center gap-2 text-sm', className)}>
        <Lock className="h-4 w-4 text-muted-foreground" />
        <span className="text-muted-foreground">{message}</span>
        <Button variant="link" size="sm" onClick={handleUpgrade} className="p-0 h-auto text-[#39ff14]">
          {language === 'es' ? 'Actualizar' : 'Upgrade'}
          <ArrowRight className="h-3 w-3 ml-1" />
        </Button>
      </div>
    );
  }

  if (variant === 'banner') {
    return (
      <div className={cn(
        'flex items-center justify-between gap-4 px-4 py-3 rounded-lg',
        'bg-gradient-to-r from-[#39ff14]/10 to-[#39ff14]/5 border border-[#39ff14]/20',
        className
      )}>
        <div className="flex items-center gap-3">
          <Crown className="h-5 w-5 text-[#39ff14]" />
          <span className="text-sm">{message}</span>
        </div>
        <Button 
          size="sm" 
          onClick={handleUpgrade}
          className="bg-[#39ff14] text-black hover:bg-[#32e612]"
        >
          {language === 'es' ? 'Actualizar a Pro' : 'Upgrade to Pro'}
        </Button>
      </div>
    );
  }

  // Card variant (default)
  return (
    <Card className={cn('border-[#39ff14]/20 bg-gradient-to-br from-background to-[#39ff14]/5', className)}>
      <CardHeader className="text-center pb-4">
        <div className="mx-auto mb-4 h-16 w-16 rounded-full bg-[#39ff14]/10 flex items-center justify-center">
          <Sparkles className="h-8 w-8 text-[#39ff14]" />
        </div>
        <CardTitle className="flex items-center justify-center gap-2">
          <Crown className="h-5 w-5 text-[#39ff14]" />
          {language === 'es' ? 'Función Pro' : 'Pro Feature'}
        </CardTitle>
        <CardDescription className="max-w-sm mx-auto">
          {message}
        </CardDescription>
      </CardHeader>
      <CardContent className="text-center">
        <Button 
          onClick={handleUpgrade}
          className="bg-[#39ff14] text-black hover:bg-[#32e612]"
        >
          {language === 'es' ? 'Actualizar a Pro' : 'Upgrade to Pro'}
          <ArrowRight className="h-4 w-4 ml-2" />
        </Button>
        <p className="text-xs text-muted-foreground mt-3">
          {language === 'es' ? 'Desde $9.99/mes' : 'Starting at $9.99/month'}
        </p>
      </CardContent>
    </Card>
  );
}

/**
 * Wrapper component that shows children only for Pro users
 */
interface FeatureGateProps {
  feature: keyof PlanFeatures;
  isPro: boolean;
  children: React.ReactNode;
  fallback?: React.ReactNode;
  language?: 'en' | 'es';
}

export function FeatureGate({
  feature,
  isPro,
  children,
  fallback,
  language = 'en',
}: FeatureGateProps) {
  if (isPro) {
    return <>{children}</>;
  }

  if (fallback) {
    return <>{fallback}</>;
  }

  return <UpgradePrompt feature={feature} language={language} />;
}

/**
 * Badge to show Pro-only features
 */
export function ProBadge({ className }: { className?: string }) {
  return (
    <span className={cn(
      'inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium',
      'bg-[#39ff14]/10 text-[#39ff14] border border-[#39ff14]/20',
      className
    )}>
      <Crown className="h-3 w-3" />
      PRO
    </span>
  );
}
