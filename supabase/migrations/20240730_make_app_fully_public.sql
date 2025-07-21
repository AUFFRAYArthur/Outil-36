/*
      # Rendre l'application entièrement publique

      Cette migration met à jour le schéma de la base de données pour supprimer complètement la dépendance à l'authentification des utilisateurs, rendant l'application entièrement publique et fonctionnelle pour les utilisateurs anonymes.

      1.  **Modifications de la structure des tables**
          -   Suppression de la colonne `user_id` des tables `projects`, `scenarios`, et `financing_instruments`. Cette colonne était liée à `auth.users` et empêchait la création d'enregistrements par des utilisateurs anonymes en raison d'une contrainte `NOT NULL`.

      2.  **Modifications de la sécurité (RLS)**
          -   Suppression des anciennes politiques RLS qui dépendaient de `user_id`.
          -   Création de nouvelles politiques publiques (`"Public full access"`) sur les tables `projects`, `scenarios`, et `financing_instruments`. Ces politiques autorisent toutes les opérations (SELECT, INSERT, UPDATE, DELETE) pour n'importe quel utilisateur, authentifié ou non.
    */

    -- Étape 1: Supprimer les colonnes user_id
    DO $$
    BEGIN
      IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'projects' AND column_name = 'user_id') THEN
        ALTER TABLE public.projects DROP COLUMN user_id;
      END IF;
    END $$;

    DO $$
    BEGIN
      IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'scenarios' AND column_name = 'user_id') THEN
        ALTER TABLE public.scenarios DROP COLUMN user_id;
      END IF;
    END $$;

    DO $$
    BEGIN
      IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'financing_instruments' AND column_name = 'user_id') THEN
        ALTER TABLE public.financing_instruments DROP COLUMN user_id;
      END IF;
    END $$;


    -- Étape 2: Réinitialiser les politiques RLS pour un accès public complet
    DROP POLICY IF EXISTS "Users can manage their own projects" ON public.projects;
    DROP POLICY IF EXISTS "Users can manage scenarios for their own projects" ON public.scenarios;
    DROP POLICY IF EXISTS "Users can manage instruments for their own scenarios" ON public.financing_instruments;
    DROP POLICY IF EXISTS "Public full access" ON public.projects;
    DROP POLICY IF EXISTS "Public full access" ON public.scenarios;
    DROP POLICY IF EXISTS "Public full access" ON public.financing_instruments;

    ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.scenarios ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.financing_instruments ENABLE ROW LEVEL SECURITY;

    CREATE POLICY "Public full access" ON public.projects FOR ALL USING (true) WITH CHECK (true);
    CREATE POLICY "Public full access" ON public.scenarios FOR ALL USING (true) WITH CHECK (true);
    CREATE POLICY "Public full access" ON public.financing_instruments FOR ALL USING (true) WITH CHECK (true);