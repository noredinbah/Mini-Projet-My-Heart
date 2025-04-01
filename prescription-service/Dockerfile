# Base image for Node.js
FROM node:16

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application
COPY . .

# Expose port for service
EXPOSE 5006

# Command to run the application
CMD [ "node", "src/app.js" ]
