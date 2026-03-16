Review the current branch against a base branch. Usage: /review-branch [base-branch] (defaults to `master`)

The base branch is: $ARGUMENTS (use `master` if empty)

Run these read-only git commands to gather context:

```bash
git rev-parse --abbrev-ref HEAD
git log <base>...HEAD --oneline
git diff <base>...HEAD --name-status
git diff <base>...HEAD
```

If more than 100 files changed, list them grouped by top-level module (Student/, Core/, Horizon/, Teacher/, Parent/) and ask which modules to focus on before proceeding.

Please review this diff and provide feedback. Use CLAUDE.md files in this repository for guidance on style, architecture, and conventions. Be constructive and helpful.

Review focus areas:
- Code quality and best practices
- Potential bugs or issues
- Performance considerations
- Security concerns
- Test coverage
