import { Factory, HandHelping, HardHat, UtensilsCrossed } from 'lucide-react';
import Link from 'next/link';

const categories = [
  {
    href: '/collections/health',
    label: 'Health & wellness',
    icon: HandHelping,
  },
  {
    href: '/collections/hospitality',
    label: 'Hotel & catering',
    icon: UtensilsCrossed,
  },
  {
    href: '/collections/industry',
    label: 'Industry & crafts',
    icon: Factory,
  },
  {
    href: '/collections/safety',
    label: 'Safety',
    icon: HardHat,
  },
];

export function CategoryStrip() {
  return (
    <section
      className="border-t border-line bg-paper"
      aria-label="Shop by sector"
    >
      <ul className="mx-auto grid max-w-[90rem] grid-cols-2 lg:grid-cols-4">
        {categories.map((category, index) => {
          const Icon = category.icon;
          return (
            <li
              key={category.href}
              className={[
                index % 2 === 1 ? 'border-l border-line' : '',
                index >= 2 ? 'border-t border-line lg:border-t-0' : '',
                index > 0 ? 'lg:border-l lg:border-line' : '',
              ]
                .filter(Boolean)
                .join(' ')}
            >
              <Link
                href={category.href}
                className="group flex flex-col items-center gap-3 px-4 py-8 text-center transition-colors duration-300 hover:bg-sage/25 sm:py-10"
              >
                <Icon
                  className="h-10 w-10 text-ink transition-transform duration-300 group-hover:-translate-y-1 sm:h-12 sm:w-12"
                  strokeWidth={1.25}
                />
                <span className="font-body text-xs tracking-wide text-mute transition-colors group-hover:text-ink sm:text-[13px]">
                  {category.label}
                </span>
              </Link>
            </li>
          );
        })}
      </ul>
    </section>
  );
}
