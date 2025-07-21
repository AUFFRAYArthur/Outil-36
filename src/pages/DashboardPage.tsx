import { useState, useEffect } from 'react';
    import { Link } from 'react-router-dom';
    import { supabase } from '../supabaseClient';

    type Project = {
      id: string;
      name: string;
      net_financing_requirement: number;
      cfads_forecast: number;
    };

    export default function DashboardPage() {
      const [projects, setProjects] = useState<Project[]>([]);
      const [loading, setLoading] = useState(true);
      const [newProjectName, setNewProjectName] = useState('');

      useEffect(() => {
        fetchProjects();
      }, []);

      const fetchProjects = async () => {
        setLoading(true);
        const { data, error } = await supabase
          .from('projects')
          .select('*')
          .order('created_at', { ascending: false });

        if (error) {
          console.error('Error fetching projects:', error);
          alert(`Erreur: ${error.message}`);
        } else {
          setProjects(data || []);
        }
        setLoading(false);
      };

      const createProject = async () => {
        if (!newProjectName.trim()) {
          alert('Le nom du projet ne peut pas être vide');
          return;
        }
        const { data, error } = await supabase
          .from('projects')
          .insert([{ name: newProjectName }])
          .select();

        if (error) {
          console.error('Error creating project:', error);
          alert(`Erreur: ${error.message}`);
        } else if (data) {
          setProjects([data[0], ...projects]);
          setNewProjectName('');
        }
      };

      if (loading) {
        return <div>Chargement des projets...</div>;
      }

      return (
        <div>
          <div className="card">
            <h3 style={{ marginTop: 0, fontWeight: 600 }}>Créer un nouveau projet</h3>
            <div style={{ display: 'flex', gap: '1rem' }}>
              <input
                type="text"
                placeholder="Ex: Acquisition de Innovate Corp"
                value={newProjectName}
                onChange={(e) => setNewProjectName(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' &amp;&amp; createProject()}
              />
              <button className="btn-primary" onClick={createProject}>Créer</button>
            </div>
          </div>

          <div style={{ marginTop: '2rem' }}>
            <h3 style={{ fontWeight: 600 }}>Tous les projets</h3>
            {projects.length === 0 ? (
              <div className="card" style={{ textAlign: 'center', padding: '2rem' }}>
                <p>Il n'y a pas encore de projets. Créez-en un pour commencer.</p>
              </div>
            ) : (
              <ul style={{ listStyle: 'none', padding: 0, margin: 0, display: 'grid', gap: '1rem' }}>
                {projects.map((project) => (
                  <li key={project.id}>
                    <Link to={`/projects/${project.id}`} className="card-link">
                      <div className="card" style={{ padding: '1rem 1.5rem' }}>
                        <p style={{ margin: 0, fontWeight: 500 }}>{project.name}</p>
                        <p style={{ margin: '0.25rem 0 0', color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
                          Gérer les scénarios de financement
                        </p>
                      </div>
                    </Link>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      );
    }
