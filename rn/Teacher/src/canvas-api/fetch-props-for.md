# Model API and fetchPropsFor

The model api and fetchPropsFor higher-order component are meant to simplify the fetching of api data for use in a component. It should also hopefully make the transition to GraphQL fairly straightforward.

### fetchPropsFor (Component, (Props, API) => AddedProps)

Basic use example:

```js
import { fetchPropsFor } from '../../canvas-api/model-api'

// ...

export default fetchPropsFor(Component, ({ courseID }, api) => ({
  courseColor: api.getCourseColor(courseID),
  courseName: (api.getCourse(courseID) || {}).name,
}))
```

The returned component receives props including `courseID`, and then passes all the props plus `courseColor` and `courseName` as fetched from the api. It will also pass the following props to Component:

```js
type FetchProps = {
  api: API, // instance of the api for "save" related calls
  isLoading: boolean, // are some requests from HOC function still in flight?
  isSaving: boolean, // are some requests from save `api` prop still in flight?
  loadError: ?Error, // what went wrong from api calls in HOC function
  saveError: ?Error, // what went wrong from save `api` prop calls
  refresh: () => void, // refetch everything in the HOC function from server
}
```

#### Initial component construction `cache-and-network`

The function passed to the HOC is called immediately with an api instance that will consult the cache first, and only request from the network if expired or missing from the cache.

#### HOC loop `cache-only`

As requests complete, the query function passed to the HOC is called again and again with an api instance that will only consult the cache, and not initiate new network requests.

#### Refresh `network-only`

If the `refresh` prop is called, the query function passed to HOC is called with an api instance that will return what's in the cache, but also make a network request, even if the cache entry has not expired.

#### Save `api` prop `network-only`

When you call methods on the `api` prop passed to the component, it will always hit the network. Methods that `PUT`, `POST`, or `DELETE` should always return a promise instead of dealing with synchronously cache data. `GET` calls should nearly always be done in the query function.

#### Pagination

Paginated api methods (most lists) should return the `Paginated` type:

```js
type Paginated<T> = {|
  list: T,
  next: ?string,
  getNextPage: ?(() => ApiPromise<Paginated<T>>),
|}

{
  getPages (): Paginated<CourseModel[]> {}
}
```

If the request params include `per_page` of `99` or greater, then the `getNextPage` function will be automatically called as each page returns, so your component will incrementally receive the full `list`.
