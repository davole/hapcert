#!/bin/bash

# Create certificate
function create_certificate {
  DOMAIN=$1

  if [ -f /etc/scripts/domains/$DOMAIN.sh ]; then
    # Execute certificate request script
    . /etc/scripts/domains/$DOMAIN.sh
  else
    return 1
  fi
}

# Concatenate certificate files into PEM
function create_pem {
  DOMAIN=$1

  if [ -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem -a -f /etc/letsencrypt/live/$DOMAIN/privkey.pem ]; then
    cat /etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/letsencrypt/live/$DOMAIN/privkey.pem > /etc/certificates/$DOMAIN.pem
  else
    return 1
  fi
}

# Update certificates in HAProxy
function update_haproxy {
  DOMAIN=$1

  if [ -f /etc/certificates/$DOMAIN.pem ]; then
    # Start transaction
    echo -e "set ssl cert /usr/local/etc/haproxy/certificates/$DOMAIN.pem <<\n$(cat /etc/certificates/$DOMAIN.pem)\n" | socat tcp-connect:haproxy:9999 -

    # Commit transaction
    echo "commit ssl cert /usr/local/etc/haproxy/certificates/$DOMAIN.pem" | socat tcp-connect:haproxy:9999 -

    # Show certification info
    echo "show ssl cert /usr/local/etc/haproxy/certificates/$DOMAIN.pem" | socat tcp-connect:haproxy:9999 -
  else
    return 1
  fi
}

# Renew a certificate
function renew_create_certificate {
  DOMAIN=$1

  if [ -d /etc/letsencrypt/live/$DOMAIN ]; then
    certbot renew --http-01-port=380
  else
    create_certificate $DOMAIN
  fi
}
