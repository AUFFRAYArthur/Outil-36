import { Outlet, Link } from 'react-router-dom';

    function App() {
      return (
        <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
          <header style={{ background: 'white', padding: '1rem 2rem', borderBottom: '1px solid var(--border-color)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <Link to="/" style={{ textDecoration: 'none', color: 'inherit' }}>
              <h1 style={{ fontSize: '1.25rem', fontWeight: 600, margin: 0 }}>Outil 36 : Plan de financement externe</h1>
            </Link>
          </header>
          <main style={{ flex: 1, padding: '2rem' }}>
            <Outlet />
          </main>
        </div>
      );
    }

    export default App;
