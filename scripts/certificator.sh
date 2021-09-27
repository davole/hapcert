#!/bin/bash

# Import functions
. /etc/scripts/functions.sh

# Create/renew certificates
SCRIPTS=$(ls -d /etc/scripts/domains/*)
for SCRIPT in $SCRIPTS; do
  DOMAIN=$(echo $SCRIPT | sed 's/.*\/\(.*\).sh$/\1/')

  echo "Create/renew certificate for '$DOMAIN':"

  # Renew/create certificate
  echo "> renew/create certificate"
  renew_create_certificate $DOMAIN

  # Create PEM file
  echo "> create PEM file"
  create_pem $DOMAIN

  # Update HAProxy
  echo "> update HAProxy"
  update_haproxy $DOMAIN
done