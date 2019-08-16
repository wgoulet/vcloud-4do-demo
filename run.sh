#!/bin/bash

# from https://stackoverflow.com/questions/17029902/using-curl-post-with-variables-defined-in-bash-script-functions
generate_post_data()
{
    cat <<EOF
{
  "common_name":"$1"
}
EOF
}

echo $1
echo $2

CERTSERIAL=`curl -H "X-Vault-Token: $2" -X POST http://devopshost:8200/v1/venafi-pki/issue/cloud-backend -d "$(generate_post_data $1)" | jq '.data.serial_number' -j | sed -e s/:/-/g`
echo $CERTSERIAL

curl -H "X-Vault-Token: $2" -X GET http://devopshost:8200/v1/venafi-pki/cert/$CERTSERIAL | jq '.data.certificate_chain' -j 
curl -H "X-Vault-Token: $2" -X GET http://devopshost:8200/v1/venafi-pki/cert/$CERTSERIAL | jq '.data.certificate_chain' -j >> /etc/ssl/nginx.crt
curl -H "X-Vault-Token: $2" -X GET http://devopshost:8200/v1/venafi-pki/cert/$CERTSERIAL | jq '.data.private_key' -j >> /etc/ssl/nginx.key
nginx -g "daemon off;"

