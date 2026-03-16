#!/usr/bin/env bash
set -e
PROFILE="${AWS_PROFILE:-custodian}"
ZONE_NAME="castalia.institute"

echo "Using AWS profile: $PROFILE"
ZONE_ID=$(aws route53 list-hosted-zones --profile "$PROFILE" --query "HostedZones[?Name=='${ZONE_NAME}.'].Id" --output text | head -1)

if [ -z "$ZONE_ID" ] || [ "$ZONE_ID" == "None" ]; then
  echo "No hosted zone found for $ZONE_NAME."
  exit 1
fi

echo "Hosted zone ID: $ZONE_ID"
echo "Applying CNAME record for rover.castalia.institute..."
aws route53 change-resource-record-sets \
  --profile "$PROFILE" \
  --hosted-zone-id "$ZONE_ID" \
  --change-batch file://"$(dirname "$0")/route53-github-pages.json"

echo "Done. DNS may take a few minutes to propagate."
