FROM node:14-alpine as builder

WORKDIR /app

# Instalar dependencias necesarias para compilar node-sass
RUN apk add --no-cache python2 make g++ python3

# Copiar primero los archivos de dependencias
COPY package*.json ./

# Configurar sass para usar la versión binaria disponible o compilarse adecuadamente
ENV SASS_BINARY_SITE=https://github.com/sass/node-sass/releases/download
ENV NODE_OPTIONS="--max-old-space-size=4096"

# Instalar dependencias
RUN npm install --unsafe-perm

# Luego copiar el resto del código
COPY . .

# Construir la aplicación
RUN npm run build

# Segunda etapa - Nginx para servir el contenido estático
FROM nginx:1.21-alpine

# Copiar los archivos de la aplicación compilada
COPY --from=builder /app/dist /usr/share/nginx/html

# Crear y copiar el archivo de configuración de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
