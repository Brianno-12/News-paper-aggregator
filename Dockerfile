# Stage 1: Build the Flutter web app
FROM debian:latest AS build-env

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y curl git unzip

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"

# Set up Flutter and enable web
RUN flutter doctor
RUN flutter config --enable-web

# Copy the app files
WORKDIR /app
COPY . .

# Get app dependencies
RUN flutter pub get

# Build the web app
RUN flutter build web

# Stage 2: Create the runtime image
FROM nginx:alpine

# Copy the built web files to nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy a custom nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 