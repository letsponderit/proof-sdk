# Ponder's deployment image for this fork. Railway builds it on every push to
# the `ponder` branch; see DEPLOY.md.
FROM node:22-bookworm-slim

# python3/make/g++ are needed to build better-sqlite3's native addon.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Dependencies first so edits to source don't reinstall them. Full install:
# tsx, the runtime entrypoint, is a devDependency upstream.
COPY package.json ./
RUN npm install --no-audit --no-fund

COPY . .

# The server serves static files from public/ only, but vite builds the editor
# bundle into dist/ — merge them or /d/:slug loads a blank "Loading editor…".
ARG RAILWAY_GIT_COMMIT_SHA=""
ENV GIT_COMMIT_SHA=${RAILWAY_GIT_COMMIT_SHA}
RUN npm run build && cp -a dist/assets/. public/assets/

ENV NODE_ENV=production
ENV PROOF_ENV=production

EXPOSE 4000
# Exec tsx directly (no npx wrapper) so SIGTERM reaches the server and deploy
# handoffs shut down cleanly instead of looking like crashes.
CMD ["node_modules/.bin/tsx", "server/index.ts"]
