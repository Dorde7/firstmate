# shellcheck shell=bash
# Resolve and verify the mirror's local landing branch for local-only tasks.
# Usage: . bin/fm-local-default-branch-lib.sh

fm_is_local_only_task() { # <task-mode>
  [ "$1" = local-only ]
}

fm_resolve_local_landing_branch() { # <project-primary>
  local primary=$1 branch
  # The mirror's own checked-out branch is the landing branch; origin may be a live checkout.
  branch=$(git -C "$primary" symbolic-ref --quiet --short HEAD 2>/dev/null) || {
    echo "error: $primary is not on a branch; check out the mirror's landing branch before spawning" >&2
    return 1
  }
  case "$branch" in
    fm/*)
      echo "error: $primary is on task branch '$branch', not a landing branch; check out the mirror's landing branch before spawning" >&2
      return 1
      ;;
  esac
  git -C "$primary" show-ref --verify --quiet "refs/heads/$branch" || {
    echo "error: $primary is on unborn branch '$branch'; commit to the mirror's landing branch before spawning" >&2
    return 1
  }
  printf '%s\n' "$branch"
}

fm_local_landing_branch() { # <project-primary> <recorded-landing-branch>
  local primary=$1 branch=$2 current
  # Tasks recorded before landing_branch= existed resolve it from the checkout.
  if [ -z "$branch" ]; then
    branch=$(fm_resolve_local_landing_branch "$primary") || return 1
  fi
  current=$(git -C "$primary" symbolic-ref --quiet --short HEAD 2>/dev/null || true)
  if [ "$current" != "$branch" ]; then
    echo "error: $primary is on '${current:-detached HEAD}', but this task lands on '$branch'; check out '$branch' in the mirror" >&2
    return 1
  fi
  printf '%s\n' "$branch"
}
