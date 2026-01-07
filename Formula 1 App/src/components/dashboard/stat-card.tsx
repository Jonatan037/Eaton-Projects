'use client';

import { LucideIcon, TrendingUp, TrendingDown, Minus } from 'lucide-react';

interface StatCardProps {
  label: string;
  value: string | number;
  change?: string;
  trend?: 'up' | 'down' | 'neutral';
  icon: LucideIcon;
  color?: string;
  sparklineData?: number[];
}

export function StatCard({
  label,
  value,
  change,
  trend = 'neutral',
  icon: Icon,
  color = '#DC2626',
  sparklineData,
}: StatCardProps) {
  const getTrendIcon = () => {
    if (trend === 'up') return <TrendingUp className="h-3 w-3 text-green-500" />;
    if (trend === 'down') return <TrendingDown className="h-3 w-3 text-red-500" />;
    return <Minus className="h-3 w-3 text-gray-500" />;
  };

  const getTrendColor = () => {
    if (trend === 'up') return 'text-green-500';
    if (trend === 'down') return 'text-red-500';
    return 'text-gray-500';
  };

  // Simple sparkline calculation
  const renderSparkline = () => {
    if (!sparklineData || sparklineData.length < 2) return null;

    const max = Math.max(...sparklineData);
    const min = Math.min(...sparklineData);
    const range = max - min || 1;
    const height = 30;
    const width = 80;
    const stepX = width / (sparklineData.length - 1);

    const points = sparklineData.map((val, i) => {
      const x = i * stepX;
      const y = height - ((val - min) / range) * height;
      return `${x},${y}`;
    });

    const pathD = `M ${points.join(' L ')}`;

    return (
      <svg width={width} height={height} className="opacity-40">
        <defs>
          <linearGradient id={`gradient-${label}`} x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor={color} stopOpacity="0.2" />
            <stop offset="100%" stopColor={color} stopOpacity="0.8" />
          </linearGradient>
        </defs>
        <path
          d={pathD}
          fill="none"
          stroke={`url(#gradient-${label})`}
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    );
  };

  return (
    <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-white/[0.06] to-white/[0.02] border border-white/[0.06] p-5 group hover:border-white/10 transition-all">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <p className="text-sm text-gray-400 mb-1">{label}</p>
          <p className="text-3xl font-bold text-white">{value}</p>
          {change && (
            <div className="flex items-center gap-1.5 mt-2">
              {getTrendIcon()}
              <span className={`text-xs font-medium ${getTrendColor()}`}>{change}</span>
            </div>
          )}
        </div>

        <div className="flex flex-col items-end gap-2">
          <div
            className="h-11 w-11 rounded-xl flex items-center justify-center"
            style={{ backgroundColor: `${color}15` }}
          >
            <Icon className="h-5 w-5" style={{ color }} />
          </div>
          {sparklineData && <div className="mt-1">{renderSparkline()}</div>}
        </div>
      </div>

      {/* Hover accent line */}
      <div
        className="absolute bottom-0 left-0 right-0 h-0.5 opacity-0 group-hover:opacity-100 transition-opacity"
        style={{ background: `linear-gradient(to right, ${color}, transparent)` }}
      />
    </div>
  );
}
