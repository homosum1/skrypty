#!/bin/bash
docker run --rm -it \
  -p 8080:8080 \
  -v "$PWD":/app \
  -w /app \
  lapis-hello /bin/sh

  # moonc . && lapis server development
