#!/bin/sh

set -ex

source "$(dirname "$0")/../utils.sh"
aws_prerequisites

#MY_IP=$(wget http://ipinfo.io/ip -qO -)
MY_IP=$(curl -q http://ipinfo.io/ip)

echo "My ip: ${MY_IP}"

IP_PERMISSIONS=$(aws ec2 describe-security-groups --group-name administrable --query 'SecurityGroups[].IpPermissions[]')

if [ "${IP_PERMISSIONS}" != "[]" ]; then
  SKELETON=$(cat <<SKL
{
  "DryRun": false,
  "GroupName": "administrable",
  "IpPermissions": ${IP_PERMISSIONS}
}
SKL
)

  aws ec2 revoke-security-group-ingress --cli-input-json "${SKELETON}"
fi
# NOTE this doesn't work... but don't know why, for future research
#aws ec2 revoke-security-group-ingress --group-name administrable --Ip-permissions "${IP_PERMISSIONS}"

aws ec2 authorize-security-group-ingress --group-name administrable --protocol tcp --port 22 --cidr ${MY_IP}/32
aws ec2 authorize-security-group-ingress --group-name administrable --protocol tcp --port 2812 --cidr ${MY_IP}/32


aws ec2 authorize-security-group-ingress --group-name administrable --protocol tcp --port 8080 --cidr ${MY_IP}/32

echo "OK"
