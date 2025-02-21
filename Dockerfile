FROM golang:alpine3.20 AS gobuilder
RUN KEEP_SORTED=0.4.0 \
    && wget --no-verbose "https://github.com/google/keep-sorted/archive/refs/tags/v${KEEP_SORTED}.tar.gz" -O /tmp/keep-sorted.tar.gz \
    && tar -xzf /tmp/keep-sorted.tar.gz --directory /tmp \
    && cd "/tmp/keep-sorted-${KEEP_SORTED}" \
    && go build -o /usr/bin

FROM debian:sid
RUN echo "export PATH=$PATH:/usr/bin" >> ~/.profile
RUN CODENARC=3.3.0 \
    && DENO=1.40.3 \
    && GJF=1.21.0 \
    && HADOLINT=2.12.0 \
    && LYCHEE=0.14.3 \
    && PMD=6.55.0 \
    && mkdir -p "${HOME}/.cache/jars" \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        black \
        cpanminus \
        gcc \
        git \
        jq \
        libxml2-utils \
        make \
        mypy \
        npm \
        openjdk-17-jre \
        pgformatter \
        pylint \
        python3 \
        python3-dev \
        python3-pglast \
        python3-pip \
        python3-venv \
        pyupgrade \
        shellcheck \
        shfmt \
        unzip \
        vim \
        vulture \
        wget \
        yamllint \
        yq \
        passwd \
    && pip install --no-cache-dir --break-system-packages ruff \
    && cpanm --notest YAML::Tidy \
    && npm install -g --ignore-scripts prettier @prettier/plugin-xml sql-formatter \
    && npm cache clean --force \
    && wget --no-verbose "https://github.com/pmd/pmd/releases/download/pmd_releases%2F${PMD}/pmd-bin-${PMD}.zip" -O /tmp/pmd.zip \
    && unzip /tmp/pmd.zip -d "${HOME}/.cache" \
    && wget --no-verbose "https://github.com/lycheeverse/lychee/releases/download/v${LYCHEE}/lychee-v${LYCHEE}-x86_64-unknown-linux-gnu.tar.gz" -O /tmp/lychee.tar.gz \
    && tar -xzf /tmp/lychee.tar.gz --directory /usr/bin \
        && wget --no-verbose "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT}/hadolint-Linux-x86_64" -O /usr/bin/hadolint && chmod +x /usr/bin/hadolint \
        && wget --no-verbose "https://github.com/denoland/deno/releases/download/v${DENO}/deno-x86_64-unknown-linux-gnu.zip" -O /tmp/deno.zip && unzip /tmp/deno.zip -d /usr/local/bin \
        && wget --no-verbose "https://repo1.maven.org/maven2/org/codenarc/CodeNarc/${CODENARC}/CodeNarc-${CODENARC}-all.jar" -O "${HOME}/.cache/jars/codenarc.jar" \
        && wget --no-verbose "https://github.com/google/google-java-format/releases/download/v${GJF}/google-java-format-${GJF}-all-deps.jar" -O "$HOME/.cache/jars/googlejavaformat.jar" \
    && apt-get remove -y \
        cpanminus \
        gcc \
        npm \
        unzip \
        wget \
    && apt-get autoremove -y \
    && apt-get install --no-install-recommends -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /root/.cpanm

COPY tools /opt/linters/tools

COPY --from=gobuilder /usr/bin/keep-sorted /usr/bin
