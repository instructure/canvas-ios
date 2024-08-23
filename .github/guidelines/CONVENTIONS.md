## Commit Message Format
We use a standard commit message format.

The first commit for any pull request must have the following:

- Title
- Reference to a Jira ticket, or multiple Jira tickets
- List of apps that are affected by the change
- Release note
- Test plan

Example:

```
This is the commit title

refs: MBL-10000
affects: Student, Teacher
release note: Fixed an issue that prevented users from launching the app.
test plan:
- Launch app
- It should not crash
```

You can add subseqent commits that will be squashed upon merge. However, if any of the required fields are missing from the first commit, you will need to amend it. Otherwise, Danger will reject the pull request and you will feel sad.

If some of the required fields don't apply, you can use the token `none`.

For example:

```
This is the commit title

refs: none
affects: none
release note: none
test plan:
- The added script will output all the names of the presidents of the united states
```

In rare cases, you can skip commit linting entirely. Don't do this.

Example:

```
This is my commit title

[ignore-commit-lint]
```