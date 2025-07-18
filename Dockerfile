FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Only generate Prisma client (doesn't require DATABASE_URL)
RUN npx prisma generate

RUN npm run build

EXPOSE 3000

# Start the app (DATABASE_URL will be provided at runtime)
CMD ["npm", "start"]
