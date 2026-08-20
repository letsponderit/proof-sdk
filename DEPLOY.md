# Ponder fork — deployment

This is Ponder's fork of [EveryInc/proof-sdk](https://github.com/EveryInc/proof-sdk),
serving <https://docs.letsponder.it>. Not affiliated with or endorsed by Every;
the hosted product is [Proof](https://proofeditor.ai).

## Branches

- `main` — tracks upstream, unmodified.
- `ponder` — what we deploy: upstream plus our fixes and styling.

## Deploying

Railway service `proof` (project `meeting-companion`) builds `Dockerfile` on
every push to `ponder`. Nothing else to run.

Rollback is a click in the Railway dashboard — redeploy any earlier deployment;
documents live on the `/data` volume and are untouched by image changes.

## Syncing upstream

```bash
git fetch upstream
git checkout main && git merge --ff-only upstream/main && git push
git checkout ponder && git merge main
```

Upstream is dormant (last commit March 2026), so expect this to be rare.

## Runtime env (set on the Railway service, not here)

`PROOF_COLLAB_SIGNING_SECRET` (required for realtime collab off localhost),
`PROOF_PUBLIC_BASE_URL`, `PROOF_CORS_ALLOW_ORIGINS`, `PROOF_SINGLE_REPLICA=1`,
`PROOF_ALLOW_FORCE_REWRITE=1`, `PROOF_COMMENT_UI_DEFAULT_MODE=auto`,
`DATABASE_PATH=/data/proof.db`, `SNAPSHOT_DIR=/data/snapshots`, `PORT=4000`.

## Local development

```bash
npm install
npm run serve   # API + collab on :4000
npm run dev     # editor on :3000
npm test
```

To exercise the built SPA against the local server the way production does:
`npm run build && cp -a dist/assets/. public/assets/`, then open
`http://localhost:4000/d/<slug>?token=…`.
