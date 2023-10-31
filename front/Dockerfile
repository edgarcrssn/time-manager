FROM node:18-bullseye-slim

WORKDIR /app
COPY . .

RUN npm ci
RUN npm run build

CMD [ "npm", "run", "preview", "--", "--host", "--port", "5173" ]
