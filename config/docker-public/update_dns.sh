#!/bin/bash

set -e

HOSTED_ZONE_ID="Z01889102EIVWW3UBDYVL"
NAME="lab53.net."
TYPE="A"
TTL=60
    
# Get current IP address
IP=$(curl http://checkip.amazonaws.com/)

# Validate IP address (makes sure Route 53 doesn't get updated with a malformed payload)
if [[ ! $IP =~ ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ ]]; then
	exit 1
fi

echo "Current IP is $IP"

# Get current
aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID | 
jq -r '.ResourceRecordSets[] | select (.Name == "'"$NAME"'") | select (.Type == "'"$TYPE"'") | .ResourceRecords[0].Value' > /tmp/current_route53_value

echo "IP in Route 53 is $(cat /tmp/current_route53_value)"

# Check if IP is different from Route 53
if grep -Fxq "$IP" /tmp/current_route53_value; then
	echo "IPs match, exiting"
	exit 1
fi

echo "IP changed from $(cat /tmp/current_route53_value) to $IP, updating records"

# Prepare route 53 payload
cat > /tmp/route53_changes.json << EOF
{
	"Comment":"Updated From DDNS Shell Script",
	"Changes":[{
		"Action":"UPSERT",
		"ResourceRecordSet": {
			"ResourceRecords": [{ "Value":"$IP" }],
			"Name":"$NAME",
			"Type":"$TYPE",
			"TTL":$TTL
		}
	}]
}
EOF
    
# Update records
aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file:///tmp/route53_changes.json >> /dev/null
