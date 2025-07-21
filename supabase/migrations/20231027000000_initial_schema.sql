/*
      # Initial Schema for Financing Modeling Tool

      This migration sets up the core tables for managing financing plans for cooperative acquisitions.

      1.  **New Tables**
          *   `projects`: Stores the top-level information for each acquisition project, including the net financing requirement.
          *   `scenarios`: Represents a specific financing structure or simulation for a project.
          *   `financing_instruments`: Contains the details of each loan, subsidy, or equity instrument within a given scenario.

      2.  **Relationships**
          *   A `project` can have multiple `scenarios`.
          *   A `scenario` can have multiple `financing_instruments`.
          *   Foreign key constraints are established to maintain data integrity.

      3.  **Security**
          *   Row Level Security (RLS) is enabled on all tables.
          *   Policies are created to ensure users can only access and manage their own data, based on their authenticated `user_id`.
    */

    -- 1. Projects Table
    CREATE TABLE IF NOT EXISTS projects (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
        name TEXT NOT NULL,
        net_financing_requirement NUMERIC(15, 2) NOT NULL DEFAULT 0,
        cfads_forecast NUMERIC(15, 2) NOT NULL DEFAULT 0, -- Cash Flow Available for Debt Service
        created_at TIMESTAMPTZ DEFAULT now()
    );

    ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

    CREATE POLICY "Users can manage their own projects"
    ON projects
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id);

    -- 2. Scenarios Table
    CREATE TABLE IF NOT EXISTS scenarios (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        project_id UUID REFERENCES projects(id) ON DELETE CASCADE NOT NULL,
        user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
        name TEXT NOT NULL,
        notes TEXT,
        created_at TIMESTAMPTZ DEFAULT now()
    );

    ALTER TABLE scenarios ENABLE ROW LEVEL SECURITY;

    CREATE POLICY "Users can manage scenarios for their own projects"
    ON scenarios
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id);

    -- 3. Financing Instruments Table
    CREATE TABLE IF NOT EXISTS financing_instruments (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        scenario_id UUID REFERENCES scenarios(id) ON DELETE CASCADE NOT NULL,
        user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
        source_name TEXT NOT NULL,
        source_type TEXT NOT NULL, -- e.g., 'Commercial Bank Loan', 'Bpifrance', 'Subsidy'
        amount NUMERIC(15, 2) NOT NULL DEFAULT 0,
        interest_rate NUMERIC(5, 4) NOT NULL DEFAULT 0,
        tenor_years INT NOT NULL DEFAULT 0,
        grace_period_months INT NOT NULL DEFAULT 0,
        repayment_structure TEXT NOT NULL DEFAULT 'annuity', -- e.g., 'annuity', 'interest-only'
        guarantee_percentage NUMERIC(5, 4) NOT NULL DEFAULT 0,
        created_at TIMESTAMPTZ DEFAULT now()
    );

    ALTER TABLE financing_instruments ENABLE ROW LEVEL SECURITY;

    CREATE POLICY "Users can manage instruments for their own scenarios"
    ON financing_instruments
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id);