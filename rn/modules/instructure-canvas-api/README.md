# instructure-canvas-api

This module contains methods to make authenticated api calls to Canvas. All api calls return a promise that resolves to an AxiosResponse.

To use `instructure-canvas-api` you must have a session that you inform `instructure-canvas-api` about. Which is then used to make authenticated api calls.

    import { setSession } from 'instructure-canvas-api'

    setSession({
      authToken: string,
      baseURL: string,
      user: {
        primary_email: string,
        id: string,
        avatar_url: string,
        name: string,
      }
    })

Later if you ever wanted to get the session you can do so using the `getSession` method.

    import { getSession } from 'instructure-canvas-api'

    let session = getSession()

The default export of instructure-canvas-api contains all of the api calls that instructure-canvas-api contains

    import canvasApi from 'instructure-canvas-api'

    canvasApi.refreshCourses()

Each of these api calls are also exported as named exports

    import { refreshCourses } from 'instructure-canvas-api'

    refreshCourses()

If you need a little more flexibility you can also import the underlying `httpClient` that is used to make authenticated api calls to canvas.

    import { httpClient } from 'instructure-canvas-api'

    let client = httpClient()

The client in this case is an axios istance that has been set up to use the auth token set in the session.

There are some utility functions that are exposed for use if needed.

    import { parseNext, paginate, exhaust } from 'instructure-canvas-api/utils/pagination'
    import { parseLinkHeader } from 'instructure-canvas-api/utils/parse-link-header'
    import { apiResponse, apiError } from 'instructure-anvas-api/utils/testHelpers'

`instructure-canvas-api` comes with a default mock for jest so it's simple to mock.

    jest.mock('instructure-canvas-api')


### Development
If you want to work on `instructure-canvas-api` while seeing those changes in another app.

 - Make sure that you have the latest watchman. Can be updated through `brew`
 - Run `yarn link` in the `instructure-canvas-api` directory
 - run `yarn link instructure-canvas-api` in the project root of the app you are working on
 - run `yarn start`


At this point you should see the packager start and under the list of watched directorys it should show both your project root as well as the `modules/instructure-canvas-api` directory.

`instructure-canvas-api` has flow and jest tests setup

    yarn flow
    yarn test

### Publishing

Publish to npm with `gulp publish` after updating the version in `package.json`