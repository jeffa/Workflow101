# bash-sample

A simple Bash script example that prints "Hello, <name>!" with a basic test harness and CI workflow.

## Features
- Prints `Hello, <name>!` (defaults to "World").
- Uses strict mode (`set -euo pipefail`).
- Includes a basic test script (`test.sh`).
- GitHub Actions CI: linting (shellcheck), testing, packaging, and optional deployment.

## Requirements
- Bash (3.2+)
- shellcheck (for linting)
- zip, unzip (for packaging)

## Getting Started

### Clone the repository
```bash
git clone <repository-url>
cd bash-sample
```

### Make scripts executable
```bash
chmod +x main.sh test.sh
```

## Usage
Run the main script:
```bash
./main.sh
# Hello, World!

./main.sh Alice
# Hello, Alice!
```

## Testing
Run the test script to verify behavior:
```bash
./test.sh
```

## Linting
You can check the scripts with shellcheck:
```bash
shellcheck main.sh test.sh
```

## CI & Deployment
The GitHub Actions workflow is defined in `.github/workflows/ci.yaml`:
- **build**: runs on pushes and pull requests to `main`, performs linting, tests, and packages `main.sh` into `release.zip`.
- **deploy**: manually triggered (`workflow_dispatch`) with `deploy_to_server=true`; downloads the artifact and copies `main.sh` to a remote server via SCP.

To enable deployment, set the following GitHub Secrets:
- `DEPLOY_USER`
- `DEPLOY_SERVER`
- `DEPLOY_SSH_PRIVATE_KEY`

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests.

## License
This project has no license. All rights reserved.