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

echo $(generate_post_data $1)

CERTSERIAL=`curl -H "X-Vault-Token: $2" -i -X POST http://10.10.0.112:8200/v1/venafi-pki/issue/cloud-int -d "$(generate_post_data $1)" -vvv --trace-ascii ./debug.out | jq '.data.serial_number' -j | sed -e s/:/-/g`
echo $CERTSERIAL

curl -H "X-Vault-Token: $2" -X GET http://10.10.0.112:8200/v1/venafi-pki/cert/$CERTSERIAL -vvv | jq '.data.certificate_chain' -j >> ./nginx.crt
curl -H "X-Vault-Token: $2" -X GET http://10.10.0.112:8200/v1/venafi-pki/cert/$CERTSERIAL -vvv | jq '.data.private_key' -j >> ./nginx.key
