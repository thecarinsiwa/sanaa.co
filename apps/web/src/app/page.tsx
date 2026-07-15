export default function HomePage() {
  return (
    <main>
      <h1>Sanaa</h1>
      <p>
        Boutique en ligne, personnalisation sur-mesure et atelier — la vitrine
        client de la plateforme.
      </p>
      <p>
        API : <code>{process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000/api'}</code>
      </p>
    </main>
  );
}
