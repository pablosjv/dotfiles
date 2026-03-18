#!/usr/bin/env bash

function glab-stale() {
    local DEFAULT_CUTOFF
    DEFAULT_CUTOFF="$(date -u -v-90d +%Y-%m-%dT%H:%M:%SZ)" # 90 days ago
    local CUTOFF="${1:-$DEFAULT_CUTOFF}"
    echo "Checking for stale branches (cutoff: $CUTOFF)..." >&2
    glab api "projects/:id/repository/branches?per_page=100" --paginate |
        jq -s --arg cutoff "$CUTOFF" '
            [
                .[][]
                | select(
                    (.name | test("^(main|master|develop|dev)$") | not) and
                    (.commit.committed_date < $cutoff)
                )
                | {
                    name,
                    merged,
                    protected,
                    last_commit_date: .commit.committed_date
                }
            ]
        '
}

function glab-delete-stale() {
    local DEFAULT_CUTOFF
    DEFAULT_CUTOFF="$(date -u -v-90d +%Y-%m-%dT%H:%M:%SZ)" # 90 days ago
    local CUTOFF="${1:-$DEFAULT_CUTOFF}"
    for branch in $(glab-stale $CUTOFF | jq -r '.[] | .name'); do
        info "Deleting stale branch: $branch"
        if git push origin --delete $branch; then
            success "Deleted stale branch: $branch"
        else
            warning "Failed to delete stale branch: $branch"
        fi
    done
}

function glab-stale-mr() {
    local DEFAULT_CUTOFF
    DEFAULT_CUTOFF="$(date -u -v-90d +%Y-%m-%dT%H:%M:%SZ)" # 90 days ago
    local CUTOFF="${1:-$DEFAULT_CUTOFF}"
    echo "Checking for stale merge requests (cutoff: $CUTOFF)..." >&2
    glab api "projects/:id/merge_requests?state=opened&per_page=100" --paginate |
        jq -s --arg cutoff "$CUTOFF" '
  [
    .[][]
    | select(.updated_at < $cutoff)
    | {
        iid,
        title,
        state,
        updated_at,
        web_url,
        source_branch,
        target_branch,
        author: {
          id: .author.id,
          username: .author.username,
          name: .author.name
        }
      }
  ]
'
}

function glab-delete-stale-mr() {
    local DEFAULT_CUTOFF
    DEFAULT_CUTOFF="$(date -u -v-90d +%Y-%m-%dT%H:%M:%SZ)" # 90 days ago
    local CUTOFF="${1:-$DEFAULT_CUTOFF}"
    for mr in $(glab-stale-mr $CUTOFF | jq -r '.[] | .iid'); do
        info "Deleting stale merge request: $mr"
        if glab mr delete $mr; then
            success "Deleted stale merge request: $mr"
        else
            warning "Failed to delete stale merge request: $mr"
        fi
    done
}
