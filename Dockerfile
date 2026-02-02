FROM debian:bookworm-slim

# Instalamos webhook, make y Google Cloud SDK
RUN apt-get update && apt-get install -y \
    webhook \
    make \
    curl \
    ffmpeg \
    gnupg \
    lsb-release \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update && apt-get install -y google-cloud-cli \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN mkdir -p ass
COPY fonts/ fonts/
COPY scripts/ scripts/
COPY hooks.json .
COPY Makefile . 

# Set ROOT environment variable to match project root
ENV ROOT=/app

# Exponemos el puerto por defecto de webhook
EXPOSE 9000

# Lanzamos el servicio
# -verbose para ver los logs en la consola de la nube
# -hooks indica dónde está tu configuración
CMD ["webhook", "-hooks", "hooks.json", "-verbose", "-port", "9000"]