'use client';

import { useState, useCallback } from 'react';
import Image, { ImageProps } from 'next/image';
import { cn } from '@/lib/utils';
import { User, Flag, MapPin, Car, Users } from 'lucide-react';

// ============================================
// PLACEHOLDER CONFIGURATIONS
// ============================================

export type PlaceholderType = 'driver' | 'team' | 'track' | 'avatar' | 'league' | 'generic';

const placeholderConfig: Record<PlaceholderType, {
  icon: React.ComponentType<{ className?: string }>;
  bgColor: string;
  iconColor: string;
  label: string;
}> = {
  driver: {
    icon: User,
    bgColor: 'bg-gradient-to-br from-gray-700 to-gray-900',
    iconColor: 'text-gray-400',
    label: 'Driver',
  },
  team: {
    icon: Car,
    bgColor: 'bg-gradient-to-br from-red-900 to-gray-900',
    iconColor: 'text-red-400',
    label: 'Team',
  },
  track: {
    icon: MapPin,
    bgColor: 'bg-gradient-to-br from-green-900 to-gray-900',
    iconColor: 'text-green-400',
    label: 'Track',
  },
  avatar: {
    icon: User,
    bgColor: 'bg-gradient-to-br from-blue-900 to-gray-900',
    iconColor: 'text-blue-400',
    label: 'User',
  },
  league: {
    icon: Users,
    bgColor: 'bg-gradient-to-br from-purple-900 to-gray-900',
    iconColor: 'text-purple-400',
    label: 'League',
  },
  generic: {
    icon: Flag,
    bgColor: 'bg-gradient-to-br from-gray-800 to-gray-900',
    iconColor: 'text-gray-400',
    label: 'Image',
  },
};

// ============================================
// PLACEHOLDER COMPONENT
// ============================================

interface PlaceholderProps {
  type: PlaceholderType;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  className?: string;
  label?: string;
}

const sizeConfig = {
  sm: { container: 'w-8 h-8', icon: 'w-4 h-4' },
  md: { container: 'w-12 h-12', icon: 'w-6 h-6' },
  lg: { container: 'w-16 h-16', icon: 'w-8 h-8' },
  xl: { container: 'w-24 h-24', icon: 'w-12 h-12' },
};

export function ImagePlaceholder({ 
  type, 
  size = 'md', 
  className,
  label 
}: PlaceholderProps) {
  const config = placeholderConfig[type];
  const sizes = sizeConfig[size];
  const Icon = config.icon;

  return (
    <div
      className={cn(
        sizes.container,
        config.bgColor,
        'rounded-lg flex items-center justify-center',
        'border border-gray-700/50',
        className
      )}
      role="img"
      aria-label={label || config.label}
    >
      <Icon className={cn(sizes.icon, config.iconColor)} />
    </div>
  );
}

// ============================================
// SAFE IMAGE COMPONENT
// ============================================

interface SafeImageProps extends Omit<ImageProps, 'onError'> {
  fallbackType?: PlaceholderType;
  fallbackClassName?: string;
  showFallbackOnEmpty?: boolean;
}

export function SafeImage({
  src,
  alt,
  fallbackType = 'generic',
  fallbackClassName,
  showFallbackOnEmpty = true,
  className,
  width,
  height,
  ...props
}: SafeImageProps) {
  const [hasError, setHasError] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  const handleError = useCallback(() => {
    setHasError(true);
    setIsLoading(false);
  }, []);

  const handleLoad = useCallback(() => {
    setIsLoading(false);
  }, []);

  // Show placeholder if no src or error occurred
  const showPlaceholder = hasError || (showFallbackOnEmpty && !src);

  if (showPlaceholder) {
    // Determine size from width/height
    const w = typeof width === 'number' ? width : parseInt(String(width) || '48');
    const size: 'sm' | 'md' | 'lg' | 'xl' = 
      w <= 32 ? 'sm' :
      w <= 48 ? 'md' :
      w <= 64 ? 'lg' : 'xl';

    return (
      <ImagePlaceholder 
        type={fallbackType} 
        size={size}
        className={cn(className, fallbackClassName)}
        label={alt}
      />
    );
  }

  return (
    <div className={cn('relative', className)}>
      {isLoading && (
        <div 
          className={cn(
            'absolute inset-0 animate-pulse bg-gray-800 rounded',
          )}
        />
      )}
      <Image
        src={src}
        alt={alt}
        width={width}
        height={height}
        onError={handleError}
        onLoad={handleLoad}
        className={cn(
          isLoading && 'opacity-0',
          'transition-opacity duration-200',
          className
        )}
        {...props}
      />
    </div>
  );
}

