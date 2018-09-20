## Cloning the repo

- `git clone --recursive git@github.com:instructure/ios.git`

Update the submodules with

- `git submodule update --recursive --init`

## Guiding Principles

### Simple

Writing an app is complex. Decisions made from the beginning have a big impact on the end result.

We strive to maintain a simple architecture that is easy to understand and pick up. Someone familiar with the platform should be productive within a single day.

Code should be self-documenting and easy to follow.

```
Ugly code is easy to recognize and its cost is easy to estimate. Neither is true for a wrong abstraction.
- Dan Abramov
```

### Easy to Debug

Surprise! Apps have bugs. Industry average is 15-50 defects per 1000 lines of code.

We build our apps in a way that makes finding and fixing issues is as easy as possible.

### Testable

Writing code in a testable way is paramount for long term success. These apps are built in a way that makes our unit testing surface as large as possible.

### Conventions

We make and keep strong conventions in order to reduce mental overhead.

[Conventions](./CONVENTIONS.md) and [Architecture](./ARCHITECTURE.md).

### No Tricky Stuff

We do things the Apple prescribed way because it offers the best long term predictability with minimal maintenance.

### Fat Model, Thin Controller

Models handle as much of the business logic as possible. This allows a wide unit testing surface. View Controllers should be as small as possible.

### Predictable

By scrutinizing each dependency we bring in, the code we write is our responsibilty. Unit tests are a key portion of the code we write, so as time passes, the code that worked 2 years ago still works today.

### Automation

We don't do any manual QA of our products. We write code that tests our apps for us.

## Using the Canvas Apps

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
- To adjust how the tests are run check out `StudentUITest.swift`

There are some recorded requests that show up with a key of `{}`. This is due to some of the data seeding requests not serializing to JSON with parameters. It's possible that the request has no parameters. This is something we will want to determine and fix so that asynchronous data seeding calls don't break.

## Linking frameworks

