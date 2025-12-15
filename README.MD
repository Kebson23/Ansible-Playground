# Ansible Playground

Multi-container lab that spins up an Ansible control node, two target nodes, and an Nginx dashboard that proxies browser terminals via ShellInABox.

## Repository Layout
- docker-compose.yml: builds and wires all containers (shared build args, secrets, and static network).
- server-ansible/: Debian-based Ansible control node with ShellInABox terminal.
- client-ansible-debian/: Debian target node with ShellInABox terminal.
- client-ansible-rocky/: Oracle/Rocky-style target node compiling ShellInABox from source and custom themes.
- dashboard/: Nginx splash page and reverse proxy for the terminals.
- running/: shared entrypoint script that starts ShellInABox.
- passphrase-shellinabox/secrets: plaintext password used for the ShellInABox user during image build.

## Requirements
- Docker with BuildKit-enabled builds (for secrets and additional build contexts).
- Docker Compose v2.

## Quick Start
1) Set the terminal password (used for every node):
   - Windows PowerShell: `Set-Content -NoNewline -Path passphrase-shellinabox/secrets -Value "<strong-password>"`
   - Linux/macOS: `echo '<strong-password>' > passphrase-shellinabox/secrets`
2) Build and start everything: `docker compose up --build`
3) Open the dashboard: http://localhost:8080
   - Direct terminals (bypassing the dashboard): server http://localhost:4444, Debian node http://localhost:4555, Oracle/Rocky node http://localhost:4666.
4) Stop the lab: `docker compose down` (add `-v` if you also want to drop any volumes created later).

## Access & Credentials
- Username: `admin` (default from `shellinabox_USER` build arg in docker-compose.yml).
- Password: contents of `passphrase-shellinabox/secrets` at build time.
- ShellInABox runs with `--disable-ssl`; keep this behind trusted networks or terminate TLS at a reverse proxy.

## Dashboard
- Served on port 8080 from `dashboard/` (Polish-language landing page).
- Proxies to:
  - `/ansible/` -> control node (Ansible installed)
  - `/client/` -> Debian target node
  - `/client2/` -> Oracle/Rocky target node

## Networking
- Static bridge network `ansible-network` on 172.16.0.0/24 with fixed IPs to simplify hostnames inside the lab.
- Adjust the subnet in docker-compose.yml if it conflicts with your local networks.

## Customization Tips
- Change ShellInABox user or port by editing `shellinabox_USER` / `shellinabox_PORT` in docker-compose.yml.
- Update the password secret before each build if you rotate credentials.
- Tweak terminal themes in `client-ansible-rocky/shellinabox-css/` and the dashboard page in `dashboard/html/index.html`.
- The Oracle/Rocky client builds ShellInABox from source via `client-ansible-rocky/compilator/compile-shellinabox.sh`; adjust there if you need another version.

## Roadmap
- v1.0: Basic setup (current state; dashboard + Ansible control + two targets).
- v1.1: Hardening best practices (TLS termination, stricter auth, image updates).
- v1.2: Encryption (enable HTTPS for ShellInABox or front proxy, secrets handling).
- v1.3: Dynamic features and improvements (scaling nodes, tunable inventory, UX tweaks).

## Activity
- Active: v1.0 delivered via this compose stack.
- Upcoming: progress through v1.1–v1.3 per roadmap above.
