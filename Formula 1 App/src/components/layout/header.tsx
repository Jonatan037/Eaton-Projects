import Link from 'next/link';
import { getTranslations } from 'next-intl/server';
import { Menu, X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { ThemeToggle } from '@/components/theme-toggle';
import { LocaleToggle } from '@/components/locale-toggle';

export async function Header() {
  const t = await getTranslations('nav');

  return (
    <header className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container mx-auto flex h-16 items-center justify-between px-4 sm:px-6 lg:px-8">
        {/* Logo */}
        <Link href="/" className="flex items-center space-x-2">
          <div className="flex h-8 w-8 items-center justify-center rounded bg-brand-red">
            <span className="text-lg font-bold text-white">A</span>
          </div>
          <span className="text-xl font-bold">
            <span className="text-brand-red">Apex</span>
            <span>Grid</span>
            <span className="text-accent-papaya"> AI</span>
          </span>
        </Link>

        {/* Desktop Navigation */}
        <nav className="hidden md:flex items-center space-x-6">
          <Link
            href="/"
            className="text-sm font-medium text-muted-foreground transition-colors hover:text-foreground"
          >
            {t('home')}
          </Link>
          <Link
            href="/leagues"
            className="text-sm font-medium text-muted-foreground transition-colors hover:text-foreground"
          >
            {t('leagues')}
          </Link>
        </nav>

        {/* Right Side Actions */}
        <div className="flex items-center space-x-2">
          <LocaleToggle />
          <ThemeToggle />
          <div className="hidden md:flex items-center space-x-2">
            <Button asChild variant="ghost" size="sm">
              <Link href="/auth/signin">{t('signIn')}</Link>
            </Button>
            <Button asChild variant="f1" size="sm">
              <Link href="/auth/signup">{t('signUp')}</Link>
            </Button>
          </div>
          
          {/* Mobile menu button */}
          <Button
            variant="ghost"
            size="icon"
            className="md:hidden"
            aria-label="Toggle menu"
          >
            <Menu className="h-5 w-5" />
          </Button>
        </div>
      </div>
    </header>
  );
}
