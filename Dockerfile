# syntax=docker/dockerfile:1

# ---- Build stage ----
FROM python:3-alpine3.23 AS builder

# Optional extra dependencies (e.g. bcrypt, ldap)
ARG DEPENDENCIES=bcrypt

# Install build deps, create venv, install Radicale from local source
RUN apk add --no-cache gcc libffi-dev musl-dev

# Copy upstream source (checked out from the upstream branch by the workflow)
COPY . /src

RUN python -m venv /app/venv \
    && /app/venv/bin/pip install --no-cache-dir --upgrade pip \
    && /app/venv/bin/pip install --no-cache-dir "/src[${DEPENDENCIES}]"


# ---- Final stage ----
FROM python:3-alpine3.23

# OCI standard labels — populated by the build workflow
ARG VERSION=unknown
ARG BUILD_DATE=unknown
ARG VCS_REF=unknown

LABEL org.opencontainers.image.title="Radicale" \
      org.opencontainers.image.description="A simple CalDAV and CardDAV server" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://github.com/mmBesar/Radicale" \
      org.opencontainers.image.upstream="https://github.com/Kozea/Radicale" \
      org.opencontainers.image.licenses="GPL-3.0"

WORKDIR /app

# Create radicale user/group matching upstream (uid/gid 1000)
RUN addgroup -g 1000 radicale \
    && adduser radicale \
        --home /var/lib/radicale \
        --system \
        --uid 1000 \
        --disabled-password \
        -G radicale \
    && apk add --no-cache ca-certificates openssl

# Copy the compiled venv from builder
COPY --chown=radicale:radicale --from=builder /app/venv /app

# Persistent storage for calendars and contacts
VOLUME /var/lib/radicale

# Radicale default port
EXPOSE 5232

# Healthcheck using wget (already in alpine — no extra package needed)
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:5232 || exit 1

USER radicale

ENTRYPOINT ["/app/bin/python", "/app/bin/radicale"]
CMD ["--hosts", "0.0.0.0:5232,[::]:5232"]
