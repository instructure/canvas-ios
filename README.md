## Canvas App by Instructure

### Apps
- Student
- Parent
- Teacher

### Commit Message Format
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

### How to connect to a local canvas instance
- Modify the contents of preload-account-info.plist (it's at the root of the repo)
  * See How To Generate a Developer Key section below
  * `client_id` is the `ID` of a generated Developer Key
  * `client_secret` is the `Key` of the generated Developer Key
- Build and run the app locally
- On the login page, your local canvas instance will appear in the top left corner of the screen

### How to Generate a Developer Key
- Visit `web.canvas.docker/accounts/self/developer_keys` (replace `web.canvas.docker`
with your local instance
- Click `+ Developer Key`
- Give it a name and the following fields:
  * `Redirect URI (Legacy)`: `https://canvas/login`
  * `Redirect URIs` (separated by new lines):
    - https://canvas/login
    - canvas-courses://canvas/login
    - canvas-teacher://canvas/login
    - canvas-parent://canvas/login
