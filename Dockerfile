FROM alpine:latest
RUN apk update && \
  apk add bash curl

COPY jira_set_version.sh /jira_set_version.sh

ENTRYPOINT ["/jira_set_version.sh"]