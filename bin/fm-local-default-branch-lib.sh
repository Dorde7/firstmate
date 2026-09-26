# shellcheck shell=bash
# Resolve the mirror's local landing branch for local-only tasks.
# Usage: . bin/fm-local-default-branch-lib.sh

fm_is_local_only_task() { # <task-mode>
  [ "$1" = local-only ]
}

fm_local_default_branch() { # <project-primary>
  local primary=$1 branch
  # The mirror's own checked-out branch is the landing branch; origin may be a live checkout.
  branch=$(git -C "$primary" symbolic-ref --quiet --short HEAD 2>/dev/null) || return 1
  git -C "$primary" show-ref --verify --quiet "refs/heads/$branch" || return 1
  printf '%s\n' "$branch"
}
