# Adding a new microservice

This document outlines the steps required to add a new microservice to this project, based on how its actual pipeline works: GitHub Actions builds and pushes images to GHCR, and ArgoCD deploys them by syncing a Helm chart that is itself published to GHCR as an OCI artifact.

## 1. Create a new directory and add your source code

Create a new directory for your microservice inside `src/`, named after your service (e.g. `src/mynewservice/`). Add your source code and a `Dockerfile` there, following the structure of an existing service for your language.

No CI configuration changes are needed for this step: `.github/workflows/ci-trigger.yaml` automatically detects any changed folder under `src/**` on a push to `main`, builds it, runs a Trivy vulnerability scan, and pushes the image to GitHub Container Registry (GHCR) — the same pipeline every existing service already goes through.

## 2. Define its gRPC contract (if it talks to other services)

If your service needs to call, or be called by, another microservice, add its `service`/`message` definitions to `Protos/demo.proto`. Then regenerate the client/server stub code for your language the same way the existing services do — see `src/<an-existing-service>/genproto.sh` for the exact `protoc` invocation to copy.

## 3. Add a Helm chart template

Create `Helm-Chart/templates/<your-service>.yaml` with a `Deployment` and `Service`, using an existing template (e.g. `Helm-Chart/templates/cartservice.yaml`) as a starting point. Keep the same conventions: resource names driven by `.Values`, and an `{{- if .Values.<yourService>.create }}` guard so the service can be toggled off.

## 4. Register the image in the chart's values

Add your service to the `images:` map in `Helm-Chart/values.yaml`:

```yaml
images:
  mynewservice:
    repository: ghcr.io/<YOUR_GITHUB_USERNAME>/microservices-demo/mynewservice
    tag: v0.10.4
```

Add any other config your service's template needs (name, ports, resource limits) as its own top-level key, matching how `cartService:` or similar existing entries are structured.

## 5. Publish a new chart version to GHCR

ArgoCD does not read `Helm-Chart/` directly — it pulls a packaged OCI Helm chart from GHCR, as configured in the root `kustomization.yaml`:

```yaml
helmCharts:
  - name: onlineboutique
    repo: oci://ghcr.io/<YOUR_GITHUB_USERNAME>
    version: 0.10.4
```

Package and push the updated chart with the release script:

```bash
TAG=v0.10.5 GITHUB_USERNAME=<your-github-username> ./Docs/releasing/make-helm-chart.sh
```

This bumps `Helm-Chart/Chart.yaml`'s version, packages the chart, and pushes it to `oci://ghcr.io/<your-github-username>`. Make sure you're logged in first (`helm registry login ghcr.io`).

## 6. Bump the version ArgoCD tracks

Update `version:` in the root `kustomization.yaml` to match the version you just pushed (e.g. `0.10.5`). Commit and push — ArgoCD will detect the change and sync your new service into the cluster automatically.

## 7. Update documentation

- Add your service to the architecture list in the root `README.md` if it introduces meaningful new functionality.
- Update `docs/img`/`docs/images` diagrams if your service changes the overall architecture.
