import type { Metadata, Viewport } from 'next';
import { Inter, JetBrains_Mono } from 'next/font/google';
import { ThemeProvider } from 'next-themes';
import { NextIntlClientProvider } from 'next-intl';
import { getLocale, getMessages } from 'next-intl/server';
import '@/styles/globals.css';
import { Providers } from './providers';
import { LocaleProvider } from '@/providers/locale-provider';
import type { Locale } from '@/lib/i18n';

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-sans',
});

const jetbrainsMono = JetBrains_Mono({
  subsets: ['latin'],
  variable: '--font-mono',
});

export const metadata: Metadata = {
  title: {
    default: 'ApexGrid AI - F1 League Management',
    template: '%s | ApexGrid AI',
  },
  description:
    'AI-powered platform for managing Formula 1 game leagues. Create leagues, track standings, and leverage AI insights.',
  keywords: [
    'F1',
    'Formula 1',
    'racing',
    'league',
    'championship',
    'standings',
    'AI',
    'game',
  ],
  authors: [{ name: 'ApexGrid AI' }],
  creator: 'ApexGrid AI',
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://apexgridai.com',
    title: 'ApexGrid AI - F1 League Management',
    description:
      'AI-powered platform for managing Formula 1 game leagues',
    siteName: 'ApexGrid AI',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'ApexGrid AI - F1 League Management',
    description:
      'AI-powered platform for managing Formula 1 game leagues',
  },
  icons: {
    icon: '/favicon.ico',
    shortcut: '/favicon-16x16.png',
    apple: '/apple-touch-icon.png',
  },
  manifest: '/site.webmanifest',
};

export const viewport: Viewport = {
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#FFFFFF' },
    { media: '(prefers-color-scheme: dark)', color: '#0A0A0A' },
  ],
  width: 'device-width',
  initialScale: 1,
};

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const locale = await getLocale();
  const messages = await getMessages();

  return (
    <html lang={locale} suppressHydrationWarning>
      <body
        className={`${inter.variable} ${jetbrainsMono.variable} font-sans antialiased`}
      >
        <ThemeProvider
          attribute="class"
          defaultTheme="dark"
          enableSystem
          disableTransitionOnChange
        >
          <NextIntlClientProvider messages={messages}>
            <LocaleProvider defaultLocale={locale as Locale}>
              <Providers>{children}</Providers>
            </LocaleProvider>
          </NextIntlClientProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
