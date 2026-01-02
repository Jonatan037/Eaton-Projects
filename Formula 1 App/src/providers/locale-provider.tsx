'use client';

import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { 
  Locale, 
  DEFAULT_LOCALE, 
  LOCALE_STORAGE_KEY,
  getTranslations,
  t as translate,
  persistLocale,
  detectLocale,
  getLocaleDisplayName,
  getLocaleFlag,
  type Translations,
} from '@/lib/i18n';

// ============================================
// CONTEXT TYPE
// ============================================

interface LocaleContextType {
  locale: Locale;
  setLocale: (locale: Locale) => void;
  t: Translations;
  translate: (path: string, params?: Record<string, string | number>) => string;
  localeDisplayName: string;
  localeFlag: string;
}

const LocaleContext = createContext<LocaleContextType | undefined>(undefined);

// ============================================
// PROVIDER COMPONENT
// ============================================

interface LocaleProviderProps {
  children: React.ReactNode;
  defaultLocale?: Locale;
  /** User's saved locale preference from database */
  userLocale?: Locale;
}

export function LocaleProvider({ 
  children, 
  defaultLocale,
  userLocale,
}: LocaleProviderProps) {
  // Initialize with user preference, then detect, then default
  const [locale, setLocaleState] = useState<Locale>(() => {
    // Server-side: use user preference or default
    if (typeof window === 'undefined') {
      return userLocale || defaultLocale || DEFAULT_LOCALE;
    }
    // Client-side: check storage, then user pref, then detect
    const stored = localStorage.getItem(LOCALE_STORAGE_KEY);
    if (stored === 'en' || stored === 'es') {
      return stored;
    }
    return userLocale || detectLocale();
  });

  const [translations, setTranslations] = useState<Translations>(() => 
    getTranslations(locale)
  );

  // Update translations when locale changes
  useEffect(() => {
    setTranslations(getTranslations(locale));
  }, [locale]);

  // Hydration sync
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const stored = localStorage.getItem(LOCALE_STORAGE_KEY);
      if (stored === 'en' || stored === 'es') {
        if (stored !== locale) {
          setLocaleState(stored);
        }
      }
    }
  }, [locale]);

  const setLocale = useCallback((newLocale: Locale) => {
    setLocaleState(newLocale);
    persistLocale(newLocale);
    
    // Optionally sync to server
    // This would call an API to update user's locale preference
    // fetch('/api/user/locale', { method: 'POST', body: JSON.stringify({ locale: newLocale }) });
  }, []);

  const translateFn = useCallback((path: string, params?: Record<string, string | number>) => {
    return translate(locale, path, params);
  }, [locale]);

  const value: LocaleContextType = {
    locale,
    setLocale,
    t: translations,
    translate: translateFn,
    localeDisplayName: getLocaleDisplayName(locale),
    localeFlag: getLocaleFlag(locale),
  };

  return (
    <LocaleContext.Provider value={value}>
      {children}
    </LocaleContext.Provider>
  );
}

// ============================================
// HOOK
// ============================================

export function useLocale(): LocaleContextType {
  const context = useContext(LocaleContext);
  
  if (!context) {
    throw new Error('useLocale must be used within a LocaleProvider');
  }
  
  return context;
}

// ============================================
// LANGUAGE SWITCHER COMPONENT
// ============================================

import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Globe, Check } from 'lucide-react';
import { cn } from '@/lib/utils';

interface LanguageSwitcherProps {
  variant?: 'default' | 'compact' | 'minimal';
  className?: string;
}

export function LanguageSwitcher({ variant = 'default', className }: LanguageSwitcherProps) {
  const { locale, setLocale, localeFlag } = useLocale();

  const languages: { code: Locale; name: string; flag: string }[] = [
    { code: 'en', name: 'English', flag: '🇺🇸' },
    { code: 'es', name: 'Español', flag: '🇪🇸' },
  ];

  if (variant === 'minimal') {
    return (
      <Button
        variant="ghost"
        size="icon"
        className={cn('h-8 w-8', className)}
        onClick={() => setLocale(locale === 'en' ? 'es' : 'en')}
        aria-label="Toggle language"
      >
        <span className="text-lg">{localeFlag}</span>
      </Button>
    );
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button 
          variant="ghost" 
          size={variant === 'compact' ? 'sm' : 'default'}
          className={cn('gap-2', className)}
        >
          {variant === 'compact' ? (
            <span className="text-lg">{localeFlag}</span>
          ) : (
            <>
              <Globe className="h-4 w-4" />
              <span>{localeFlag}</span>
              <span className="hidden sm:inline">
                {languages.find(l => l.code === locale)?.name}
              </span>
            </>
          )}
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        {languages.map((lang) => (
          <DropdownMenuItem
            key={lang.code}
            onClick={() => setLocale(lang.code)}
            className={cn(
              'gap-2 cursor-pointer',
              locale === lang.code && 'bg-accent'
            )}
          >
            <span className="text-lg">{lang.flag}</span>
            <span>{lang.name}</span>
            {locale === lang.code && (
              <Check className="h-4 w-4 ml-auto" />
            )}
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}

// ============================================
// TRANSLATION COMPONENT (for JSX interpolation)
// ============================================

interface TransProps {
  id: string;
  params?: Record<string, string | number | React.ReactNode>;
  children?: (translation: string) => React.ReactNode;
}

export function Trans({ id, params, children }: TransProps) {
  const { translate } = useLocale();
  
  // Simple case: just render the translation
  if (!params && !children) {
    return <>{translate(id)}</>;
  }

  // With string params
  if (params && !children) {
    const stringParams: Record<string, string | number> = {};
    for (const [key, value] of Object.entries(params)) {
      if (typeof value === 'string' || typeof value === 'number') {
        stringParams[key] = value;
      }
    }
    return <>{translate(id, stringParams)}</>;
  }

  // Render prop pattern for complex interpolation
  if (children) {
    return <>{children(translate(id))}</>;
  }

  return null;
}
