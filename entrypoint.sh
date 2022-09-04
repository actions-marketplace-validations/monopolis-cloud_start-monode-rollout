#!/bin/ash -xe

get_from_event() {
  jq -r "$1" "${GITHUB_EVENT_PATH}"
}

if jq --exit-status '.inputs.deployment_id' "$GITHUB_EVENT_PATH" >/dev/null; then
  MONOPOLIS_URL="https://github-api.monopolis.cloud/rollout/start/$(get_from_event '.repository.full_name')/$(get_from_event '.inputs.deployment_id')"

  CONFIGURATIONS=$(curl --fail -X POST "${MONOPOLIS_URL}" -H "Authorization: Bearer ${GITHUB_TOKEN}")
  echo ::set-output name=upstream-crosschecks::$UPSTREAM

  UPSTREAM=$(echo "$CROSSCHECK_DATA" | jq 'to_entries[] | select(.value.type == "upstream") | .key')
  echo ::set-output name=configurations::$CONFIGURATIONS

  DOWNSTREAM=$(echo "$CROSSCHECK_DATA" | jq 'to_entries[] | select(.value.type == "downstream") | .key')
  echo ::set-output name=downstream-crosschecks::$DOWNSTREAM
else
  echo ::set-output name=configurations::"{}"
  echo ::set-output name=upstream-crosschecks::"[]"
  echo ::set-output name=downstream-crosschecks::"[]"
fi
