# Environment

Refer to `~/.codex/AGENTS_LOCAL.md` for more machine-specific instructions.

Use `zsh -lc` to run commands. This is a Nix-managed system so installed
programs are in `/etc/profiles/per-user/$USER/bin/`
(e.g. /etc/profiles/per-user/chakenne/bin/rg).

## Using temporary commands

If we need to use a command that is not installed, we can use `nix-shell`
to temporarily install it for use. If it's a command that would be useful to
permenantly install, recommend adding it to the home-manager modules
located in `~/.dotfiles/`.

## Finding nixpkgs

Before suggesting a new nix dependency/package ensure that it actuallty exists
as named. Use `nix search nixpkgs` to find packages in nixpkgs (e.g. `nix search
nixpkgs ripgrep`); this isn't limited to just the nixpkgs channel.

# Development

Never use a `write` feature of gh!

## Pull Requests

The pull request for a corresponding branch can be inspected by running `gh pr
view --json=body,comments,commits,reviews,latestReviews,reviewDecision,reviewRequests`
in a given branch of a repository.

To inspect the full review body (with suggestions) run:

```
gh pr view --json=headRepository,headRepositoryOwner,number \
  | jq '. | "repos/\(.headRepositoryOwner.login)/\(.headRepository.name)/pulls/\(.number)/comments"' \
  | xargs -I {} gh api {} 
```

### Reading issues

If I refer to an issue number, you can assume I'm talking about the repository
I'm in, unless I specify another project. But it will almost certainly be the
same org as the repo of the workspace we're in.

To see the name and org/owner run `gh repo view --json owner,name`

To read an issue by number run
`gh issue view 434 --json title,state,body,comments,labels,milestone,projectItems`.

### Addressing feedback

Use the latest review comments from a PR to figure out what changes need to
be made. They are usually more consequential than the suggestion. So also
review the diff from `${UPSTREAM_HEAD}..${HEAD}` for context.

By default, you should first give your opinion on the suggestions, then offer
to implement the changes.

Even if there is an approval, that approval might have suggestions that we want
to take into consideration. Don't treat an approval as a green light.
