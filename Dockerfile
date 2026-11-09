# Stage 1: Build the backend binary
FROM rust:1.77-slim-bookworm AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*
COPY Cargo.toml ./
RUN mkdir src && echo "fn main() {}" > src/main.rs && cargo build --release && rm -rf src
COPY src ./src
RUN touch src/main.rs && cargo build --release

# Stage 2: Minimal runtime image
FROM debian:bookworm-slim
WORKDIR /app
RUN apt-get update && apt-get install -y ca-certificates ffmpeg sqlite3 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/memoria /app/memoria
COPY dist /app/dist
RUN mkdir -p /data /media_sources
EXPOSE 8080
ENV DATABASE_URL="sqlite:///data/memoria.db?mode=rwc"
ENV RUST_LOG="info"
CMD ["/app/memoria"]
