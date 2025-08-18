## Commit Message Format
We use a standard commit message format.

A commit in the pull request's branch must have the following when creating a new pull request:

- `refs:` Reference to a Jira ticket, or multiple Jira tickets separated by a comma.
- `builds:` List of apps that should be tested during reviewing the PR and should be built by the CI. For example: you added a new feature to the Student app but you refactored shared code that is also used by the teacher app. This refactoring is not user facing, but can break features in the teacher app.
- `affects:` List of apps that have user facing changes. This field is used to generate release notes when releasing a new version.
- `release note:` The user facing release note that will be visible in the app store's `What's New` section.

Example:

```
Added new feature module.

refs: MBL-10000
builds: Student, Teacher
affects: Student
release note: Introduced a new screen to check your grades.
test plan:
- Launch app
- Test the new screen.
```

You can add subsequent commits with the same template that will overwrite any previous commits' template. This way you can modify these fields during development and only the last value of each field will be validated. If any of the required fields are missing when creating the pull request, you will need to add a new commit with the template or amend your last commit. Otherwise, Danger will reject the pull request.

If some of the required fields don't apply, you can use the token `none`.

For example:

```
This is the commit title

refs: none
affects: none
release note: none
test plan:
- The added script will output all the names of the presidents of the United States
```

In rare cases, you can skip commit linting entirely. Don't do this.

Example:

```
This is my commit title

[ignore-commit-lint]
```