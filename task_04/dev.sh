#!/bin/bash
docker run --rm -it -v "$PWD":/app -w /app lapis-hello moonc .
docker run --rm -it -p 8080:8080 -v "$PWD":/app -w /app lapis-hello lapis server development