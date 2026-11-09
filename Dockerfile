# Stage 1: Build the backend binary
FROM rust:1.80-bullseye AS builder
WORKDIR /app
COPY Cargo.toml ./
RUN mkdir src && echo "fn main() {}" > src/main.rs && cargo build --release
COPY src ./src
RUN cargo build --release

# Stage 2: Runtime environment
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libsqlite3-0 \
    zip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/target/release/media_vault /app/media_vault
COPY dist /app/dist

VOLUME ["/data", "/media_sources"]
EXPOSE 8080
CMD ["/app/media_vault"]
