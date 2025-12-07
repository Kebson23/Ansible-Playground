# Docker Best Practices Guide

> A concise, opinionated reference for building secure, efficient, and maintainable Docker images and running containers according to modern best practices.

---

## 1. Core Principles

- Build deterministic and reproducible images.
- Keep images small to reduce attack surface and speed up deployment.
- Treat containers as ephemeral:
  - Persistence belongs in volumes, not the container filesystem.
- One container = one main process.
- All configuration is code-driven (Infrastructure as Code mindset).

---

## 2. Base Image Best Practices

- Use official images (e.g., python:3.12-slim, nginx:alpine, golang:1.23).
- Prefer minimal bases:
  - alpine, *-slim, distroless.
- Pin image versions.
- Maintain consistency across services.

---

## 3. Dockerfile Architecture

- Order layers for maximum build-cache usage:
  1. Base image
  2. System packages
  3. Language dependencies
  4. Application code
- Use `.dockerignore` to exclude:
  - `.git/`, logs, build artifacts, `node_modules`, credentials.
- Prefer `COPY` over `ADD`.
- Combine related commands:
  ```dockerfile
  RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates \
      && rm -rf /var/lib/apt/lists/*

4. Multi-Stage Builds

Example:

FROM golang:1.23 AS builder
WORKDIR /src
COPY . .
RUN go build -o app ./cmd/app

FROM gcr.io/distroless/base-debian12
COPY --from=builder /src/app /app
ENTRYPOINT ["/app"]


Benefits:

Smaller production images

No compilers or unnecessary tools in final image

5. Security Best Practices

Never store secrets in images.

Run as a non-root user:

RUN adduser --uid 10001 --disabled-password appuser
USER appuser


Enable read-only root filesystem.

Drop Linux capabilities:

--cap-drop=ALL --cap-add=NET_BIND_SERVICE


Keep dependencies updated.

Use image scanning tools (Trivy, Clair, Snyk).

6. OS & Package Manager Practices

Debian/Ubuntu:

Use --no-install-recommends

Always clean apt cache

Alpine:

Use apk add --no-cache

Pin critical packages.

Remove unnecessary build dependencies.

7. Application Dependency Management

Use deterministic lockfiles.

Install dependencies before copying full source for cache efficiency:

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .


Separate dev and production dependencies.

8. Environment Variables & Configuration

Store environment-specific values outside the image.

Avoid secrets.

Follow 12-factor app:

Configuration via environment variables.

Provide safe defaults.

9. Entrypoint & Command

Use exec form:

ENTRYPOINT ["./entrypoint.sh"]
CMD ["run"]


Entrypoint responsibilities:

Logging setup

Environment validation

Migrations

Handle PID1 correctly (tini/init when needed).

10. Logging

Log to stdout and stderr.

Avoid writing logs to files.

Prefer structured logs (JSON).

11. Volumes & Persistence

Define explicit persistent paths.

Avoid storing mutable data in container filesystem.

Use volumes for database data, caches, uploads.

Always document expected volume paths.

12. Networking

Expose only necessary ports.

Do not hardcode IPs or hostnames.

Let reverse proxies / ingress controllers handle TLS.

13. Resource Limits

Set CPU and memory limits in Compose/K8s.

Ensure graceful behavior under pressure.

Avoid unbounded memory usage.

14. Docker Compose Best Practices

Use Compose to define services declaratively.

Store config in .env files.

Use override files for local dev:

docker-compose.override.yml

Use named networks and volumes.

15. CI/CD & Image Lifecycle

Build images in CI pipelines.

Use immutable tags:

myapp:1.0.3
myapp:2025-12-07-abcdef


Use build caching (BuildKit).

Push versioned + tracking tags.

Sign images (cosign).

Generate SBOMs.

16. Observability & Health Checks

Provide:

/health

/ready

/metrics

Emit structured metrics (OpenTelemetry / Prometheus).

Use Docker HEALTHCHECK where appropriate.

17. Anti-Patterns (Avoid)

Using the latest tag.

Running containers as root.

Baking secrets into the image.

Installing debug tools in production images.

Treating containers like VMs.

Very large images.

18. Final Checklist

 Minimal, pinned base image

 .dockerignore configured

 Multi-stage build used if applicable

 Secrets not stored in image

 Non-root user

 Logs to stdout/stderr

 No persistent data inside container

 Image scanned and rebuilt regularly

 Immutable version tagging

 CI-built, not locally built for prod