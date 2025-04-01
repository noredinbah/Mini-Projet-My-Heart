# Use a base image that fits your service's tech stack
FROM node:14-alpine

# Set working directory inside the container
WORKDIR /usr/src/app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy application code
COPY . .

# Expose the port the app will run on
EXPOSE 5005

# Command to run the service
CMD [ "npm", "start" ]
