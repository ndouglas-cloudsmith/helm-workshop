#!/bin/bash

# Set Cloudsmith credentials
export CLOUDSMITH_API_KEY="728c0c63e71048798c94a0fdbaffde5b7b2f9605"
export CLOUDSMITH_ORG="acme-corporation"

echo "Environment variables set:"
echo "CLOUDSMITH_API_KEY=${CLOUDSMITH_API_KEY:0:5}****************"
echo "CLOUDSMITH_ORG=$CLOUDSMITH_ORG"
