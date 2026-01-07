'use client';

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

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { name: 'Leagues', href: '/dashboard', icon: Trophy },
  { name: 'Championships', href: '/dashboard', icon: Medal },
  { name: 'Tracks', href: '/dashboard', icon: Route },
  { name: 'Analytics', href: '/dashboard', icon: BarChart3 },
  { name: 'Admin', href: '/dashboard', icon: Shield },
  { name: 'Settings', href: '/dashboard', icon: Settings },
];

export function Sidebar() {
  const pathname = usePathname();

  const isActive = (href: string, name: string) => {
    if (name === 'Dashboard') {
      return pathname === '/dashboard';
    }
    return false;
  };

  return (
    <TooltipProvider delayDuration={0}>
      <aside className="w-[60px] bg-[#0a0a0a] flex flex-col fixed h-screen z-40 border-r border-white/5">
        {/* Logo */}
        <div className="h-[60px] flex items-center justify-center">
          <Link href="/dashboard">
            <Image
              src="/images/apexgrid-icon.png"
              alt="ApexGrid"
              width={26}
              height={26}
              className="opacity-90 hover:opacity-100 transition-opacity"
            />
          </Link>
        </div>

        {/* Navigation */}
        <nav className="flex-1 flex flex-col items-center pt-2 gap-2">
          {navigation.map((item) => {
            const Icon = item.icon;
            const active = isActive(item.href, item.name);

            return (
              <Tooltip key={item.name}>
                <TooltipTrigger asChild>
                  <Link
                    href={item.href}
                    className={`w-10 h-10 rounded-xl flex items-center justify-center transition-all duration-200 ${
                      active
                        ? 'bg-[#DC2626] text-white'
                        : 'text-gray-500 hover:text-gray-300 hover:bg-white/5'
                    }`}
                  >
                    <Icon className="h-[18px] w-[18px]" strokeWidth={1.5} />
                  </Link>
                </TooltipTrigger>
                <TooltipContent
                  side="right"
                  sideOffset={8}
                  className="bg-[#1a1a1a] border-white/10 text-white text-xs"
                >
                  {item.name}
                </TooltipContent>
              </Tooltip>
            );
          })}
        </nav>

        {/* Bottom - Settings */}
        <div className="pb-4 flex flex-col items-center gap-2">
          <Tooltip>
            <TooltipTrigger asChild>
              <Link
                href="/dashboard"
                className="w-10 h-10 rounded-xl flex items-center justify-center text-gray-500 hover:text-gray-300 hover:bg-white/5 transition-all"
              >
                <Settings className="h-[18px] w-[18px]" strokeWidth={1.5} />
              </Link>
            </TooltipTrigger>
            <TooltipContent
              side="right"
              sideOffset={8}
              className="bg-[#1a1a1a] border-white/10 text-white text-xs"
            >
              Settings
            </TooltipContent>
          </Tooltip>
        </div>
      </aside>
    </TooltipProvider>
  );
}
