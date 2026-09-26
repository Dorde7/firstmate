# shellcheck shell=bash
# Resolve the mirror's local landing branch for registered local-only tasks.
# Usage: . bin/fm-local-default-branch-lib.sh (after FM_ROOT and FM_HOME are set).

fm_is_local_only_project_task() { # <project-primary> <task-mode>
  local project=$1 mode=$2 posture
  [ "$mode" = local-only ] || return 1
  posture=$(FM_HOME="$FM_HOME" "$FM_ROOT/bin/fm-project-mode.sh" --raw "$(basename "$project")" 2>/dev/null) || return 1
  [ "${posture%% *}" = local-only ]
}

fm_local_default_branch() { # <project-worktree>
  local worktree=$1 branch ref
  for branch in main master; do
    if git -C "$worktree" show-ref --verify --quiet "refs/heads/$branch"; then
      printf '%s\n' "$branch"
      return 0
    fi
  done
  # A custom landing branch remains usable when the mirror has no main/master.
  # The remote HEAD is only a hint here; it must name a branch local to the mirror.
  ref=$(git -C "$worktree" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
  branch=${ref#origin/}
  if [ -n "$ref" ] && git -C "$worktree" show-ref --verify --quiet "refs/heads/$branch"; then
    printf '%s\n' "$branch"
    return 0
  fi
  return 1
}
