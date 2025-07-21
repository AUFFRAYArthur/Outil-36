import { useState, useEffect } from 'react';
    import { useParams, Link } from 'react-router-dom';
    import { supabase } from '../supabaseClient';
    import { ArrowLeft } from 'lucide-react';

    type Project = {
      id: string;
      name: string;
      net_financing_requirement: number;
      cfads_forecast: number;
    };

    type Scenario = {
      id: string;
      project_id: string;
      name: string;
      notes: string | null;
    };

    export default function ProjectPage() {
      const { projectId } = useParams<{ projectId: string }>();
      const [project, setProject] = useState<Project | null>(null);
      const [scenarios, setScenarios] = useState<Scenario[]>([]);
      const [loading, setLoading] = useState(true);
      const [newScenarioName, setNewScenarioName] = useState('');

      useEffect(() => {
        const fetchProjectData = async () => {
          if (!projectId) return;
          setLoading(true);

          // Fetch project details
          const { data: projectData, error: projectError } = await supabase
            .from('projects')
            .select('*')
            .eq('id', projectId)
            .single();

          if (projectError) {
            console.error('Error fetching project:', projectError);
            setProject(null);
          } else {
            setProject(projectData);
          }

          // Fetch scenarios
          const { data: scenariosData, error: scenariosError } = await supabase
            .from('scenarios')
            .select('*')
            .eq('project_id', projectId)
            .order('created_at', { ascending: false });

          if (scenariosError) {
            console.error('Error fetching scenarios:', scenariosError);
          } else {
            setScenarios(scenariosData || []);
          }

          setLoading(false);
        };

        fetchProjectData();
      }, [projectId]);

      const createScenario = async () => {
        if (!newScenarioName.trim() || !projectId) {
          alert('Le nom du scénario ne peut pas être vide.');
          return;
        }

        const { data, error } = await supabase
          .from('scenarios')
          .insert([{ name: newScenarioName, project_id: projectId }])
          .select();

        if (error) {
          console.error('Error creating scenario:', error);
          alert(`Erreur: ${error.message}`);
        } else if (data) {
          setScenarios([data[0], ...scenarios]);
          setNewScenarioName('');
        }
      };

      if (loading) {
        return <div>Chargement du projet...</div>;
      }

      if (!project) {
        return (
          <div>
            <h2>Projet non trouvé</h2>
            <p>Le projet que vous cherchez n'existe pas ou n'a pas pu être chargé.</p>
            <Link to="/" className="btn-secondary">Retour à la liste des projets</Link>
          </div>
        );
      }

      return (
        <div>
          <Link to="/" className="btn-secondary" style={{ display: 'inline-flex', alignItems: 'center', gap: '0.5rem', marginBottom: '1.5rem' }}>
            <ArrowLeft size={16} />
            Retour aux projets
          </Link>

          <h2 style={{ fontSize: '2rem', fontWeight: 700, margin: '0 0 1rem 0' }}>{project.name}</h2>

          <div className="card">
            <h3 style={{ marginTop: 0, fontWeight: 600 }}>Créer un nouveau scénario</h3>
            <div style={{ display: 'flex', gap: '1rem' }}>
              <input
                type="text"
                placeholder="Ex: Scénario optimiste"
                value={newScenarioName}
                onChange={(e) => setNewScenarioName(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' &amp;&amp; createScenario()}
              />
              <button className="btn-primary" onClick={createScenario}>Créer Scénario</button>
            </div>
          </div>

          <div style={{ marginTop: '2rem' }}>
            <h3 style={{ fontWeight: 600 }}>Scénarios de financement</h3>
            {scenarios.length === 0 ? (
              <div className="card" style={{ textAlign: 'center', padding: '2rem' }}>
                <p>Aucun scénario pour ce projet. Créez-en un pour commencer.</p>
              </div>
            ) : (
              <ul style={{ listStyle: 'none', padding: 0, margin: 0, display: 'grid', gap: '1rem' }}>
                {scenarios.map((scenario) => (
                  <li key={scenario.id} className="card" style={{ padding: '1rem 1.5rem' }}>
                    <p style={{ margin: 0, fontWeight: 500 }}>{scenario.name}</p>
                    <p style={{ margin: '0.25rem 0 0', color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
                      Gérer les instruments de financement (à venir)
                    </p>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      );
    }
