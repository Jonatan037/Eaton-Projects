import { format, formatInTimeZone, toZonedTime } from 'date-fns-tz';
import { formatDistanceToNow, isAfter, isBefore, addDays } from 'date-fns';
import { enUS, es } from 'date-fns/locale';

export type Locale = 'en' | 'es';

const localeMap = {
  en: enUS,
  es: es,
};

/**
 * Format a date in a specific timezone
 */
export function formatDateInTimezone(
  date: Date | string,
  timezone: string,
  formatString: string,
  locale: Locale = 'en'
): string {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  return formatInTimeZone(dateObj, timezone, formatString, {
    locale: localeMap[locale],
  });
}

/**
 * Format a race date/time for display
 */
export function formatRaceDateTime(
  date: Date | string,
  timezone: string,
  locale: Locale = 'en'
): string {
  const formatStr = locale === 'es' 
    ? "EEEE, d 'de' MMMM yyyy - HH:mm"
    : 'EEEE, MMMM d, yyyy - h:mm a';
  
  return formatDateInTimezone(date, timezone, formatStr, locale);
}

/**
 * Format a short date for tables
 */
export function formatShortDate(
  date: Date | string,
  timezone: string,
  locale: Locale = 'en'
): string {
  return formatDateInTimezone(date, timezone, 'MMM d, yyyy', locale);
}

/**
 * Format time only
 */
export function formatTime(
  date: Date | string,
  timezone: string,
  locale: Locale = 'en'
): string {
  const formatStr = locale === 'es' ? 'HH:mm' : 'h:mm a';
  return formatDateInTimezone(date, timezone, formatStr, locale);
}

/**
 * Get relative time (e.g., "in 2 days", "hace 3 horas")
 */
export function getRelativeTime(date: Date | string, locale: Locale = 'en'): string {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  return formatDistanceToNow(dateObj, {
    addSuffix: true,
    locale: localeMap[locale],
  });
}

/**
 * Check if a race is upcoming (within the next N days)
 */
export function isUpcoming(date: Date | string, daysAhead = 7): boolean {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  const now = new Date();
  const futureDate = addDays(now, daysAhead);
  
  return isAfter(dateObj, now) && isBefore(dateObj, futureDate);
}

/**
 * Check if a date is in the past
 */
export function isPast(date: Date | string): boolean {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  return isBefore(dateObj, new Date());
}

/**
 * Get timezone abbreviation (e.g., "CST", "EST")
 */
export function getTimezoneAbbreviation(
  date: Date | string,
  timezone: string
): string {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  return formatInTimeZone(dateObj, timezone, 'zzz');
}

/**
 * Convert a date to a specific timezone
 */
export function toTimezone(date: Date | string, timezone: string): Date {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  return toZonedTime(dateObj, timezone);
}

/**
 * Format date for input fields (ISO format without timezone)
 */
export function formatForInput(date: Date | string): string {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  return format(dateObj, "yyyy-MM-dd'T'HH:mm");
}

/**
 * Common timezone options for leagues
 */
export const TIMEZONE_OPTIONS = [
  { value: 'America/New_York', label: 'Eastern Time (ET)' },
  { value: 'America/Chicago', label: 'Central Time (CT)' },
  { value: 'America/Denver', label: 'Mountain Time (MT)' },
  { value: 'America/Los_Angeles', label: 'Pacific Time (PT)' },
  { value: 'America/Mexico_City', label: 'Mexico City' },
  { value: 'America/Sao_Paulo', label: 'São Paulo' },
  { value: 'Europe/London', label: 'London (GMT/BST)' },
  { value: 'Europe/Paris', label: 'Central European (CET/CEST)' },
  { value: 'Europe/Berlin', label: 'Berlin' },
  { value: 'Europe/Madrid', label: 'Madrid' },
  { value: 'Asia/Tokyo', label: 'Tokyo (JST)' },
  { value: 'Asia/Shanghai', label: 'China (CST)' },
  { value: 'Australia/Sydney', label: 'Sydney (AEST)' },
  { value: 'UTC', label: 'UTC' },
];
