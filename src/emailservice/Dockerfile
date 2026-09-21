
FROM python:3.10.8-slim@sha256:abf96998af340975c26177b900c10cfb40716c985325303c063736f0f5cf3171 as base

FROM base as builder

RUN printf 'deb http://snapshot.debian.org/archive/debian/20230201T000000Z bullseye main\ndeb http://snapshot.debian.org/archive/debian-security/20230201T000000Z bullseye-security main\n' > /etc/apt/sources.list \
    && apt-get -o Acquire::Check-Valid-Until=false -qq update \
    && apt-get install -y --no-install-recommends \
        libc6 wget g++ \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install -r requirements.txt

FROM base
ENV PYTHONUNBUFFERED=1
ENV ENABLE_PROFILER=1

WORKDIR /email_server

COPY --from=builder /usr/local/lib/python3.10/ /usr/local/lib/python3.10/

COPY . .

EXPOSE 8080
ENTRYPOINT [ "python", "email_server.py" ]
