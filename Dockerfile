FROM python:3.11-slim

RUN --mount=type=cache,target=/root/.cache/pip pip install -U pip

ARG TARGETPLATFORM
RUN <<EOF
apt-get update
apt-get install --no-install-recommends -y curl ffmpeg
if [ "$TARGETPLATFORM" != "linux/amd64" ]; then
	apt-get install --no-install-recommends -y build-essential
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app
RUN mkdir -p voices config

COPY requirements.txt /app/
RUN --mount=type=cache,target=/root/.cache/pip pip install -r requirements.txt

COPY *.py *.sh *.default.yaml README.md LICENSE /app/

ARG PRELOAD_MODEL
ENV PRELOAD_MODEL=${PRELOAD_MODEL}
ENV TTS_HOME=voices
ENV HF_HOME=voices
ENV COQUI_TOS_AGREED=1

CMD bash startup.sh
