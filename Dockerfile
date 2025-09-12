# Use official Node.js LTS
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Install dependencies first for better caching
COPY package*.json ./
RUN npm ci --only=production || npm install --only=production

# Copy app source
COPY . .

# Expose app port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
