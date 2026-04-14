# EasyCrypt devcontainer
# Base: Debian Bookworm (stable, good opam/OCaml support)
FROM debian:bookworm-slim

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# ── System dependencies ────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    git \
    curl \
    wget \
    unzip \
    pkg-config \
    # OCaml / opam requirements
    bubblewrap \
    rsync \
    m4 \
    patch \
    # EasyCrypt C-level deps
    libgmp-dev \
    libpcre2-dev \
    zlib1g-dev \
    # Python (used by EasyCrypt tooling)
    python3 \
    python3-yaml \
    # Useful in a dev container
    procps \
    less \
    rlwrap \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# ── Z3 4.13.x (apt ships 4.8 on Bookworm; EasyCrypt needs 4.12+) ─────────────
# Using the official upstream binary release.
# Z3 4.13.4 is the first release with correct Linux arm64 binaries.
# Naming convention: arm64 → arm64-glibc-2.34, x86_64 → x64-glibc-2.35
ARG Z3_VERSION=4.13.4
RUN ARCH="$(uname -m)" \
 && case "${ARCH}" in \
      aarch64|arm64) \
        Z3_ARCHIVE="z3-${Z3_VERSION}-arm64-glibc-2.34.zip" \
        Z3_DIR="z3-${Z3_VERSION}-arm64-glibc-2.34" \
        ;; \
      *) \
        Z3_ARCHIVE="z3-${Z3_VERSION}-x64-glibc-2.35.zip" \
        Z3_DIR="z3-${Z3_VERSION}-x64-glibc-2.35" \
        ;; \
    esac \
 && curl -fsSL "https://github.com/Z3Prover/z3/releases/download/z3-${Z3_VERSION}/${Z3_ARCHIVE}" \
         -o /tmp/z3.zip \
 && unzip /tmp/z3.zip -d /tmp/z3src \
 && cp /tmp/z3src/${Z3_DIR}/bin/z3 /usr/local/bin/z3 \
 && chmod +x /usr/local/bin/z3 \
 && rm -rf /tmp/z3.zip /tmp/z3src \
 && z3 --version

# ── Non-root user (Codespaces convention: "vscode") ───────────────────────────
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN groupadd --gid ${USER_GID} ${USERNAME} \
 && useradd  --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME}

# ── opam (installed as root so it can write to /usr/local/bin) ────────────────
RUN curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh \
    | bash -s -- --no-backup

# Switch to the non-root user for all subsequent steps
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Initialise opam (no sandbox inside Docker)
RUN opam init --bare --no-setup --disable-sandboxing -y

# Create a dedicated switch pinned to OCaml 4.14 (< 5.0, required by EasyCrypt)
RUN opam switch create easycrypt 4.14.2 -y

# Add EasyCrypt package and install all its opam dependencies
RUN opam pin -yn add easycrypt https://github.com/EasyCrypt/easycrypt.git \
 && opam install --switch=easycrypt --deps-only -y easycrypt

# Install Alt-Ergo 2.6.0 (the version recommended by EasyCrypt/Why3 1.8)
RUN opam install --switch=easycrypt -y alt-ergo.2.6.0

# Install EasyCrypt itself
RUN opam install --switch=easycrypt -y easycrypt

# ── Shell environment ──────────────────────────────────────────────────────────
# Make opam env available in every new shell session
RUN echo 'eval $(opam env --switch=easycrypt)' >> /home/${USERNAME}/.bashrc \
 && echo 'eval $(opam env --switch=easycrypt)' >> /home/${USERNAME}/.profile

# ── Why3 / EasyCrypt prover configuration ────────────────────────────────────
# Run why3config so EasyCrypt finds Z3 and Alt-Ergo automatically.
# We do this at image-build time so students don't need to do it manually.
RUN eval $(opam env --switch=easycrypt) \
 && easycrypt why3config

# ── Verify the installation ───────────────────────────────────────────────────
RUN eval $(opam env --switch=easycrypt) \
 && easycrypt
