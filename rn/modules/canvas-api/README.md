# canvas-api

This module contains methods to make authenticated api calls to Canvas. All api calls return a promise that resolves to an AxiosResponse.

To use `canvas-api` you must have a session that you inform `canvas-api` about. Which is then used to make authenticated api calls.

    import { setSession } from 'canvas-api'

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

    import { getSession } from 'canvas-api'

    let session = getSession()

The default export of canvas-api contains all of the api calls that canvas-api contains

    import canvasApi from 'canvas-api'

    canvasApi.refreshCourses()

Each of these api calls are also exported as named exports

    import { refreshCourses } from 'canvas-api'

    refreshCourses()

If you need a little more flexibility you can also import the underlying `httpClient` that is used to make authenticated api calls to canvas.

    import { httpClient } from 'canvas-api'

    let client = httpClient()

The client in this case is an axios istance that has been set up to use the auth token set in the session.

There are some utility functions that are exposed for use if needed.

    import { parseNext, paginate, exhaust } from 'canvas-api/utils/pagination'
    import { parseLinkHeader } from 'canvas-api/utils/parse-link-header'
    import { apiResponse, apiError } from 'canvas-api/utils/testHelpers'

`canvas-api` comes with a default mock for jest so it's simple to mock.

    jest.mock('canvas-api')


### Development
If you want to work on `canvas-api` while seeing those changes in another app.

 - Make sure that you have the latest watchman. Can be updated through `brew`
 - Run `yarn link` in the `canvas-api` directory
 - run `yarn link canvas-api` in the project root of the app you are working on
 - run `yarn start`


At this point you should see the packager start and under the list of watched directorys it should show both your project root as well as the `modules/canvas-api` directory.

`canvas-api` has flow and jest tests setup

    yarn flow
    yarn test