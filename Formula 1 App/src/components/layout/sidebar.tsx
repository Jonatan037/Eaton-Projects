'use client';

import { useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { usePathname } from 'next/navigation';
import {
  LayoutDashboard,
  Trophy,
  Medal,
  Route,
  BarChart3,
  Settings,
  Shield,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip';

interface SidebarProps {
  onCollapsedChange?: (collapsed: boolean) => void;
  defaultCollapsed?: boolean;
}

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { name: 'Leagues', href: '/leagues', icon: Trophy },
  { name: 'Championships', href: '/championships', icon: Medal },
  { name: 'Tracks', href: '/tracks', icon: Route },
  { name: 'Analytics', href: '/analytics', icon: BarChart3 },
  { name: 'Admin', href: '/admin', icon: Shield },
  { name: 'Settings', href: '/settings', icon: Settings },
];

export function Sidebar({ onCollapsedChange, defaultCollapsed = true }: SidebarProps) {
  const pathname = usePathname();
  const [collapsed, setCollapsed] = useState(defaultCollapsed);

  const handleToggle = () => {
    const newState = !collapsed;
    setCollapsed(newState);
    onCollapsedChange?.(newState);
  };

  const isActive = (href: string) => {
    if (href === '/dashboard') {
      return pathname === '/dashboard';
    }
    return pathname.startsWith(href);
  };

  return (
    <TooltipProvider delayDuration={0}>
      <aside
        className={`${
          collapsed ? 'w-[72px]' : 'w-64'
        } bg-[#0d0d0d] border-r border-white/[0.06] flex flex-col transition-all duration-300 fixed h-screen z-40`}
      >
        {/* Logo */}
        <div className="h-16 flex items-center justify-center border-b border-white/[0.06] relative">
          <Link href="/dashboard" className="flex items-center justify-center">
            {collapsed ? (
              <Image
                src="/images/apexgrid-icon.png"
                alt="ApexGrid"
                width={40}
                height={40}
                className="h-9 w-9"
              />
            ) : (
              <Image
                src="/images/apexgrid-logo.png"
                alt="ApexGrid"
                width={180}
                height={45}
                className="h-10 w-auto"
              />
            )}
          </Link>
        </div>

        {/* Toggle Button */}
        <button
          onClick={handleToggle}
          className="absolute -right-3 top-20 h-6 w-6 rounded-full bg-[#1a1a1a] border border-white/10 flex items-center justify-center text-gray-400 hover:text-white hover:bg-[#252525] transition-colors z-50"
        >
          {collapsed ? (
            <ChevronRight className="h-3 w-3" />
          ) : (
            <ChevronLeft className="h-3 w-3" />
          )}
        </button>

        {/* Navigation */}
        <nav className="flex-1 py-4 px-3">
          <ul className="space-y-1">
            {navigation.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.href);

              const linkContent = (
                <Link
                  href={item.href}
                  className={`flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all duration-200 group ${
                    active
                      ? 'bg-gradient-to-r from-[#DC2626] to-[#B91C1C] text-white shadow-lg shadow-red-600/20'
                      : 'text-gray-400 hover:text-white hover:bg-white/[0.04]'
                  } ${collapsed ? 'justify-center px-2' : ''}`}
                >
                  <Icon
                    className={`h-5 w-5 flex-shrink-0 ${
                      active ? 'text-white' : 'group-hover:text-[#EF4444]'
                    }`}
                  />
                  {!collapsed && (
                    <span className="font-medium text-sm">{item.name}</span>
                  )}
                </Link>
              );

              if (collapsed) {
                return (
                  <li key={item.name}>
                    <Tooltip>
                      <TooltipTrigger asChild>{linkContent}</TooltipTrigger>
                      <TooltipContent
                        side="right"
                        className="bg-[#1a1a1a] border-white/10 text-white"
                      >
                        {item.name}
                      </TooltipContent>
                    </Tooltip>
                  </li>
                );
              }

              return <li key={item.name}>{linkContent}</li>;
            })}
          </ul>
        </nav>

        {/* Bottom Section - User Avatar Placeholder */}
        <div className="border-t border-white/[0.06] p-3">
          <div
            className={`flex items-center gap-3 px-2 py-2 rounded-xl hover:bg-white/[0.04] transition-colors cursor-pointer ${
              collapsed ? 'justify-center' : ''
            }`}
          >
            <div className="h-9 w-9 rounded-full bg-gradient-to-br from-[#DC2626] to-[#991B1B] flex items-center justify-center flex-shrink-0">
              <span className="text-sm font-bold text-white">U</span>
            </div>
            {!collapsed && (
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-white truncate">User</p>
                <p className="text-xs text-gray-500 truncate">View Profile</p>
              </div>
            )}
          </div>
        </div>
      </aside>
    </TooltipProvider>
  );
}
