# --------- downloader -----------
FROM cr.loongnix.cn/library/node:18.18 as downloader

WORKDIR /

RUN apt update && apt install wget -y

RUN wget -q https://github.com/Loongson-Cloud-Community/FastGPT/releases/download/v4.7/app.tar.gz && tar xf app.tar.gz

# --------- runner -----------
FROM cr.loongnix.cn/library/node:18.18 as runner

WORKDIR /app

# create user and use it
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# copy running files
COPY --from=downloader /app /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1
ENV PORT=3000

EXPOSE 3000

USER nextjs

ENV serverPath=./projects/app/server.js

ENTRYPOINT ["sh","-c","node ${serverPath}"]
