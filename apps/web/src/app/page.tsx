import { CategoryStrip } from '@/components/category-strip';
import { Hero } from '@/components/hero';
import { SiteHeader } from '@/components/site-header';

export default function HomePage() {
  return (
    <>
      <SiteHeader />
      <main>
        <Hero />
        <CategoryStrip />
      </main>
    </>
  );
}
