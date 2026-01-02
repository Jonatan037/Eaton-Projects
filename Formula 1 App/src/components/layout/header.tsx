import Link from 'next/link';
import { getTranslations } from 'next-intl/server';
import { Menu, User, LogOut, Settings, Trophy } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { ThemeToggle } from '@/components/theme-toggle';
import { LocaleToggle } from '@/components/locale-toggle';
import { createClient } from '@/lib/supabase/server';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

async function signOut() {
  'use server';
  const supabase = await createClient();
  await supabase.auth.signOut();
}

export async function Header() {
  const t = await getTranslations('nav');
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  return (
    <header className="sticky top-0 z-50 w-full border-b border-white/10 bg-black/80 backdrop-blur-xl supports-[backdrop-filter]:bg-black/60">
      <div className="container mx-auto flex h-16 items-center justify-between px-4 sm:px-6 lg:px-8">
        {/* Logo - Consistent with homepage */}
        <Link href="/" className="flex items-center space-x-2 group">
          <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-gradient-to-br from-[#2ECC71] to-[#27AE60] shadow-lg shadow-[#2ECC71]/20 group-hover:shadow-[#2ECC71]/40 transition-shadow">
            <span className="text-lg font-bold text-white">A</span>
          </div>
          <span className="text-xl font-bold tracking-tight">
            <span className="text-white">APEX</span>
            <span className="text-white">GRID</span>
            <span className="text-[#2ECC71]"> AI</span>
          </span>
        </Link>

        {/* Desktop Navigation */}
        <nav className="hidden md:flex items-center space-x-1">
          <Link
            href="/"
            className="px-4 py-2 text-sm font-medium text-gray-300 transition-colors hover:text-white rounded-lg hover:bg-white/5"
          >
            {t('home')}
          </Link>
          <Link
            href="/leagues"
            className="px-4 py-2 text-sm font-medium text-gray-300 transition-colors hover:text-white rounded-lg hover:bg-white/5"
          >
            {t('leagues')}
          </Link>
        </nav>

        {/* Right Side Actions */}
        <div className="flex items-center space-x-2">
          <LocaleToggle />
          <ThemeToggle />
          
          {user ? (
            /* Authenticated User Menu */
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button 
                  variant="ghost" 
                  size="sm"
                  className="hidden md:flex items-center gap-2 text-gray-300 hover:text-white hover:bg-white/10"
                >
                  <div className="h-7 w-7 rounded-full bg-gradient-to-br from-[#2ECC71] to-[#27AE60] flex items-center justify-center">
                    <span className="text-xs font-bold text-white">
                      {user.email?.charAt(0).toUpperCase()}
                    </span>
                  </div>
                  <span className="max-w-[120px] truncate text-sm">
                    {user.email?.split('@')[0]}
                  </span>
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56 bg-gray-900 border-gray-800">
                <div className="px-2 py-1.5">
                  <p className="text-sm font-medium text-white">{user.email?.split('@')[0]}</p>
                  <p className="text-xs text-gray-400 truncate">{user.email}</p>
                </div>
                <DropdownMenuSeparator className="bg-gray-800" />
                <DropdownMenuItem asChild className="cursor-pointer text-gray-300 hover:text-white focus:text-white focus:bg-white/10">
                  <Link href="/leagues" className="flex items-center">
                    <Trophy className="mr-2 h-4 w-4" />
                    My Leagues
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild className="cursor-pointer text-gray-300 hover:text-white focus:text-white focus:bg-white/10">
                  <Link href="/profile" className="flex items-center">
                    <User className="mr-2 h-4 w-4" />
                    Profile
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild className="cursor-pointer text-gray-300 hover:text-white focus:text-white focus:bg-white/10">
                  <Link href="/settings" className="flex items-center">
                    <Settings className="mr-2 h-4 w-4" />
                    Settings
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuSeparator className="bg-gray-800" />
                <DropdownMenuItem asChild className="cursor-pointer text-red-400 hover:text-red-300 focus:text-red-300 focus:bg-red-500/10">
                  <form action={signOut}>
                    <button type="submit" className="flex items-center w-full">
                      <LogOut className="mr-2 h-4 w-4" />
                      Sign Out
                    </button>
                  </form>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          ) : (
            /* Guest Navigation */
            <div className="hidden md:flex items-center space-x-2">
              <Button asChild variant="ghost" size="sm" className="text-gray-300 hover:text-white hover:bg-white/10">
                <Link href="/auth/signin">{t('signIn')}</Link>
              </Button>
              <Button 
                asChild 
                size="sm" 
                className="bg-gradient-to-r from-[#2ECC71] to-[#27AE60] text-white font-semibold hover:from-[#27AE60] hover:to-[#229954] shadow-lg shadow-[#2ECC71]/20"
              >
                <Link href="/auth/signup">{t('signUp')}</Link>
              </Button>
            </div>
          )}
          
          {/* Mobile menu button */}
          <Button
            variant="ghost"
            size="icon"
            className="md:hidden text-gray-300 hover:text-white hover:bg-white/10"
            aria-label="Toggle menu"
          >
            <Menu className="h-5 w-5" />
          </Button>
        </div>
      </div>
    </header>
  );
}
