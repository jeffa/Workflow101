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

The GitHub Actions workflow for generating release notes is defined in `.github/workflows/release-notes.yml`

To use this workflow, follow the commit message convention and push to `main`. The `RELEASE_NOTES.md` file will be automatically updated.

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests.

## License
This project has no license. All rights reserved.
