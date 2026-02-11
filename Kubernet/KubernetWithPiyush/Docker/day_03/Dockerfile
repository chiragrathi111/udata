FROM node:18 AS installer

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

RUN npm run build 

FROM nginx:latest AS developer

COPY --from=installer /app/build /usr/share/nginx/htmldofker