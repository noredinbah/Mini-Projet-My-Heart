# Define root directories for Docker and Kubernetes
$rootDir = "."
$dockerDir = "$rootDir\docker"
$kubernetesDir = "$rootDir\kubernetes"

# Create Docker and Kubernetes related directories
New-Item -Path $dockerDir -ItemType Directory -Force
New-Item -Path $kubernetesDir -ItemType Directory -Force

# Create Dockerfile template for services
Set-Content -Path "$dockerDir\Dockerfile" -Value @"
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
"@

# Create docker-compose.yml for local development with network setup
Set-Content -Path "$dockerDir\docker-compose.yml" -Value @"
version: '3'

services:
  patient-service:
    build: ./patient-service
    ports:
      - "5001:5005"
    networks:
      - myheart-network

  rendezvous-service:
    build: ./rendezvous-service
    ports:
      - "5002:5005"
    networks:
      - myheart-network

  dossier-medical-service:
    build: ./dossier-medical-service
    ports:
      - "5003:5005"
    networks:
      - myheart-network

  notification-service:
    build: ./notification-service
    ports:
      - "5004:5005"
    networks:
      - myheart-network

  facturation-service:
    build: ./facturation-service
    ports:
      - "5006:5005"
    networks:
      - myheart-network

  laboratoire-service:
    build: ./laboratoire-service
    ports:
      - "5007:5005"
    networks:
      - myheart-network

  pharmacie-service:
    build: ./pharmacie-service
    ports:
      - "5008:5005"
    networks:
      - myheart-network

  prescription-service:
    build: ./prescription-service
    ports:
      - "5009:5005"
    networks:
      - myheart-network

  kafka:
    image: wurstmeister/kafka
    environment:
      KAFKA_ADVERTISED_LISTENER: INSIDE://kafka:9093
      KAFKA_LISTENER_SECURITY_PROTOCOL: PLAINTEXT
      KAFKA_LISTENER_NAME_INSIDE: INSIDE
      KAFKA_LISTENER_INTERNAL: INSIDE://0.0.0.0:9093
      KAFKA_LISTENER_EXTERNAL: EXTERNAL://0.0.0.0:9092
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
    ports:
      - "9092:9092"
    networks:
      - myheart-network

  zookeeper:
    image: wurstmeister/zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
    ports:
      - "2181:2181"
    networks:
      - myheart-network

networks:
  myheart-network:
    driver: bridge
"@

# Create Kubernetes deployment, service, and ingress for each service
$services = @(
    "patient-service", "rendezvous-service", "dossier-medical-service", "notification-service",
    "facturation-service", "laboratoire-service", "pharmacie-service", "prescription-service"
)

foreach ($service in $services) {
    # Create Kubernetes deployment for each service
    Set-Content -Path "$kubernetesDir\deployment-$service.yaml" -Value @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $service
  template:
    metadata:
      labels:
        app: $service
    spec:
      containers:
        - name: $service
          image: $service:latest
          ports:
            - containerPort: 5005
"@

    # Create Kubernetes service for each service
    Set-Content -Path "$kubernetesDir\service-$service.yaml" -Value @"
apiVersion: v1
kind: Service
metadata:
  name: $service
spec:
  selector:
    app: $service
  ports:
    - protocol: TCP
      port: 5005
      targetPort: 5005
"@

    # Create Kubernetes ingress for each service (if ingress controller is set up)
    Set-Content -Path "$kubernetesDir\ingress-$service.yaml" -Value @"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $service-ingress
spec:
  rules:
    - host: $service.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: $service
                port:
                  number: 5005
"@
}

Write-Host "Docker and Kubernetes configuration setup completed at $rootDir"
