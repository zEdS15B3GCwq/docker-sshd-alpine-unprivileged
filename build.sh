#!/bin/bash
docker build --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') -t sshd-alpine-unprivileged:latest .
