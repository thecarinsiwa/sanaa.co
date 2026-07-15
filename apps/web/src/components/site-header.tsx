import { Search, ShoppingBag, UserRound } from 'lucide-react';
import Link from 'next/link';

const navLinks = [
  { href: '/collections/sante', label: 'Santé — bien-être' },
  { href: '/collections/securite', label: 'Sécurité' },
  { href: '/collections/hotellerie', label: 'Hôtellerie — restauration' },
  { href: '/collections/industrie', label: 'Industrie — artisanat' },
];

export function SiteHeader() {
  return (
    <header className="anim-fade-in relative z-20 bg-paper">
      <div className="flex items-center justify-between gap-4 border-b border-line px-4 py-2 text-[11px] tracking-wide text-mute sm:px-6 lg:px-10">
        <p className="hidden truncate sm:block">
          Manufacture de vêtements professionnels — qualité &amp; sur-mesure
        </p>
        <div className="ml-auto flex flex-wrap items-center gap-x-5 gap-y-1">
          <a href="tel:+243000000000" className="transition-colors hover:text-ink">
            +243 00 000 0000
          </a>
          <Link href="/contact" className="transition-colors hover:text-ink">
            Contact
          </Link>
          <Link href="/a-propos" className="transition-colors hover:text-ink">
            À propos
          </Link>
        </div>
      </div>

      <div className="flex items-center justify-between gap-4 px-4 py-3 sm:px-6 lg:px-10">
        <Link
          href="/"
          className="flex h-12 min-w-14 shrink-0 items-center justify-center bg-ink px-3 font-display text-lg font-bold tracking-[0.12em] text-paper sm:h-14 sm:min-w-16 sm:text-xl"
          aria-label="Sanaa — accueil"
        >
          SANAA
        </Link>

        <nav
          className="hidden items-center gap-6 lg:flex xl:gap-8"
          aria-label="Navigation principale"
        >
          {navLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="font-body text-[13px] tracking-wide text-ink transition-opacity hover:opacity-55"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="flex items-center gap-4 sm:gap-5">
          <Link
            href="/recherche"
            className="group flex items-center gap-2 text-[13px] transition-opacity hover:opacity-55"
          >
            <Search className="h-4 w-4" strokeWidth={1.75} />
            <span className="hidden sm:inline">Rechercher</span>
          </Link>
          <Link
            href="/compte"
            className="group flex items-center gap-2 text-[13px] transition-opacity hover:opacity-55"
          >
            <UserRound className="h-4 w-4" strokeWidth={1.75} />
            <span className="hidden sm:inline">Compte</span>
          </Link>
          <Link
            href="/panier"
            className="group relative flex items-center gap-2 text-[13px] transition-opacity hover:opacity-55"
          >
            <ShoppingBag className="h-4 w-4" strokeWidth={1.75} />
            <span className="hidden sm:inline">Panier</span>
            <span className="absolute -right-2 -top-2 flex h-4 min-w-4 items-center justify-center bg-ink px-1 font-body text-[10px] text-paper sm:static sm:ml-0.5 sm:bg-transparent sm:p-0 sm:text-[13px] sm:text-ink">
              0
            </span>
          </Link>
        </div>
      </div>
    </header>
  );
}
