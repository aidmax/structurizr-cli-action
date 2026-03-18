# CLAUDE.md — AI Assistant Guide for structurizr-cli-action

## Project Overview

This is a GitHub Action that wraps the [Structurizr CLI](https://github.com/structurizr/cli) to enable automated pushing of C4 architecture models to a Structurizr workspace from CI/CD pipelines. The action delegates all execution to an external Docker image (`ghcr.io/aidmax/structurizr-cli-docker:latest`), keeping this repository minimal.

**Author:** Maksim Milykh
**License:** MIT
**Type:** Docker-based GitHub Action

---

## Repository Structure

```
structurizr-cli-action/
├── .github/
│   └── workflows/
│       ├── test.yml        # Runs on every push; tests the action end-to-end
│       └── release.yml     # Triggered on version tags (v*); creates GitHub Release with changelog
├── tests/
│   ├── workspace.dsl       # Sample Structurizr DSL used in CI tests
│   └── doc/
│       ├── adr/
│       │   ├── 0001-record-architecture-decisions.md
│       │   └── 0002-implement-as-unix-shell-scripts.md
│       └── docs/
│           └── example.md
├── action.yml              # GitHub Action definition (the core file)
├── package.json            # Empty; present for tooling compatibility
├── LICENSE                 # MIT
└── README.md               # User-facing documentation
```

---

## Core File: action.yml

This is the single most important file. It defines the GitHub Action interface.

### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `id` | Yes | — | Structurizr workspace ID |
| `key` | Yes | — | Workspace API key |
| `secret` | Yes | — | Workspace API secret |
| `workspace` | Yes | — | Path to workspace JSON or DSL file(s) |
| `docs` | No | — | Path to Markdown/AsciiDoc docs directory |
| `adrs` | No | — | Path to Architecture Decision Records directory |
| `url` | No | `https://api.structurizr.com` | Structurizr API URL (override for self-hosted) |
| `passphrase` | No | — | Passphrase for client-side encryption |
| `merge` | No | `true` | Merge layout info from the remote workspace |
| `archive` | No | `true` | Archive previous workspace version before pushing |

### How It Works

The action runs the Structurizr CLI `push` command inside the Docker container `ghcr.io/aidmax/structurizr-cli-docker:latest`, passing all inputs as CLI arguments. There is no local scripting — all logic lives in the Docker image.

---

## Development Conventions

### Branching

- Primary development branch: `master`
- Releases are tagged as `v*` (e.g., `v1`, `v2`)
- The `main` remote branch exists alongside `master`

### Versioning

- The project uses **major version tags** (e.g., `v1`). Users reference the action as `aidmax/structurizr-cli-action@v1`.
- When creating a release, update the major version tag to point to the new commit as well as creating a specific tag.

### Releases

Releases are automated via `.github/workflows/release.yml`:
1. Push a tag matching `v*`
2. Changelog is auto-generated from commit messages using `scottbrenner/generate-changelog-action`
3. A GitHub Release is created with the generated changelog

Use **Conventional Commits** style for commit messages to get clean changelogs:
- `feat(scope): description` — new feature
- `fix(scope): description` — bug fix
- `docs(scope): description` — documentation change
- `chore(scope): description` — maintenance

### Testing

Tests run automatically on every push via `.github/workflows/test.yml`. The test:
- Checks out the repo
- Runs the action itself (`uses: ./`) against a real Structurizr workspace
- Uses repository secrets: `STZR_ID`, `STZR_API_KEY`, `STZR_API_SECRET`
- Uses `tests/workspace.dsl` as the workspace file
- Runs with `merge: false` and `archive: false` to avoid side effects

**To test locally:** You cannot run the action locally without a real Structurizr account and credentials. Validate changes by inspecting `action.yml` structure and DSL syntax.

---

## Making Changes

### Adding or Modifying Inputs

1. Edit `action.yml`:
   - Add the input under `inputs:` with `description`, `required`, and optionally `default`
   - Pass it as an argument under `runs.args`
2. Update `README.md` to document the new input
3. If appropriate, add the parameter to the test workflow in `.github/workflows/test.yml`

### Updating the Docker Image

The Docker image is maintained in a separate repository (`aidmax/structurizr-cli-docker`). To use a specific version, change the image reference in `action.yml`:

```yaml
runs:
  using: 'docker'
  image: 'docker://ghcr.io/aidmax/structurizr-cli-docker:latest'
```

Replace `latest` with a specific tag (e.g., `v2023.05`) if pinning is needed.

### Structurizr DSL

The test file `tests/workspace.dsl` demonstrates the DSL syntax:
- `!adrs <path>` — include ADR documents
- `!docs <path>` — include Markdown documentation
- Model definitions use `person`, `softwareSystem`, and relationship arrows (`->`)
- Views: `systemContext`, `styles`

---

## Key Architectural Decisions

Documented in `tests/doc/adr/`:

- **ADR 0001:** Use Architecture Decision Records (Michael Nygard format) — *Accepted*
- **ADR 0002:** Implement as Unix shell scripts — *Accepted* (historical; actual implementation is now via Docker image)

**Historical note:** The project originally used a local `Dockerfile` but migrated to an external Docker image (`ghcr.io/aidmax/structurizr-cli-docker`) in December 2020 (commit `250ed28`). This decouples the CLI version from the action repository.

---

## Common Tasks

### Add a new CLI option
1. Check the [Structurizr CLI docs](https://github.com/structurizr/cli) for available flags
2. Add input to `action.yml` under `inputs:`
3. Wire it into `runs.args` using `${{ inputs.<name> }}`
4. Document in `README.md`
5. Test in `.github/workflows/test.yml` if testable without secrets

### Release a new version
```bash
git tag v<N>
git push origin v<N>
# Also move the major tag if bumping minor:
git tag -f v<major>
git push origin v<major> --force
```

### Update test workspace
Edit `tests/workspace.dsl` to reflect changes in DSL features or add new test cases for docs/ADRs.

---

## What This Repo Is NOT

- Not a Node.js or Python project — `package.json` is empty and has no purpose beyond tooling conventions
- Not a self-contained CLI — all execution logic is in the Docker image, not here
- Not a multi-file action — there are no shell scripts or compiled artifacts to maintain
