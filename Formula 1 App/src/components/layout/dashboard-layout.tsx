'use client';

import { useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { usePathname } from 'next/navigation';
import {
  LayoutDashboard,
  Trophy,
  Calendar,
  Users,
  BarChart3,
  Settings,
  HelpCircle,
  ChevronLeft,
  ChevronRight,
  LogOut,
  Bell,
  Search,
  Sparkles,
  Flag,
  MessageSquare,
  CreditCard,
  User,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LocaleToggle } from '@/components/locale-toggle';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

interface DashboardLayoutProps {
  children: React.ReactNode;
  user: {
    email: string;
    name?: string;
  };
}

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { name: 'My Leagues', href: '/leagues', icon: Trophy },
  { name: 'Calendar', href: '/calendar', icon: Calendar },
  { name: 'Analytics', href: '/analytics', icon: BarChart3 },
  { name: 'AI Assistant', href: '/ai-chat', icon: Sparkles },
];

const secondaryNav = [
  { name: 'Drivers', href: '/drivers', icon: Users },
  { name: 'Teams', href: '/teams', icon: Flag },
  { name: 'Results', href: '/results', icon: Trophy },
];

const bottomNav = [
  { name: 'Settings', href: '/settings', icon: Settings },
  { name: 'Billing', href: '/billing', icon: CreditCard },
  { name: 'Help & Support', href: '/help', icon: HelpCircle },
];

