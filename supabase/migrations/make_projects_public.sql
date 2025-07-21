/*
      # Rendre les projets publics

      Cette migration supprime les exigences d'authentification des utilisateurs pour la table `projects`, autorisant un accès public.

      1.  **Modifications de la table**
          -   `projects`: La colonne `user_id` est rendue facultative (nullable) pour permettre la création de projets anonymes.

      2.  **Sécurité (RLS)**
          -   Toutes les politiques RLS existantes sur la table `projects` sont supprimées.
          -   Une nouvelle politique est ajoutée pour permettre à tout utilisateur (y compris anonyme) de lire tous les projets.
          -   Une nouvelle politique est ajoutée pour permettre à tout utilisateur (y compris anonyme) de créer de nouveaux projets.
          -   Les opérations de mise à jour (Update) et de suppression (Delete) sont implicitement désactivées car aucune politique n'est créée pour elles.
    */

    -- 1. Rendre user_id nullable
    -- Utilisation de DO $$ pour gérer le cas où la colonne n'existe pas ou est déjà nullable, bien que ALTER COLUMN soit généralement suffisant.
    DO $$
    BEGIN
      IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'projects' AND column_name = 'user_id' AND is_nullable = 'NO'
      ) THEN
        ALTER TABLE public.projects ALTER COLUMN user_id DROP NOT NULL;
      END IF;
    END $$;


    -- 2. Supprimer les anciennes politiques RLS
    -- Remarque : Suppression de politiques qui pourraient ne pas exister ; utilisation de IF EXISTS pour éviter les erreurs.
    DROP POLICY IF EXISTS "Users can read own data" ON public.projects;
    DROP POLICY IF EXISTS "Users can insert their own projects" ON public.projects;
    DROP POLICY IF EXISTS "Users can update their own projects" ON public.projects;
    DROP POLICY IF EXISTS "Users can delete their own projects" ON public.projects;
    DROP POLICY IF EXISTS "Enable read access for authenticated users only" ON public.projects;
    DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.projects;
    DROP POLICY IF EXISTS "Allow public read access" ON public.projects;
    DROP POLICY IF EXISTS "Allow public insert access" ON public.projects;


    -- 3. Créer de nouvelles politiques RLS publiques
    CREATE POLICY "Allow public read access" ON public.projects
      FOR SELECT
      TO anon, authenticated
      USING (true);

    CREATE POLICY "Allow public insert access" ON public.projects
      FOR INSERT
      TO anon, authenticated
      WITH CHECK (true);