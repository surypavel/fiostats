# Fly's unmanaged postgres-flex image with pgvector added.
# Deploy to the Postgres app (NOT the web app):
#   fly deploy . -a <your-db-app-name> --image-label pgvector
FROM flyio/postgres-flex:17.2

RUN apt-get update \
  && apt-get install -y --no-install-recommends postgresql-17-pgvector \
  && rm -rf /var/lib/apt/lists/*