export function DashboardLayout({ children, user }: DashboardLayoutProps) {
  const pathname = usePathname();
  const [collapsed, setCollapsed] = useState(false);

  const isActive = (href: string) => {
    if (href === '/dashboard') {
      return pathname === '/dashboard';
    }
    return pathname.startsWith(href);
  };

  return (
    <div className="min-h-screen bg-[#0a0a0a] flex">
      {/* Sidebar */}
      <aside 
        className={`${
          collapsed ? 'w-20' : 'w-64'
        } bg-black/50 border-r border-white/10 flex flex-col transition-all duration-300 fixed h-screen z-40`}
      >
        {/* Logo */}
        <div className="h-16 flex items-center justify-between px-4 border-b border-white/10">
          {!collapsed ? (
            <Link href="/dashboard" className="flex items-center gap-2">
              <Image 
                src="/images/logo.png" 
                alt="ApexGrid AI" 
                width={160} 
                height={40}
                className="h-10 w-auto"
              />
            </Link>
          ) : (
            <Link href="/dashboard" className="mx-auto">
              <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-[#2ECC71] to-[#27AE60] flex items-center justify-center shadow-lg shadow-[#2ECC71]/20">
                <span className="text-xl font-bold text-white">A</span>
              </div>
            </Link>
          )}
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setCollapsed(!collapsed)}
            className={`text-gray-400 hover:text-white hover:bg-white/10 ${collapsed ? 'absolute -right-4 bg-black border border-white/10 rounded-full' : ''}`}
          >
            {collapsed ? <ChevronRight className="h-4 w-4" /> : <ChevronLeft className="h-4 w-4" />}
          </Button>
        </div>

        {/* Main Navigation */}
        <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
          <div className="space-y-1">
            {!collapsed && (
              <p className="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">
                General
              </p>
            )}
            {navigation.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.href);
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={`flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all duration-200 group ${
                    active 
                      ? 'bg-gradient-to-r from-[#2ECC71] to-[#27AE60] text-white shadow-lg shadow-[#2ECC71]/20' 
                      : 'text-gray-400 hover:text-white hover:bg-white/5'
                  } ${collapsed ? 'justify-center' : ''}`}
                  title={collapsed ? item.name : undefined}
                >
                  <Icon className={`h-5 w-5 ${active ? 'text-white' : 'group-hover:text-[#2ECC71]'}`} />
                  {!collapsed && <span className="font-medium">{item.name}</span>}
                </Link>
              );
            })}
          </div>

          <div className="pt-6 space-y-1">
            {!collapsed && (
              <p className="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">
                Championship
              </p>
            )}
            {secondaryNav.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.href);
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={`flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all duration-200 group ${
                    active 
                      ? 'bg-gradient-to-r from-[#2ECC71] to-[#27AE60] text-white shadow-lg shadow-[#2ECC71]/20' 
                      : 'text-gray-400 hover:text-white hover:bg-white/5'
                  } ${collapsed ? 'justify-center' : ''}`}
                  title={collapsed ? item.name : undefined}
                >
                  <Icon className={`h-5 w-5 ${active ? 'text-white' : 'group-hover:text-[#2ECC71]'}`} />
                  {!collapsed && <span className="font-medium">{item.name}</span>}
                </Link>
              );
            })}
          </div>

          <div className="pt-6 space-y-1">
            {!collapsed && (
              <p className="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">
                Account
              </p>
            )}
            {bottomNav.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.href);
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  className={`flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all duration-200 group ${
                    active 
                      ? 'bg-gradient-to-r from-[#2ECC71] to-[#27AE60] text-white shadow-lg shadow-[#2ECC71]/20' 
                      : 'text-gray-400 hover:text-white hover:bg-white/5'
                  } ${collapsed ? 'justify-center' : ''}`}
                  title={collapsed ? item.name : undefined}
                >
                  <Icon className={`h-5 w-5 ${active ? 'text-white' : 'group-hover:text-[#2ECC71]'}`} />
                  {!collapsed && <span className="font-medium">{item.name}</span>}
                </Link>
              );
            })}
          </div>
        </nav>

        {/* Upgrade Card */}
        {!collapsed && (
          <div className="mx-3 mb-4">
            <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-[#2ECC71]/20 to-[#27AE60]/10 border border-[#2ECC71]/30 p-4">
              <div className="flex items-start gap-3">
                <div className="h-10 w-10 rounded-xl bg-[#2ECC71]/20 flex items-center justify-center">
                  <Sparkles className="h-5 w-5 text-[#2ECC71]" />
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-2">
                    <span className="font-semibold text-white text-sm">Upgrade to PRO</span>
                    <span className="text-xs bg-[#2ECC71] text-white px-1.5 py-0.5 rounded font-medium">20% OFF</span>
                  </div>
                  <p className="text-xs text-gray-400 mt-1">
                    Unlimited leagues, AI insights, and priority support.
                  </p>
                  <p className="text-lg font-bold text-white mt-2">$9<span className="text-sm font-normal text-gray-400">/month</span></p>
                  <Button className="w-full mt-3 bg-[#2ECC71] hover:bg-[#27AE60] text-white text-sm font-semibold">
                    Upgrade Now
                  </Button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* User Profile */}
        <div className="border-t border-white/10 p-3">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-white/5 transition-colors ${collapsed ? 'justify-center' : ''}`}>
                <div className="h-9 w-9 rounded-full bg-gradient-to-br from-[#2ECC71] to-[#27AE60] flex items-center justify-center flex-shrink-0">
                  <span className="text-sm font-bold text-white">
                    {user.email?.charAt(0).toUpperCase()}
                  </span>
                </div>
                {!collapsed && (
                  <div className="flex-1 text-left min-w-0">
                    <p className="text-sm font-medium text-white truncate">
                      {user.name || user.email?.split('@')[0]}
                    </p>
                    <p className="text-xs text-gray-500 truncate">{user.email}</p>
                  </div>
                )}
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56 bg-gray-900 border-gray-800">
              <div className="px-2 py-1.5">
                <p className="text-sm font-medium text-white">{user.name || user.email?.split('@')[0]}</p>
                <p className="text-xs text-gray-400 truncate">{user.email}</p>
              </div>
              <DropdownMenuSeparator className="bg-gray-800" />
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
                <form action="/api/auth/signout" method="POST">
                  <button type="submit" className="flex items-center w-full">
                    <LogOut className="mr-2 h-4 w-4" />
                    Sign Out
                  </button>
                </form>
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </aside>

      {/* Main Content */}
      <div className={`flex-1 flex flex-col ${collapsed ? 'ml-20' : 'ml-64'} transition-all duration-300`}>
        {/* Top Header */}
        <header className="h-16 bg-black/50 border-b border-white/10 flex items-center justify-between px-6 sticky top-0 z-30 backdrop-blur-xl">
          <div className="flex items-center gap-4 flex-1 max-w-xl">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-500" />
              <Input
                placeholder="Search leagues, drivers, results..."
                className="pl-10 bg-white/5 border-white/10 text-white placeholder:text-gray-500 focus:border-[#2ECC71]/50 focus:ring-[#2ECC71]/20"
              />
              <kbd className="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none inline-flex h-5 select-none items-center gap-1 rounded border border-white/10 bg-white/5 px-1.5 font-mono text-[10px] font-medium text-gray-400">
                ⌘K
              </kbd>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <LocaleToggle />
            
            <Button variant="ghost" size="icon" className="text-gray-400 hover:text-white hover:bg-white/10 relative">
              <Bell className="h-5 w-5" />
              <span className="absolute top-1.5 right-1.5 h-2 w-2 bg-[#2ECC71] rounded-full" />
            </Button>

            <Button variant="ghost" size="icon" className="text-gray-400 hover:text-white hover:bg-white/10">
              <MessageSquare className="h-5 w-5" />
            </Button>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 p-6 bg-[#0a0a0a]">
          {children}
        </main>
      </div>
    </div>
  );
}
