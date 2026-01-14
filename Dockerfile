FROM node:18-alpine AS build

WORKDIR /usr/src/app

COPY package*.json ./

# 'npm ci' é mais rápido e confiável para builds automatizados que 'npm install'
# Ele garante que as versões sejam exatamente as do package-lock.json
RUN npm ci

COPY . .

RUN npm run build

FROM node:18-alpine AS prod-deps

WORKDIR /usr/src/app

COPY package*.json ./

# --omit=dev (ou --only=production) instala apenas o necessário para rodar
RUN npm ci --omit=dev && npm cache clean --force

# ----------------------------
# Estágio 3: Final (Runtime)
# ----------------------------
FROM node:18-alpine3.19

WORKDIR /usr/src/app

# Copia apenas o necessário dos estágios anteriores
COPY --from=prod-deps /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/package*.json ./

EXPOSE 3000

# Dica: Se possível, use 'node dist/main.js' diretamente ao invés de npm start
# para melhor tratamento de sinais de encerramento (SIGTERM/SIGINT)
CMD ["npm", "run", "start:prod"]