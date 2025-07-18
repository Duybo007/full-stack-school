# Use official Node.js image as base
FROM node:18-alpine AS base

# Set working directory
WORKDIR /app

# Install dependencies only with the needed files
COPY package*.json ./
RUN npm ci --omit=dev

# Copy Prisma files separately to leverage Docker cache
COPY prisma ./prisma

# Copy the rest of the application
COPY . .

# Generate the database
RUN npx prisma generate
RUN npx prisma migrate deploy

# Build the Next.js application
RUN npm run build

# Use a smaller image for the final build
FROM node:18-alpine AS runner

# Set working directory
WORKDIR /app

# Copy only the necessary artifacts from the builder stage
COPY --from=base /app/package.json ./
COPY --from=base /app/.next ./.next
COPY --from=base /app/public ./public
COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app/prisma ./prisma

# Expose port
EXPOSE 3000

# Start app in production mode
CMD ["npm", "start"]
