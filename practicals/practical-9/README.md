# Practical 9: Installing Docker and Running Your First Container

This practical focuses on containerization using Docker, an essential skill for modern cloud engineering.

## Objectives

- Install and configure Docker
- Understand container basics
- Build and manage containers
- Work with Docker networking
- Create custom Docker images

## Prerequisites

- Completed Practicals 1-8
- Understanding of Linux services
- Basic networking knowledge

## Step-by-Step Guide

### 1. Docker Installation

```bash
# Update system
sudo apt update
sudo apt upgrade -y

# Install prerequisites
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add current user to docker group
sudo usermod -aG docker $USER
```

### 2. Basic Docker Commands

```bash
# Test installation
docker --version
docker run hello-world

# List containers
docker ps  # Running containers
docker ps -a  # All containers

# Container lifecycle
docker run -d --name web nginx
docker stop web
docker start web
docker restart web
docker rm web

# Container logs
docker logs web
docker logs -f web  # Follow logs
```

### 3. Working with Docker Images

```bash
# List images
docker images

# Pull images
docker pull ubuntu:latest
docker pull nginx:stable

# Remove images
docker rmi nginx:stable

# Build custom image
mkdir docker-test
cd docker-test
```

Create a Dockerfile:
```dockerfile
FROM ubuntu:latest
LABEL maintainer="your-email@example.com"

# Install packages
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy custom configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
```

Build and run:
```bash
docker build -t my-nginx .
docker run -d -p 80:80 my-nginx
```

### 4. Docker Networking

```bash
# List networks
docker network ls

# Create network
docker network create myapp-network

# Run containers in network
docker run -d --name db --network myapp-network mysql:5.7
docker run -d --name web --network myapp-network nginx

# Inspect network
docker network inspect myapp-network
```

### 5. Docker Compose

Create docker-compose.yml:
```yaml
version: '3'
services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./website:/usr/share/nginx/html
    depends_on:
      - db
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: myapp
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
```

Run with Docker Compose:
```bash
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Start services
docker-compose up -d

# Stop services
docker-compose down
```

### 6. Docker Monitoring

Create a monitoring script:
```bash
sudo vi /usr/local/bin/monitor_docker.sh
```

Add monitoring script content (see scripts/monitor_docker.sh).

## Expected Outcomes

- [x] Docker successfully installed
- [x] Basic container management
- [x] Custom image creation
- [x] Multi-container applications
- [x] Container monitoring

## Docker Best Practices

### 1. Image Management

```bash
# Use specific tags
docker pull nginx:1.21.6

# Clean unused images
docker image prune -a

# Use multi-stage builds
# Example Dockerfile
FROM node:14 AS builder
WORKDIR /app
COPY . .
RUN npm install && npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

### 2. Container Security

```bash
# Scan images for vulnerabilities
docker scan nginx:latest

# Run containers with limited privileges
docker run --user 1000:1000 nginx

# Use read-only root filesystem
docker run --read-only nginx
```

### 3. Resource Management

```bash
# Limit container resources
docker run -d \
  --name limited-nginx \
  --cpus=0.5 \
  --memory=512m \
  nginx
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   # Fix Docker socket permissions
   sudo chmod 666 /var/run/docker.sock
   
   # Add user to Docker group
   sudo usermod -aG docker $USER
   ```

2. **Container Won't Start**
   ```bash
   # Check logs
   docker logs container_name
   
   # Check system resources
   docker stats
   ```

3. **Network Issues**
   ```bash
   # Check container networking
   docker network inspect bridge
   
   # Enter container network namespace
   docker exec -it container_name bash
   ```

## Career Tips

- Learn Docker Compose for multi-container apps
- Understand container orchestration (Kubernetes)
- Practice building efficient Dockerfiles
- Learn about container security
- Understand Docker networking

## Additional Resources

Create a container management dashboard:
```bash
# Install monitoring tools
docker run -d \
  --name=portainer \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  portainer/portainer-ce
```

## Practice Exercises

1. Create a custom LAMP stack using Docker Compose
2. Build a multi-stage Dockerfile for a Node.js application
3. Set up container monitoring with Prometheus and Grafana
4. Create a Docker registry with authentication
5. Implement automated container updates using Watchtower