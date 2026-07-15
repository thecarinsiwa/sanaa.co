export default function HomePage() {
  return (
    <main>
      <h1>Sanaa Admin</h1>
      <p>
        Back-office : catalogue, atelier, stocks, CRM et finance. Réservé au
        personnel.
      </p>
      <p>
        API : <code>{process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000/api'}</code>
      </p>
    </main>
  );
}
