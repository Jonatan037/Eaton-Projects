import Link from 'next/link';
import { getTranslations } from 'next-intl/server';

export async function Footer() {
  const t = await getTranslations('footer');
  const currentYear = new Date().getFullYear();

  return (
    <footer className="border-t bg-muted/50">
      <div className="container mx-auto px-4 py-12 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 gap-8 md:grid-cols-4">
          {/* Brand */}
          <div className="col-span-1 md:col-span-2">
            <Link href="/" className="flex items-center space-x-2">
              <div className="flex h-8 w-8 items-center justify-center rounded bg-brand-red">
                <span className="text-lg font-bold text-white">A</span>
              </div>
              <span className="text-xl font-bold">
                <span className="text-brand-red">Apex</span>
                <span>Grid</span>
                <span className="text-accent-papaya"> AI</span>
              </span>
            </Link>
            <p className="mt-4 max-w-xs text-sm text-muted-foreground">
              AI-powered platform for managing Formula 1 game leagues. Track standings, manage teams, and leverage intelligent insights.
            </p>
          </div>

          {/* Links */}
          <div>
            <h3 className="mb-4 text-sm font-semibold">Platform</h3>
            <ul className="space-y-2 text-sm text-muted-foreground">
              <li>
                <Link href="/leagues" className="hover:text-foreground transition-colors">
                  Public Leagues
                </Link>
              </li>
              <li>
                <Link href="/leagues/create" className="hover:text-foreground transition-colors">
                  Create League
                </Link>
              </li>
              <li>
                <Link href="/docs" className="hover:text-foreground transition-colors">
                  Documentation
                </Link>
              </li>
            </ul>
          </div>

          {/* Legal */}
          <div>
            <h3 className="mb-4 text-sm font-semibold">Legal</h3>
            <ul className="space-y-2 text-sm text-muted-foreground">
              <li>
                <Link href="/privacy" className="hover:text-foreground transition-colors">
                  {t('privacy')}
                </Link>
              </li>
              <li>
                <Link href="/terms" className="hover:text-foreground transition-colors">
                  {t('terms')}
                </Link>
              </li>
              <li>
                <Link href="/contact" className="hover:text-foreground transition-colors">
                  {t('contact')}
                </Link>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom */}
        <div className="mt-12 flex flex-col items-center justify-between border-t pt-8 md:flex-row">
          <p className="text-sm text-muted-foreground">
            {t('copyright', { year: currentYear })}
          </p>
          <p className="mt-4 text-xs text-muted-foreground md:mt-0">
            Not affiliated with Formula 1 or F1. This is an independent fan project.
          </p>
        </div>
      </div>
    </footer>
  );
}
