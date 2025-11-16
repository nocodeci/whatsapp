FROM node:20-alpine

# Install build dependencies
RUN apk add --no-cache python3 make g++ sqlite

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY src/ ./src/

# Create store directory
RUN mkdir -p /app/store

# Expose port
EXPOSE 8080

# Run the application
CMD ["npm", "start"]


