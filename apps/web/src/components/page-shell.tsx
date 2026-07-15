import Link from 'next/link';
import type { ReactNode } from 'react';
import { SiteHeader } from '@/components/site-header';

type PageShellProps = {
  title: string;
  description?: string;
  children?: ReactNode;
};

export function PageShell({ title, description, children }: PageShellProps) {
  return (
    <>
      <SiteHeader />
      <main className="mx-auto max-w-3xl px-4 py-16 sm:px-6 lg:px-10">
        <p className="mb-3 font-display text-xs font-semibold tracking-[0.24em] text-mute uppercase">
          Sanaa
        </p>
        <h1 className="font-display text-4xl font-bold tracking-[-0.03em] text-ink sm:text-5xl">
          {title}
        </h1>
        {description ? (
          <p className="mt-4 text-base leading-relaxed text-mute">{description}</p>
        ) : null}
        {children ? <div className="mt-10">{children}</div> : null}
        <p className="mt-12">
          <Link href="/" className="text-sm font-semibold tracking-wide underline-offset-4 hover:underline">
            ← Back to home
          </Link>
        </p>
      </main>
    </>
  );
}
