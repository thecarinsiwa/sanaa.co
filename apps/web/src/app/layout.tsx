import type { Metadata } from 'next';
import { DM_Sans, Syne } from 'next/font/google';
import type { CSSProperties, ReactNode } from 'react';
import './globals.css';

const syne = Syne({
  subsets: ['latin'],
  variable: '--font-syne',
  display: 'swap',
});

const dmSans = DM_Sans({
  subsets: ['latin'],
  variable: '--font-dm-sans',
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'Sanaa — professional clothing',
  description:
    'Professional clothing manufacture: health, hospitality, industry and made-to-measure.',
};

export default function RootLayout({ children }: { children: ReactNode }) {
  const fontVars = {
    '--font-display': 'var(--font-syne), ui-sans-serif, system-ui, sans-serif',
    '--font-body': 'var(--font-dm-sans), ui-sans-serif, system-ui, sans-serif',
  } as CSSProperties;

  return (
    <html lang="en" className={`${syne.variable} ${dmSans.variable}`}>
      <body className="font-body antialiased" style={fontVars}>
        {children}
      </body>
    </html>
  );
}
