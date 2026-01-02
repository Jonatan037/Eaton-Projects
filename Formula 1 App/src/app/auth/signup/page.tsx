import { Metadata } from 'next';
import Link from 'next/link';
import { getTranslations } from 'next-intl/server';
import { RegisterForm } from './register-form';
import { Header } from '@/components/layout/header';

export const metadata: Metadata = {
  title: 'Sign Up',
  description: 'Create your ApexGrid AI account',
};

export default async function SignUpPage() {
  const t = await getTranslations('auth');
  const tNav = await getTranslations('nav');

  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      <main className="flex-1 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div className="w-full max-w-md space-y-8">
          <div className="text-center">
            <h1 className="text-3xl font-bold tracking-tight">
              {t('signUpTitle')}
            </h1>
            <p className="mt-2 text-sm text-muted-foreground">
              {t('alreadyHaveAccount')}{' '}
              <Link
                href="/auth/signin"
                className="font-medium text-primary hover:text-primary/80"
              >
                {tNav('signIn')}
              </Link>
            </p>
          </div>
          <RegisterForm />
        </div>
      </main>
    </div>
  );
}
