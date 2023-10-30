FROM node:18.16.1

WORKDIR /app
COPY . .

RUN npm install
RUN npm run build

CMD [ "npm", "run", "preview", "--", "--host", "--port", "5173" ]
