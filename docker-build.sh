#!/bin/sh -e
echo "Updating dependencies..."
go get
echo "Building Go binary..."
CGO_ENABLED=0 go build
echo "Building Docker image..."
docker build -t miguelgrinberg/gowebapp:latest .
echo "Pushing Docker image to DockerHub..."
docker push miguelgrinberg/gowebapp:latest
