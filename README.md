# Workflow 101

A simple Github project that focuses on Action Workflows.


## Getting Started
The GitHub Actions workflow is defined in `.github/workflows/ci.yaml`:
- **build**: runs on pushes and pull requests to `main`, performs linting, tests, and packages `main.sh` into `release.zip`.
- **deploy**: manually triggered (`workflow_dispatch`) with `deploy_to_server=true`; downloads the artifact and copies `main.sh` to a remote server via SCP.

To enable deployment, set the following GitHub Secrets:
- `DEPLOY_USER`
- `DEPLOY_SERVER`
- `DEPLOY_SSH_PRIVATE_KEY`

## Release Notes

The GitHub Actions workflow for generating release notes is defined in `.github/workflows/release-notes.yml`:
- **Trigger**: Runs on every push to `main`.
- **Permissions**: `contents: write` to allow committing `RELEASE_NOTES.md`.
- **Steps**:
  - **Checkout repository**: `actions/checkout@v4` with `fetch-depth: 0` and `persist-credentials: true` to access full commit history and retain auth for pushing changes.
  - **Update release notes**: Executes `bash scripts/update_release_notes.sh ${{ github.event.before }} ${{ github.sha }}` to parse commit messages tagged with `added:`, `updated:`, or `deleted:` and insert entries into `RELEASE_NOTES.md`.
  - **Commit and push changes**: Configures Git user as `github-actions[bot]`, adds `RELEASE_NOTES.md`, and commits/pushes if there are updates.

The `scripts/update_release_notes.sh` script:
- **Initialization**: Creates `RELEASE_NOTES.md` with a `## Unreleased` section (and subsections for **Added**, **Updated**, **Deleted**) if the file does not exist.
- **Log parsing**: Uses `git log --format='%h %s' <previous_commit>..<current_commit>` to scan commit messages for tags in the form `added: <description>`, `updated: <description>`, or `deleted: <description>`.
- **Entry insertion**: Appends entries in the format `- <description> (<short_hash>)` under the appropriate section in `RELEASE_NOTES.md`.

To use this workflow, follow the commit message convention and push to `main`. The `RELEASE_NOTES.md` file will be automatically updated.

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests.

## License
This project has no license. All rights reserved.
