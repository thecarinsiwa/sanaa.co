'use client';

import { ChevronLeft, ChevronRight } from 'lucide-react';
import Image from 'next/image';
import Link from 'next/link';
import { useState } from 'react';

const slides = [
  {
    id: 'health',
    title: 'Your professional outfits, made simple.',
    text: 'Quality, innovation and care — pieces built for the job, also available made-to-measure.',
    cta: 'Health / Wellness',
    href: '/collections/health',
    image:
      'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=1400&q=80',
    imageAlt: 'Healthcare professionals in workwear',
  },
  {
    id: 'hospitality',
    title: 'Elegance that serves hospitality.',
    text: 'Hotel and catering uniforms designed for comfort across a full shift.',
    cta: 'Hotel / Catering',
    href: '/collections/hospitality',
    image:
      'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=1400&q=80',
    imageAlt: 'Hospitality team in uniform',
  },
  {
    id: 'industry',
    title: 'Clothing made for the workshop.',
    text: 'Durability, freedom of movement and finishes for industry and crafts.',
    cta: 'Industry / Crafts',
    href: '/collections/industry',
    image:
      'https://images.unsplash.com/photo-1504307651254-35680f356dfd?auto=format&fit=crop&w=1400&q=80',
    imageAlt: 'Workers in industrial clothing',
  },
];

export function Hero() {
  const [index, setIndex] = useState(0);
  const slide = slides[index];

  const prev = () => setIndex((i) => (i === 0 ? slides.length - 1 : i - 1));
  const next = () => setIndex((i) => (i === slides.length - 1 ? 0 : i + 1));

  return (
    <section
      className="relative flex min-h-[calc(100vh-7.5rem)] flex-col overflow-hidden bg-sage lg:min-h-[calc(100vh-8rem)]"
      aria-label="Featured"
    >
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_70%_60%_at_85%_40%,rgba(255,255,255,0.35),transparent_60%)]" />

      <div className="relative z-10 mx-auto grid w-full max-w-[90rem] flex-1 grid-cols-1 items-center gap-8 px-4 py-10 sm:px-6 md:gap-10 lg:grid-cols-2 lg:gap-6 lg:px-10 lg:py-0">
        <div className="max-w-xl lg:py-16 xl:max-w-2xl">
          <p className="anim-fade-up mb-4 font-display text-sm font-semibold tracking-[0.28em] text-ink/70 uppercase">
            Sanaa
          </p>
          <h1
            key={`title-${slide.id}`}
            className="anim-fade-up font-display text-[clamp(2.25rem,5.2vw,4.25rem)] leading-[1.05] font-bold tracking-[-0.03em] text-ink"
          >
            {slide.title}
          </h1>
          <p
            key={`text-${slide.id}`}
            className="anim-fade-up-delay mt-5 max-w-md text-[1.05rem] leading-relaxed text-mute"
          >
            {slide.text}
          </p>
          <div className="anim-fade-up-delay-2 mt-8 flex flex-wrap items-center gap-4">
            <Link
              href={slide.href}
              className="inline-flex items-center bg-ink px-7 py-3.5 text-xs font-semibold tracking-[0.14em] text-paper uppercase transition-[transform,background-color] duration-300 hover:bg-ink/90 active:scale-[0.98]"
            >
              {slide.cta}
            </Link>
          </div>

          <div className="mt-10 flex items-center gap-2">
            <button
              type="button"
              onClick={prev}
              aria-label="Previous slide"
              className="flex h-11 w-11 items-center justify-center bg-paper text-ink shadow-sm transition-transform duration-200 hover:-translate-x-0.5"
            >
              <ChevronLeft className="h-5 w-5" strokeWidth={1.75} />
            </button>
            <button
              type="button"
              onClick={next}
              aria-label="Next slide"
              className="flex h-11 w-11 items-center justify-center bg-paper text-ink shadow-sm transition-transform duration-200 hover:translate-x-0.5"
            >
              <ChevronRight className="h-5 w-5" strokeWidth={1.75} />
            </button>
            <div className="ml-3 flex gap-1.5" aria-hidden>
              {slides.map((s, i) => (
                <span
                  key={s.id}
                  className={`h-1.5 w-1.5 rounded-full transition-colors ${
                    i === index ? 'bg-ink' : 'bg-ink/25'
                  }`}
                />
              ))}
            </div>
          </div>
        </div>

        <div
          key={`image-${slide.id}`}
          className="anim-pan-in relative mx-auto aspect-[4/5] w-full max-w-lg self-end lg:max-w-none lg:self-stretch lg:py-8"
        >
          <div className="relative h-full min-h-[22rem] w-full lg:min-h-0">
            <Image
              src={slide.image}
              alt={slide.imageAlt}
              fill
              priority
              sizes="(max-width: 1024px) 90vw, 45vw"
              className="object-cover object-top [mask-image:linear-gradient(to_bottom,black_82%,transparent)]"
            />
          </div>
        </div>
      </div>
    </section>
  );
}
