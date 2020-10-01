//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow
export * from './fetch-props-for'
export * from './model'
export { httpCache } from './httpClient'

import httpClient, { httpCache } from './httpClient'
import parseLink from './utils/parse-link-header'
import {
  CourseModel,
  ToDoModel,
} from './model'

type ApiPolicy = 'cache-only' | 'cache-and-network' | 'network-only'
type ApiOptions = {|
  policy: ApiPolicy,
  onStart?: ApiPromise<any> => void,
  onComplete?: ApiPromise<any> => void,
  onAnyComplete?: ApiPromise<any> => void,
  onError?: Error => void,
|}
type Paginated<T> = {|
  list: T,
  next: ?string,
  getNextPage: ?(() => ApiPromise<Paginated<T>>),
|}

const emptyArray = []
const emptyPaginated: Paginated<any> = {
  list: emptyArray,
  next: null,
  getNextPage: null,
}

export class API {
  options: ApiOptions

  constructor (options: ApiOptions) {
    this.options = options
  }

  cleanup () {
    this.options.onStart =
    this.options.onComplete =
    this.options.onAnyComplete =
    this.options.onError = undefined
  }

  get (url: string, config: ApiConfig = {}) {
    const { policy } = this.options
    const cached = httpCache.get(url, config)
    if (
      policy === 'network-only' ||
      (policy === 'cache-and-network' && cached.expiresAt < Date.now())
    ) {
      this.request(httpClient.get(url, config))
    }
    return cached.value || null
  }

  paginate<T> (url: string, config: ApiConfig = {}): Paginated<T> {
    const transform = config.transform
    config.transform = (value: any, response: ApiResponse<any>) => {
      const list = transform ? transform(value, response) : value
      const { current, first, next } = parseLink(response.headers.link) || {}
      const getNextPage = next && (() => {
        this.request(httpClient.get(next, config))
      })
      if (getNextPage && config.params && config.params.per_page >= 100) {
        getNextPage() // automatically request all pages
      }
      if (current && current !== first) {
        const base = httpCache.get(url, config).value
        if (base) {
          base.list = base.list.concat(list)
          base.next = next
          base.getNextPage = getNextPage
        }
        return null
      }
      return {
        list,
        next,
        getNextPage,
      }
    }

    const cached = httpCache.get(url, config)
    const { policy } = this.options
    if (
      policy === 'network-only' ||
      (policy === 'cache-and-network' && cached.expiresAt < Date.now())
    ) {
      this.request(httpClient.get(url, config))
    }
    // getNextPage won't survive serialization
    const value = cached.value
    if (value && value.next && !value.getNextPage && policy !== 'cache-only') {
      value.getNextPage = () => this.request(httpClient.get(value.next, config))
    }
    return value || emptyPaginated
  }

  post (url: string, data: *, config: ApiConfig = {}) {
    return this.request(httpClient.post(url, data, config))
  }

  put (url: string, data: *, config: ApiConfig = {}) {
    return this.request(httpClient.put(url, data, config))
  }

  delete (url: string, config: ApiConfig = {}) {
    return this.request(httpClient.delete(url, config))
  }

  request (promise: ApiPromise<any>) {
    const { onStart, onComplete, onError } = this.options
    onStart && onStart(promise)
    promise
      .catch(error => { onError && onError(error) })
      .then(() => { onComplete && onComplete(promise) })
    return promise
  }

  getCourseColor (courseID: string): string {
    const json: ?Object = this.get('users/self/colors')
    return json && json.custom_colors[`course_${courseID}`] || '#aaa'
  }

  getCourse (courseID: string): ?CourseModel {
    return this.get(`courses/${courseID}`, {
      params: {
        include: [ 'permissions', 'term', 'favorites', 'course_image', 'sections' ],
      },
      transform: (course: Course) => new CourseModel(course),
    })
  }

  getToDos (): Paginated<ToDoModel[]> {
    return this.paginate('users/self/todo', {
      transform: (todos: ToDoItem[]) => todos.map(todo => new ToDoModel(todo)),
    })
  }
}
