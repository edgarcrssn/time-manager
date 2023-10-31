FROM node:20.9.0

WORKDIR /app
COPY . .

RUN npm ci
RUN npm run build

CMD [ "npm", "run", "preview", "--", "--host", "--port", "5173" ]
