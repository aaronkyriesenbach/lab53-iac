#!/bin/bash

SECRET_LOCATION=secrets

if [ ! -d $SECRET_LOCATION ]; then
    mkdir $SECRET_LOCATION
fi

echo "Generating JWT secret"
openssl rand -hex 128 > $SECRET_LOCATION/JWT_SECRET

echo "Generating Authelia LDAP user password"
openssl rand -hex 64 > $SECRET_LOCATION/LDAP_PASSWORD

echo "Generating session secret"
openssl rand -hex 128 > $SECRET_LOCATION/SESSION_SECRET

echo "Generating storage encryption key"
openssl rand -hex 128 > $SECRET_LOCATION/STORAGE_ENCRYPTION_KEY

echo "Generating HMAC secret"
openssl rand -hex 128 > $SECRET_LOCATION/HMAC_SECRET

echo "Generating RSA keypair for OIDC JWK signing"
openssl genrsa -out $SECRET_LOCATION/jwk_private.pem 2048
openssl rsa -in $SECRET_LOCATION/jwk_private.pem -outform PEM -pubout -out $SECRET_LOCATION/jwk_public.pem
