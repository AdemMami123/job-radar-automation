
# 🎯 Job Radar Automation

**A free, self-hosted job search automation built with n8n, PostgreSQL, Docker, and Mailpit.**

Job Radar automates the process of collecting job opportunities, normalizing job listings, scoring them against configurable career preferences, and preparing email notifications for relevant opportunities.

The goal is to reduce manual job searching and help developers focus on opportunities that match their skills, experience level, and preferred working locations.

## ✨ Features

- **Automated job collection** — Fetch job listings from supported public job sources.
- **Job normalization** — Standardize job data from different sources into a consistent structure.
- **Duplicate prevention** — Use unique job fingerprints to avoid storing duplicate listings.
- **Configurable scoring** — Score opportunities based on job titles, technical skills, seniority, location, and freshness.
- **PostgreSQL storage** — Store job listings, scores, configuration, and application tracking information.
- **Email notifications** — Generate HTML email summaries for high-scoring job matches.
- **Local email testing** — Use Mailpit to inspect generated emails without sending them to a real inbox.
- **Self-hosted workflow automation** — Run the automation locally with Docker and n8n.
- **Error-handling workflow** — Include a separate workflow for handling execution errors.

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| [n8n](https://n8n.io/) | Workflow automation |
| [PostgreSQL](https://www.postgresql.org/) | Job database and configuration storage |
| [Docker](https://www.docker.com/) | Local service deployment |
| [Mailpit](https://mailpit.axllent.org/) | Local email testing |
| JavaScript | Data transformation and job scoring |
| SQL | Database schema and queries |

## 🏗️ Project Structure

```text
job-radar-automation/
├── workflows/
│   ├── job-radar-main.json
│   └── 00-error-handler.json
├── database/
│   └── schema.sql
├── .env.example
├── .gitignore
└── README.md
```

The workflow filenames above represent the intended repository structure. Adjust them if your exported files use different names.

## ⚙️ How It Works

```text
Job Sources
    |
    v
Fetch Job Listings
    |
    v
Normalize Job Data
    |
    v
Generate Unique Fingerprints
    |
    v
Store Jobs in PostgreSQL
    |
    v
Load Scoring Configuration
    |
    v
Calculate Job Scores
    |
    v
Update Job Records
    |
    v
Build HTML Email Summary
    |
    v
Send Email Through Mailpit
```

The exact execution path depends on the workflow's configured connections and conditions.

### Job Scoring

The scoring system evaluates listings using configurable criteria, including:

- Target job titles
- Relevant technical skills
- Junior-friendly or graduate-level opportunities
- Seniority requirements
- Remote work and preferred locations
- Visa sponsorship information, when available
- Recent posting dates
- Blacklisted companies

The current workflow uses these score categories:

| Score | Status |
|---|---|
| 60–100 | `hot` |
| 35–59 | `queued` |
| 0–34 | `ignored` |

These thresholds are defined by the current scoring logic and can be changed to suit your preferences.

## 📋 Prerequisites

Before starting, install:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)
- A GitHub account
- A local n8n instance
- PostgreSQL and Mailpit containers, connected to a network accessible by n8n

The following instructions assume you are running the services locally on Windows. Adapt the commands if your environment differs.

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/job-radar-automation.git
cd job-radar-automation
```

Replace `YOUR_USERNAME` with your GitHub username.

### 2. Configure the environment

Copy the example environment file:

**PowerShell**

```powershell
Copy-Item .env.example .env
```

Update the local values as needed.

> Important: `.env.example` documents suggested settings. Your containers must explicitly reference the corresponding environment variables for them to take effect.

Never commit your real `.env` file or secrets to GitHub.

### 3. Prepare PostgreSQL

Create a PostgreSQL database named `jobradar` and configure a database user with appropriate permissions.

Run the SQL statements in:

```text
database/schema.sql
```

The schema defines the following tables:

| Table | Purpose |
|---|---|
| `jobs` | Stores job listings, fingerprints, scores, and statuses |
| `scoring_config` | Stores job-scoring preferences |
| `applications` | Tracks application stages, notes, and follow-up dates |

The database must be reachable from n8n over the Docker network.

### 4. Configure n8n

Open your local n8n instance, typically at:

http://localhost:5678

Import the workflow JSON files from the `workflows/` directory.

Configure the PostgreSQL credential using your actual local database settings. If your containers share the `job-radar-net` Docker network, the PostgreSQL hostname may be:

```text
Host: job-radar-postgres
Port: 5432
Database: jobradar
User: jobradar
Password: Your configured local password
SSL: Disabled for local development
```

Do not assume the example values match every installation.

### 5. Configure Mailpit

Mailpit provides a local SMTP server and web interface for testing emails.

Typical local configuration:

```text
SMTP Host: mailpit
SMTP Port: 1025
SSL/TLS: Disabled
```

Open the inbox in your browser:

http://localhost:8025

Ensure Mailpit and n8n can communicate over a shared Docker network.

### 6. Test the workflow

Before enabling scheduled execution:

1. Confirm PostgreSQL connectivity.
2. Confirm the scoring configuration exists.
3. Execute the workflow manually.
4. Inspect the normalized job data and generated fingerprints.
5. Verify that inserted jobs have valid fingerprints.
6. Verify that scores and statuses are written to PostgreSQL.
7. Inspect the HTML email output.
8. Check Mailpit for generated notifications.
9. Review error-handling behavior.
10. Enable scheduled execution only after the workflow works as expected.

## 🗄️ Database Schema

The schema file creates three primary tables.

### `jobs`

Stores collected opportunities, source information, descriptions, tags, scores, and notification status.

### `scoring_config`

Stores configurable preferences as JSONB values. Default entries include target titles, stack keywords, negative keywords, preferred locations, and blacklisted companies.

### `applications`

Provides a basic structure for recording applications, follow-up dates, notes, and application stages.

## 🔐 Security

Security is important when self-hosting automation workflows.

- Never commit `.env` files, passwords, API keys, or database backups.
- Review exported n8n workflows before publishing them.
- Avoid publishing personal information or sensitive execution data.
- Use strong passwords for exposed services.
- Keep PostgreSQL and n8n administration interfaces private unless properly secured.
- Do not expose local development services directly to the public internet without appropriate protection.
- Review Docker port mappings and firewall rules before deployment.

## 💰 Cost

The project is designed for local, self-hosted use with free software.

| Component | Intended cost |
|---|---|
| n8n self-hosted | Free software option |
| PostgreSQL | Free, open source |
| Docker Desktop | Free subject to Docker's applicable terms |
| Mailpit | Free, open source |
| Public job sources | Depends on source access and terms |
| External APIs | Not required by the intended AI-free workflow |

Local hosting still uses your computer's electricity, storage, and internet connection. Hosting or external services may introduce costs if you later choose to deploy them.

## ⚠️ Limitations

- Available jobs depend on the configured sources.
- Public job sources may change their APIs, formats, or access policies.
- Job descriptions and metadata may be incomplete.
- Scores are heuristic indicators, not guarantees of job suitability.
- Visa sponsorship data may be missing or inaccurate.
- Notifications depend on successful workflow execution and correct SMTP configuration.
- The project does not guarantee employment or automatically submit job applications.

Always verify job details on the original employer or job-board website.

## 🗺️ Roadmap

Potential improvements include:

- [ ] Add more job sources.
- [ ] Improve duplicate detection.
- [ ] Add configurable scoring weights.
- [ ] Add application tracking and follow-up reminders.
- [ ] Add a daily or weekly email digest.
- [ ] Add dashboard and reporting functionality.
- [ ] Add automated workflow tests.
- [ ] Improve Docker Compose setup for one-command installation.
- [ ] Add documentation for backup and recovery.

## 🤝 Contributing

Contributions, bug reports, and feature suggestions are welcome.

1. Fork the repository.
2. Create a feature branch.
3. Commit your changes.
4. Open a pull request describing the changes.

## 📄 License

No license has been selected yet.

Before publishing the project for reuse, consider adding an appropriate open-source license, such as the MIT License, if that matches your intentions.

## 👤 Author

**Adem Mami**

- GitHub: [@AdemMami123](https://github.com/AdemMami123)
- LinkedIn: [Adem Mami](https://linkedin.com/in/adem-mami-13ra)
- Portfolio: [ademmami.me](https://ademmami.me)

---

If you find this project useful, consider giving the repository a ⭐ on GitHub.