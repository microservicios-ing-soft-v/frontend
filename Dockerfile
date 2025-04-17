FROM node:12 as builder

WORKDIR /app

# Configuración específica para node-sass
ENV NODE_ENV=development
ENV SASS_BINARY_NAME=linux-x64-64_binding.node
ENV SASS_BINARY_SITE=https://github.com/sass/node-sass/releases/download/v4.7.2

# Instalar herramientas necesarias
RUN apt-get update && \
    apt-get install -y python g++ build-essential && \
    npm install -g node-gyp

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias con retry
RUN npm config set unsafe-perm true && \
    npm install --force --no-optional

# Copiar el resto del código fuente
COPY . .

# Construir la aplicación
RUN npm run build || npm run build || npm run build

# Segunda etapa - Nginx para servir el contenido estático
FROM nginx:1.21-alpine

# Copiar los archivos compilados desde la etapa de builder
# Ajusta la ruta si tu proyecto Vue usa otra carpeta de salida
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
