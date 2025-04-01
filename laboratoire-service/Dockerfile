# Base image for Node.js
FROM node:16

# Set working directory
WORKDIR /usr/src/app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy the application
COPY . .

# Expose port for the service
EXPOSE 5009

# Command to run the application
CMD [ "node", "src/server/index.js" ]
