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

### Network request recording/replay in UI automation
For UI automation we record network requests as well as data seeding calls. This will help make our tests run faster as well as be more stable as we are less likely to break due to changes in canvas.

The way recording and replay works is through `VCR.m` in the `SoSeedy` framework. When tests are run, part of the setup process for the test case is to go out to a storage service (tbd) and retrieve a file that contains all of the network and data seeding requests that are made during that test.

On the JS side of react native, we stub out XMLHttpRequest and when we perform a network request we ask `VCR.m` for the recorded response for the request. on data seeding we have a function in `SoSeedy.swift` called `recorded` that is used to wrap a call to the data seeding api.

In order to run the recording/replay locally, there are a few steps you need to take.
- Download minio
  - `brew install minio/stable/minio`
  - `minio server /tmp/data`
  - Log in to the minio UI using `minio` `miniostorage` as the access key and secret key
  - Create a bucket called `cassettes`
  - Click on the kabob next to the cassettes bucket and click `Edit policy`
  - Make the policy `Read and Write` with a prefix of `*`
- Go into `VCR.m` and comment out the first line in
  `- (void)recordCassette:(NSString *)testCase completionHandler:(void (^)(NSError *error))completionHandler`
- Do a test run and you should see recording files show up in `/tmp/data`
- Change the `record` variable in `VCR.m` in the `init` method to `NO`
- Do a test run and it should pull from the recorded files

There are some recorded requests that show up with a key of `{}`. This is due to some of the data seeding requests not serializing to JSON with parameters. It's possible that the request has no parameters. This is something we will want to determine and fix so that asynchronous data seeding calls don't break.

