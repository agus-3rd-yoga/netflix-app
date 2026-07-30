#FROM node:24-alpine AS builder
#WORKDIR /app
#COPY package.json yarn.lock ./
#RUN yarn install --frozen-lockfile
#COPY . .
#RUN yarn build

#FROM nginx:stable-alpine
#WORKDIR /usr/share/nginx/html
#RUN rm -rf ./*
#COPY --from=builder /app/dist .
#EXPOSE 80
#CMD ["nginx", "-g", "daemon off;"]

# ----------------------------------------------------
# 1. Build Stage
# ----------------------------------------------------
FROM node:24-alpine AS builder

WORKDIR /app

# Enable corepack if using Yarn v2/v3/v4; optional for Yarn v1
# RUN corepack enable

# Copy lockfiles first to leverage Docker layer caching
COPY package.json yarn.lock ./

# Install all dependencies (including devDependencies required for Vite/TSC)
RUN yarn install --frozen-lockfile --prefer-offline

# Copy application source code
COPY . .

# Build the production static bundles
RUN yarn build

# ----------------------------------------------------
# 2. Production Stage
# ----------------------------------------------------
FROM nginx:alpine-slim AS runner

# Copy custom Nginx configuration to support SPA routing (React Router)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

# Run Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]