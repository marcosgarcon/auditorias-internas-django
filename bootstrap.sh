#!/usr/bin/env bash
set -e

mkdir -p docker/web
mkdir -p backend/{config,audits}/{templates,management/commands}
mkdir -p backend/audits/templates/pdf

# docker-compose
cat > docker-compose.yml << 'EOF'
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 5s
      timeout: 5s
      retries: 10

  web:
    build:
      context: .
      dockerfile: docker/web/Dockerfile
    env_file: .env
    command: bash -lc "python backend/manage.py migrate && python backend/manage.py runserver 0.0.0.0:8000"
    volumes:
      - .:/app
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy

volumes:
  pgdata:
EOF

# Dockerfile
cat > docker/web/Dockerfile << 'EOF'
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libcairo2 \
    pango1.0-tools \
    libpango-1.0-0 \
    libpangoft2-1.0-0 \
    libgdk-pixbuf-2.0-0 \
    libffi8 \
    libglib2.0-0 \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY backend /app/backend
EOF

# requirements
cat > requirements.txt << 'EOF'
Django==5.0.6
djangorestframework==3.15.2
psycopg2-binary==2.9.10
django-cors-headers==4.4.0
weasyprint==62.3
Pillow==11.0.0
drf-spectacular==0.27.2
EOF

# .env example
cat > .env.example << 'EOF'
DEBUG=1
SECRET_KEY=change-me
ALLOWED_HOSTS=*
POSTGRES_DB=auditorias
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
DATABASE_URL=postgresql://postgres:postgres@db:5432/auditorias
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
EOF

# manage.py
cat > backend/manage.py << 'EOF'
#!/usr/bin/env python
import os, sys
def main():
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
    from django.core.management import execute_from_command_line
    execute_from_command_line(sys.argv)
if __name__ == '__main__': main()
EOF
chmod +x backend/manage.py

# config __init__
cat > backend/config/__init__.py << 'EOF'
EOF

# settings.py
cat > backend/config/settings.py << 'EOF'
import os
from
