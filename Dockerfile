# Dockerfile
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y nginx curl && apt-get clean
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

