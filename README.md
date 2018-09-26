## Cloning the repo

First install [https://git-lfs.github.com](https://git-lfs.github.com).

- `brew install git-lfs`
- `git lfs install`
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

The way recording and replay works is through `VCR.swift` in the `SoSeedySwift` framework. When tests are run, part of the setup process for the test case is to find the coorresponding cassette file, stored in `ios-private` that has all of the request/responses made for that test case.

In order to run the recording/replay locally, there are a few steps you need to take.
- Go into StudentUITest.swift and set find the `shouldUseVCR` variable and set it to true.
- If you want to record new mocks update `VCR.shared.record` to be true
 - After the test run, you can look for a log output prefixed by `Cassette Directory`. You will then need to copy all of the json files in that directory to `ios-private/cassettes`
- If you want to use mocks update `VCR.shared.record` to be false and ensure that you have the ios-private submodule checked out.

There are some recorded requests that show up with a key of `{}`. This is due to some of the data seeding requests not serializing to JSON with parameters. It's possible that the request has no parameters. This is something we will want to determine and fix so that asynchronous data seeding calls don't break.

## Linking frameworks

