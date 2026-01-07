'use client';

import { useState } from 'react';
import { Bell, Search } from 'lucide-react';
import { Sidebar } from './sidebar';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';

interface AppLayoutProps {
  children: React.ReactNode;
  user: {
    email: string;
    name?: string;
  };
}

export function AppLayout({ children, user }: AppLayoutProps) {
  const [sidebarCollapsed, setSidebarCollapsed] = useState(true);

  return (
    <div className="min-h-screen bg-[#0a0a0a] flex">
      {/* Sidebar */}
      <Sidebar
        defaultCollapsed={true}
        onCollapsedChange={setSidebarCollapsed}
      />

      {/* Main Content */}
      <div
        className={`flex-1 flex flex-col transition-all duration-300 ${
          sidebarCollapsed ? 'ml-[72px]' : 'ml-64'
        }`}
      >
        {/* Top Header */}
        <header className="h-14 bg-[#0d0d0d]/80 backdrop-blur-xl border-b border-white/[0.06] flex items-center justify-between px-6 sticky top-0 z-30">
          <div className="flex items-center gap-4 flex-1 max-w-md">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-500" />
              <Input
                placeholder="Search..."
                className="pl-10 h-9 bg-white/[0.04] border-white/[0.06] text-white text-sm placeholder:text-gray-500 focus:border-red-500/50 focus:ring-red-500/20 rounded-lg"
              />
            </div>
          </div>

          <div className="flex items-center gap-2">
            <Button
              variant="ghost"
              size="icon"
              className="h-9 w-9 text-gray-400 hover:text-white hover:bg-white/[0.04] relative"
            >
              <Bell className="h-4 w-4" />
              <span className="absolute top-2 right-2 h-2 w-2 bg-[#DC2626] rounded-full" />
            </Button>

            {/* User Info */}
            <div className="flex items-center gap-3 ml-2 pl-4 border-l border-white/[0.06]">
              <div className="text-right hidden sm:block">
                <p className="text-sm font-medium text-white">
                  {user.name || user.email?.split('@')[0]}
                </p>
                <p className="text-xs text-gray-500">{user.email}</p>
              </div>
              <div className="h-8 w-8 rounded-full bg-gradient-to-br from-[#DC2626] to-[#991B1B] flex items-center justify-center">
                <span className="text-xs font-bold text-white">
                  {user.email?.charAt(0).toUpperCase()}
                </span>
              </div>
            </div>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 p-6 bg-[#0a0a0a]">{children}</main>
      </div>
    </div>
  );
}
