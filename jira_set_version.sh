#!/bin/bash

URL=$INPUT_URL
TOKEN=$INPUT_TOKEN
VERSION=$INPUT_VERSION
TICKETS=$INPUT_TICKETS

#
# Performs a post request
# Arguments:
# 1. method: one of POST, PUT, GET
# 1. relative path, will be appended to URL to build the complete url
# 2. request body
#
# Result:
# sets the global variables LAST_HTTP_STATUS and LAST_RESPONSE_BODY
#
function send {
  method=$1
  relativePath=$2
  requestBody=$3

  echo "executing $method to $URL$relativePath: $requestBody"

  # print response_code to stdout and response body to file
  LAST_HTTP_STATUS=$(curl --request "$method" \
    -w '%{response_code}' \
    -s \
    -o output.json \
    --url "$URL$relativePath" \
    --header "Authorization: Bearer $TOKEN" \
    --header 'Content-Type: application/json' \
    --data "$requestBody")
  LAST_RESPONSE_BODY=$(cat output.json)
  rm output.json
}

# iterate over all ticket ids
export IFS=","
# shellcheck disable=SC2066
for ticketId in $TICKETS; do

  # extract the jira project from the ticket which is expected to
  # be the part before the hyphen.
  PROJECT=$(sed -nE "s/(.+)-[0-9]+/\1/p" <<< "$ticketId")

  # create version in this project
  echo "Creation version $VERSION in project $PROJECT"
  send POST '/rest/api/2/version' "{ \"name\": \"$VERSION\", \"project\": \"$PROJECT\", \"released\": true }"
  if [[ $LAST_HTTP_STATUS == 400 ]];then
    echo "The version $VERSION probably already exists. Continuing."
  elif [[ $LAST_HTTP_STATUS == 201 ]];then
    echo "The version $VERSION has been created"
  else
    echo "Something failed: $LAST_RESPONSE_BODY"
    exit 1
  fi
  
  # set version on ticket

  echo "Setting version $VERSION on ticket $ticketId"

  # store the body in a variable
  BODY=$(cat <<-END
  {
    "update": {
      "fixVersions": [
        {
          "add": {
            "name": "$VERSION"
          }
        }
      ]
    }
  }
END
  )
  send PUT "/rest/api/2/issue/$ticketId" "$BODY"
  if [[ $LAST_HTTP_STATUS == 204 ]];then
    echo "Success for $ticketId"
  else
    # just log the problem but continue
    echo "Updating the ticket $ticketId failed: $LAST_HTTP_STATUS $LAST_RESPONSE_BODY"
  fi
done


