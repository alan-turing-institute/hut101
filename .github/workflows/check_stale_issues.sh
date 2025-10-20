#! /usr/bin/env bash

set -e

echo "Checking for stale issues."

# List of issues from https://github.com/orgs/alan-turing-institute/projects/319/views/1
ALL_PROJECT_ISSUES=($(gh project item-list 319 --owner alan-turing-institute --format json --jq '.items[].content.url'))

EXPECTED_PREFIX="https://github.com/alan-turing-institute/hut101/issues/"
for ISSUE_URL in "${ALL_PROJECT_ISSUES[@]}"; do
    if [[ "$ISSUE_URL" != ${EXPECTED_PREFIX}* ]]; then
        echo "Skipping URL $ISSUE_URL as it is not an issue on the alan-turing-institute/hut101 repository."
        continue
    fi
    if [[ "$(gh issue view "$ISSUE_URL" --json state --jq '.state')" == "CLOSED" ]]; then
        echo "Skipping URL $ISSUE_URL as it is already closed."
        continue
    fi

    ISSUE_NUMBER="${url##*/}"

    # Fetch the top comment for the issue
    ISSUE_BODY=$(gh issue view "$ISSUE_URL" --json body --jq '.body')
    # Get the original GitHub issue
    ORIGINAL_GITHUB_ISSUE=$(grep -Eo '^https://github.com/.*/issues/[0-9]+$' <<< "${ISSUE_BODY}" | head -n 1)
    if [[ -z "$ORIGINAL_GITHUB_ISSUE" ]]; then
        echo "No original GitHub issue found in issue $ISSUE_URL. Skipping."
        continue
    fi

    # Get the original submitter's username
    COACH=$(gh issue view "$ISSUE_URL" --json author --jq '.author.login')
    if [[ -z "$COACH" ]]; then
        echo "No coach found in issue $ISSUE_URL. Skipping."
        continue
    fi

    # Check the original GitHub issue to see if it's been closed
    ORIGINAL_STATE=$(gh issue view "$ORIGINAL_GITHUB_ISSUE" --json state --jq '.state')
    if [[ "$ORIGINAL_STATE" == "OPEN" ]]; then
        echo "Original issue $ORIGINAL_GITHUB_ISSUE (@${COACH}) is still open. No action needed."
        continue
    elif [[ "$ORIGINAL_STATE" == "CLOSED" ]]; then
        echo "Original issue ${ORIGINAL_GITHUB_ISSUE} is closed. Notifying coach ${COACH}."

        COMMENT_BODY="Hello ${COACH}! This is an automated notification. I noticed that the [original issue](${ORIGINAL_GITHUB_ISSUE}) has been closed. Thus, I'm also closing this issue on the hut101 repository. If you believe this is a mistake, please ping a repository maintainer."
        gh issue comment "$ISSUE_URL" --body "$COMMENT_BODY"
        gh issue close "$ISSUE_URL"
    else
        echo "Got state '${ORIGINAL_STATE}' for issue ${ORIGINAL_GITHUB_ISSUE}. Not sure what to do about this, so skipping."
    fi 
done
