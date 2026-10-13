
-- Job Radar - PostgreSQL Database Schema
-- Database: jobradar
-- PostgreSQL 16+

BEGIN;

-- 1. Jobs collected from job boards
CREATE TABLE IF NOT EXISTS jobs (
    id SERIAL PRIMARY KEY,
    fingerprint TEXT UNIQUE NOT NULL,
    source TEXT NOT NULL,
    external_id TEXT,
    title TEXT NOT NULL,
    company TEXT NOT NULL,
    location TEXT,
    remote BOOLEAN DEFAULT FALSE,
    url TEXT,
    description TEXT,
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    visa_sponsorship BOOLEAN DEFAULT FALSE,
    posted_at TIMESTAMPTZ,
    first_seen_at TIMESTAMPTZ DEFAULT NOW(),
    score INTEGER DEFAULT 0,
    score_breakdown TEXT,
    status TEXT DEFAULT 'queued',
    notified_at TIMESTAMPTZ
);

-- 2. Scoring configuration
CREATE TABLE IF NOT EXISTS scoring_config (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL
);

-- 3. Job applications and follow-up tracking
CREATE TABLE IF NOT EXISTS applications (
    id SERIAL PRIMARY KEY,
    job_id INTEGER NOT NULL REFERENCES jobs(id),
    applied_at TIMESTAMPTZ DEFAULT NOW(),
    follow_up_at TIMESTAMPTZ,
    notes TEXT,
    stage TEXT DEFAULT 'applied'
);

-- Useful indexes for workflow queries
CREATE INDEX IF NOT EXISTS idx_jobs_status
    ON jobs(status);

CREATE INDEX IF NOT EXISTS idx_jobs_posted_at
    ON jobs(posted_at DESC);

CREATE INDEX IF NOT EXISTS idx_jobs_score
    ON jobs(score DESC);

CREATE INDEX IF NOT EXISTS idx_jobs_source
    ON jobs(source);

CREATE INDEX IF NOT EXISTS idx_applications_job_id
    ON applications(job_id);

CREATE INDEX IF NOT EXISTS idx_applications_follow_up_at
    ON applications(follow_up_at);

-- 4. Default scoring configuration
-- ON CONFLICT prevents duplicate keys when rerunning this section.
INSERT INTO scoring_config (key, value)
VALUES
    (
        'target_titles',
        '["software engineer", "software developer", "full stack developer", "frontend developer", "backend developer", "web developer", "react developer", "typescript developer"]'::JSONB
    ),
    (
        'stack_keywords',
        '["javascript", "typescript", "react", "next.js", "angular", "node.js", "node", "java", "spring boot", "postgresql", "sql", "rest api", "docker"]'::JSONB
    ),
    (
        'negative_keywords',
        '["senior", "staff engineer", "principal engineer", "engineering manager", "director", "lead developer"]'::JSONB
    ),
    (
        'preferred_locations',
        '["tunisia", "remote", "europe", "worldwide", "africa"]'::JSONB
    ),
    (
        'blacklist_companies',
        '[]'::JSONB
    )
ON CONFLICT (key) DO NOTHING;

COMMIT;