// ============================================
// AVATAR COMPONENT
// ============================================

interface AvatarProps {
  src?: string | null;
  name?: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  className?: string;
}

const avatarSizes = {
  sm: 'w-8 h-8 text-xs',
  md: 'w-10 h-10 text-sm',
  lg: 'w-12 h-12 text-base',
  xl: 'w-16 h-16 text-lg',
};

export function Avatar({ src, name, size = 'md', className }: AvatarProps) {
  const [hasError, setHasError] = useState(false);

  // Generate initials from name
  const initials = name
    ? name
        .split(' ')
        .map(n => n[0])
        .join('')
        .toUpperCase()
        .slice(0, 2)
    : '?';

  // Generate consistent color from name
  const colorIndex = name 
    ? name.charCodeAt(0) % 6 
    : 0;
  
  const bgColors = [
    'bg-red-600',
    'bg-blue-600',
    'bg-green-600',
    'bg-purple-600',
    'bg-orange-600',
    'bg-pink-600',
  ];

  if (!src || hasError) {
    return (
      <div
        className={cn(
          avatarSizes[size],
          bgColors[colorIndex],
          'rounded-full flex items-center justify-center font-semibold text-white',
          className
        )}
        aria-label={name || 'User avatar'}
      >
        {initials}
      </div>
    );
  }

  return (
    <div className={cn(avatarSizes[size], 'relative rounded-full overflow-hidden', className)}>
      <Image
        src={src}
        alt={name || 'Avatar'}
        fill
        className="object-cover"
        onError={() => setHasError(true)}
      />
    </div>
  );
}

// ============================================
// TEAM LOGO COMPONENT
// ============================================

interface TeamLogoProps {
  src?: string | null;
  teamName: string;
  primaryColor?: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  className?: string;
}

export function TeamLogo({ 
  src, 
  teamName, 
  primaryColor,
  size = 'md', 
  className 
}: TeamLogoProps) {
  const [hasError, setHasError] = useState(false);
  const sizes = sizeConfig[size];

  // Get short name (first 3 letters)
  const shortName = teamName.slice(0, 3).toUpperCase();

  if (!src || hasError) {
    return (
      <div
        className={cn(
          sizes.container,
          'rounded-lg flex items-center justify-center font-bold text-white',
          'border-2',
          className
        )}
        style={{
          backgroundColor: primaryColor || '#374151',
          borderColor: primaryColor ? `${primaryColor}80` : '#4B5563',
        }}
        aria-label={`${teamName} logo`}
      >
        <span className={cn(
          size === 'sm' && 'text-[8px]',
          size === 'md' && 'text-[10px]',
          size === 'lg' && 'text-xs',
          size === 'xl' && 'text-sm',
        )}>
          {shortName}
        </span>
      </div>
    );
  }

  return (
    <div className={cn(sizes.container, 'relative rounded-lg overflow-hidden', className)}>
      <Image
        src={src}
        alt={`${teamName} logo`}
        fill
        className="object-contain"
        onError={() => setHasError(true)}
      />
    </div>
  );
}

// ============================================
// TRACK IMAGE COMPONENT
// ============================================

interface TrackImageProps {
  src?: string | null;
  trackName: string;
  country?: string;
  aspectRatio?: '16:9' | '4:3' | '1:1';
  className?: string;
}

const aspectRatioClasses = {
  '16:9': 'aspect-video',
  '4:3': 'aspect-4/3',
  '1:1': 'aspect-square',
};

