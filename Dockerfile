FROM node:19-alpine AS build_node_modules

# Copy Web UI
COPY src/ /app/
WORKDIR /app
RUN npm install
RUN npm ci --production
FROM node:19-alpine 

COPY --from=build_node_modules /app /app

RUN mv /app/node_modules /node_modules

# Enable this to run `npm run serve`
RUN npm i -g nodemon

# Install Linux packages
RUN apk add -U --no-cache \
  wireguard-tools \
  dumb-init

# Expose Ports
EXPOSE 51820/udp
EXPOSE 51821/tcp

# Set Environment
ENV DEBUG=Server,WireGuard

# Run Web UI
WORKDIR /app
CMD ["/usr/bin/dumb-init", "node", "server.js"]