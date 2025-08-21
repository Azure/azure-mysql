#!/usr/bin/env bash
set -euo pipefail

# Usage message function
usage() {
  echo "Usage: $0 --subscriptionId <subscriptionId> --location <location>"
  exit 1
}

# Parse named parameters using GNU getopt
ARGS=$(getopt -o '' --long subscriptionId:,location: -n "$0" -- "$@") || usage
eval set -- "$ARGS"

while true; do
  case "$1" in
    --subscriptionId)
      subscriptionId="$2"
      shift 2
      ;;
    --location)
      location="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      usage
      ;;
  esac
done

# Validate required arguments
if [[ -z "${subscriptionId-}" || -z "${location-}" ]]; then
  echo "Error: Missing required parameters."
  usage
fi

apiVersion="2023-12-30"
uri="/subscriptions/${subscriptionId}/providers/Microsoft.DBforMySQL/locations/${location}/capabilitySets?api-version=${apiVersion}"

echo "INFO: Calling API - GET $uri"

# Execute API call with logging
if response=$(az rest --method GET --uri "$uri" --output json --only-show-errors); then
  echo "INFO: API call succeeded"
else
  echo "ERROR: API call failed"
  exit 1
fi

data=$(echo "$response" | jq .)

# Check for 'value' array
if [[ "$(echo "$data" | jq '.value | length')" -lt 1 ]]; then
  echo "WARN: No capabilitySets returned — your subscription may lack access in region '$location'. Consider filing a support request."
  exit 0
fi

echo -e "\nSupported MySQL server versions in region '$location':"
supported_versions=$(echo "$response" | jq -r '.value[0].properties.supportedServerVersions // [] | .[]? | .name // empty')
if [[ -n "$supported_versions" ]]; then
  echo "$supported_versions" | sed 's/^/- /'
else
  echo "  [Warning] No supported server versions found; your subscription may lack access in this region. Consider filing a support request."
fi

echo -e "\nAvailable Flexible Server editions and HA modes:"
editions=$(echo "$response" | jq -c '.value[0].properties.supportedFlexibleServerEditions // [] | .[]?')
if [[ -n "$editions" ]]; then
  while IFS= read -r edition; do
    name=$(jq -r '.name' <<< "$edition")
    echo "Edition: $name"
    jq -c '.supportedSkus[]?' <<< "$edition" | while IFS= read -r sku; do
      sku_name=$(jq -r '.name' <<< "$sku" )
      hamodes=$(jq -r '.supportedHAMode | join(", ")' <<< "$sku")
      echo "  SKU Name: $sku_name; HA Modes: $hamodes"
    done
  done <<< "$editions"
else
  echo "  [Warning] No server editions found; your subscription may lack access in this region. Consider filing a support request."
fi