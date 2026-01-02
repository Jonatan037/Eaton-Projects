import { describe, it, expect } from 'vitest';
import {
  formatRaceDateTime,
  formatShortDate,
  formatTime,
  getRelativeTime,
  isUpcoming,
  formatDateInTimezone,
} from '@/lib/date-utils';

describe('Date Utils', () => {
  describe('formatDateInTimezone', () => {
    it('should format date in specified timezone', () => {
      const date = new Date('2025-03-15T14:00:00Z');
      const formatted = formatDateInTimezone(date, 'America/Chicago', 'yyyy-MM-dd HH:mm');
      
      // Chicago is UTC-6 (or -5 during DST)
      expect(formatted).toMatch(/2025-03-15 0[89]:00/);
    });

    it('should accept string dates', () => {
      const formatted = formatDateInTimezone('2025-06-01T12:00:00Z', 'UTC', 'yyyy-MM-dd');
      expect(formatted).toBe('2025-06-01');
    });
  });

  describe('formatRaceDateTime', () => {
    it('should format race date in English', () => {
      const date = new Date('2025-03-15T14:00:00Z');
      const formatted = formatRaceDateTime(date, 'UTC', 'en');
      
      expect(formatted).toContain('Saturday');
      expect(formatted).toContain('March');
      expect(formatted).toContain('15');
      expect(formatted).toContain('2025');
    });

    it('should format race date in Spanish', () => {
      const date = new Date('2025-03-15T14:00:00Z');
      const formatted = formatRaceDateTime(date, 'UTC', 'es');
      
      expect(formatted).toContain('sábado');
      expect(formatted).toContain('marzo');
    });
  });

  describe('formatShortDate', () => {
    it('should format short date', () => {
      const date = new Date('2025-06-15T00:00:00Z');
      const formatted = formatShortDate(date, 'UTC');
      
      expect(formatted).toBe('Jun 15, 2025');
    });
  });

  describe('formatTime', () => {
    it('should format time in English (12-hour)', () => {
      const date = new Date('2025-03-15T14:30:00Z');
      const formatted = formatTime(date, 'UTC', 'en');
      
      expect(formatted).toBe('2:30 PM');
    });

    it('should format time in Spanish (24-hour)', () => {
      const date = new Date('2025-03-15T14:30:00Z');
      const formatted = formatTime(date, 'UTC', 'es');
      
      expect(formatted).toBe('14:30');
    });
  });

  describe('getRelativeTime', () => {
    it('should return relative time string', () => {
      const futureDate = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000); // 2 days from now
      const relative = getRelativeTime(futureDate, 'en');
      
      expect(relative).toContain('in');
      expect(relative).toContain('day');
    });

    it('should support Spanish locale', () => {
      const pastDate = new Date(Date.now() - 3 * 60 * 60 * 1000); // 3 hours ago
      const relative = getRelativeTime(pastDate, 'es');
      
      expect(relative).toContain('hace');
    });
  });

  describe('isUpcoming', () => {
    it('should return true for date in the future within range', () => {
      const futureDate = new Date(Date.now() + 3 * 24 * 60 * 60 * 1000); // 3 days from now
      expect(isUpcoming(futureDate, 7)).toBe(true);
    });

    it('should return false for past date', () => {
      const pastDate = new Date(Date.now() - 24 * 60 * 60 * 1000); // 1 day ago
      expect(isUpcoming(pastDate, 7)).toBe(false);
    });

    it('should return false for date beyond range', () => {
      const farFuture = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days from now
      expect(isUpcoming(farFuture, 7)).toBe(false);
    });

    it('should accept string dates', () => {
      const futureDate = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000);
      expect(isUpcoming(futureDate.toISOString(), 7)).toBe(true);
    });
  });
});
