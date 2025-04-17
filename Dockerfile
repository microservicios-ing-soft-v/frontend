FROM node:14-alpine as builder

WORKDIR /app

# Copiar primero los archivos de dependencias
COPY package*.json ./

# Instalar dependencias con un timeout más largo y opciones para mayor estabilidad
RUN npm install --no-fund --no-audit --prefer-offline --legacy-peer-deps

COPY . .

RUN npm run build

# Nginx para servir el contenido estático
FROM nginx:1.21-alpine

COPY --from=builder /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
