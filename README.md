# Introduction

This action sets the fix version on one or more jira tickets.

# Inputs

* url: the jira base url, e.g. https://jiratest.freenet-group.de
* token: an api token. See https://confluence.atlassian.com/enterprise/using-personal-access-tokens-1026032365.html
* version: the version string to be set
* tickets: a comma-separated list of jira ticket ids

# Development

On linux if all required commands are installed:
```shell
INPUT_URL=https://jiratest.freenet-group.de INPUT_TOKEN=XXX INPUT_PROJECT=OMS INPUT_VERSION=1.2.3 INPUT_TICKETS=OMS-12345 ./jira_set_version.sh
```

With the docker image:
```shell
docker build -t jira-set-version .
```
```shell
docker run -e INPUT_URL=https://jiratest.freenet-group.de -e INPUT_TOKEN=XXX -e INPUT_PROJECT=OMS -e INPUT_VERSION=1.2.3 -e INPUT_TICKETS=OMS-12345 jira-set-version
```