export function TrackImage({ 
  src, 
  trackName, 
  country,
  aspectRatio = '16:9',
  className 
}: TrackImageProps) {
  const [hasError, setHasError] = useState(false);

  if (!src || hasError) {
    return (
      <div
        className={cn(
          aspectRatioClasses[aspectRatio],
          'bg-gradient-to-br from-green-900/50 to-gray-900',
          'rounded-lg flex flex-col items-center justify-center',
          'border border-gray-700/50',
          className
        )}
        aria-label={trackName}
      >
        <MapPin className="w-8 h-8 text-green-500 mb-2" />
        <span className="text-sm font-medium text-gray-300">{trackName}</span>
        {country && (
          <span className="text-xs text-gray-500">{country}</span>
        )}
      </div>
    );
  }

  return (
    <div className={cn(aspectRatioClasses[aspectRatio], 'relative rounded-lg overflow-hidden', className)}>
      <Image
        src={src}
        alt={trackName}
        fill
        className="object-cover"
        onError={() => setHasError(true)}
      />
    </div>
  );
}

// ============================================
// DRIVER PORTRAIT COMPONENT
// ============================================

interface DriverPortraitProps {
  src?: string | null;
  driverName: string;
  teamColor?: string;
  number?: number;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  className?: string;
}

export function DriverPortrait({
  src,
  driverName,
  teamColor,
  number,
  size = 'md',
  className,
}: DriverPortraitProps) {
  const [hasError, setHasError] = useState(false);
  const sizes = sizeConfig[size];

  // Get initials
  const initials = driverName
    .split(' ')
    .map(n => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);

  if (!src || hasError) {
    return (
      <div
        className={cn(
          sizes.container,
          'rounded-full flex flex-col items-center justify-center',
          'border-2',
          className
        )}
        style={{
          backgroundColor: teamColor ? `${teamColor}20` : '#1F2937',
          borderColor: teamColor || '#4B5563',
        }}
        aria-label={driverName}
      >
        <span className="font-bold text-gray-300" style={{ color: teamColor }}>
          {number || initials}
        </span>
      </div>
    );
  }

  return (
    <div 
      className={cn(sizes.container, 'relative rounded-full overflow-hidden border-2', className)}
      style={{ borderColor: teamColor || '#4B5563' }}
    >
      <Image
        src={src}
        alt={driverName}
        fill
        className="object-cover"
        onError={() => setHasError(true)}
      />
    </div>
  );
}

// ============================================
// COUNTRY FLAG COMPONENT
// ============================================

interface CountryFlagProps {
  countryCode: string;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

// Map common country names to ISO codes
const countryCodeMap: Record<string, string> = {
  'united states': 'us',
  'usa': 'us',
  'united kingdom': 'gb',
  'uk': 'gb',
  'great britain': 'gb',
  'spain': 'es',
  'germany': 'de',
  'france': 'fr',
  'italy': 'it',
  'netherlands': 'nl',
  'belgium': 'be',
  'australia': 'au',
  'brazil': 'br',
  'canada': 'ca',
  'japan': 'jp',
  'mexico': 'mx',
  'monaco': 'mc',
  'austria': 'at',
  'switzerland': 'ch',
  'finland': 'fi',
  'denmark': 'dk',
  'thailand': 'th',
  'china': 'cn',
  'singapore': 'sg',
  'uae': 'ae',
  'qatar': 'qa',
  'saudi arabia': 'sa',
  'bahrain': 'bh',
  'hungary': 'hu',
  'portugal': 'pt',
  'poland': 'pl',
  'argentina': 'ar',
  'new zealand': 'nz',
};

export function CountryFlag({ countryCode, size = 'md', className }: CountryFlagProps) {
  const code = countryCodeMap[countryCode.toLowerCase()] || countryCode.toLowerCase();
  
  const sizeClasses = {
    sm: 'w-4 h-3',
    md: 'w-6 h-4',
    lg: 'w-8 h-6',
  };

  // Use flag CDN for actual flags
  const flagUrl = `https://flagcdn.com/${code}.svg`;

  return (
    <div className={cn(sizeClasses[size], 'relative rounded-sm overflow-hidden shadow-sm', className)}>
      <Image
        src={flagUrl}
        alt={`${countryCode} flag`}
        fill
        className="object-cover"
        unoptimized // External CDN
      />
    </div>
  );
}
