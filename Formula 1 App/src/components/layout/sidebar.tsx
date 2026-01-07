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
  const [collapsed] = useState(defaultCollapsed);

  const isActive = (href: string) => {
    if (href === '/dashboard') {
      return pathname === '/dashboard';
    }
    return pathname.startsWith(href);
  };

  return (
    <TooltipProvider delayDuration={0}>
      <aside className="w-16 bg-[#0c0c0c] flex flex-col fixed h-screen z-40">
        {/* Logo */}
        <div className="h-14 flex items-center justify-center">
          <Link href="/dashboard" className="flex items-center justify-center">
            <Image
              src="/images/apexgrid-icon.png"
              alt="ApexGrid"
              width={28}
              height={28}
              className="h-7 w-7 opacity-90"
            />
          </Link>
        </div>

        {/* Navigation */}
        <nav className="flex-1 flex flex-col items-center py-4 gap-1">
          {navigation.map((item) => {
            const Icon = item.icon;
            const active = isActive(item.href);

            return (
              <Tooltip key={item.name}>
                <TooltipTrigger asChild>
                  <Link
                    href={item.href}
                    className={`w-10 h-10 rounded-xl flex items-center justify-center transition-all duration-200 ${
                      active
                        ? 'bg-[#DC2626] text-white shadow-lg shadow-red-600/30'
                        : 'text-gray-500 hover:text-white hover:bg-white/[0.06]'
                    }`}
                  >
                    <Icon className="h-[18px] w-[18px]" strokeWidth={active ? 2 : 1.5} />
                  </Link>
                </TooltipTrigger>
                <TooltipContent
                  side="right"
                  sideOffset={12}
                  className="bg-[#1c1c1c] border-white/10 text-white text-xs px-3 py-1.5"
                >
                  {item.name}
                </TooltipContent>
              </Tooltip>
            );
          })}
        </nav>

        {/* Bottom Section - User Avatar */}
        <div className="pb-4 flex flex-col items-center">
          <Tooltip>
            <TooltipTrigger asChild>
              <button className="w-8 h-8 rounded-full bg-gradient-to-br from-[#DC2626] to-[#991B1B] flex items-center justify-center text-white text-xs font-semibold hover:opacity-90 transition-opacity">
                U
              </button>
            </TooltipTrigger>
            <TooltipContent
              side="right"
              sideOffset={12}
              className="bg-[#1c1c1c] border-white/10 text-white text-xs px-3 py-1.5"
            >
              Profile
            </TooltipContent>
          </Tooltip>
        </div>
      </aside>
    </TooltipProvider>
  );
}
