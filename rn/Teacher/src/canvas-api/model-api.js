// @flow
export * from './fetch-props-for'
export * from './model'
export { httpCache } from './httpClient'

import localeCompare from '../utils/locale-sort'
import httpClient, { httpCache } from './httpClient'
import { paginate, exhaust } from './utils/pagination'
import {
  CourseModel,
  PageModel,
} from './model'

type ApiPolicy = 'cache-only' | 'cache-and-network' | 'network-only'
type ApiOptions = {|
  policy: ApiPolicy,
  onStart?: ApiPromise<any> => void,
  onComplete?: ApiPromise<any> => void,
  onAnyComplete?: ApiPromise<any> => void,
  onError?: Error => void,
|}

const emptyArray = []

export class API {
  static cache: Object = {}

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
      this.request((config.params && config.params.per_page >= 99)
        ? exhaust(paginate(url, config))
        : httpClient().get(url, config)
      )
    }
    return cached.value || null
  }

  post (url: string, data: *, config: ApiConfig = {}) {
    return this.request(httpClient().post(url, data, config))
  }

  put (url: string, data: *, config: ApiConfig = {}) {
    return this.request(httpClient().put(url, data, config))
  }

  delete (url: string, config: ApiConfig = {}) {
    return this.request(httpClient().delete(url, config))
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

  getPages (context: CanvasContext, contextID: string): PageModel[] {
    return this.get(`${context}/${contextID}/pages`, {
      params: {
        per_page: 99,
      },
      transform: (pages: Page[]) => pages.map(page => new PageModel(page))
        .sort((a, b) => {
          if (a.isFrontPage) return -1
          if (b.isFrontPage) return 1
          return localeCompare(a.title, b.title)
        }),
    }) || emptyArray
  }

  createPage (context: CanvasContext, contextID: string, parameters: PageParameters): ApiPromise<PageModel> {
    return this.post(`${context}/${contextID}/pages`, { wiki_page: parameters }, {
      transform: (page: Page) => new PageModel(page),
    })
  }

  getPage (context: CanvasContext, contextID: string, url: string): ?PageModel {
    return this.get(`${context}/${contextID}/pages/${url}`, {
      transform: (page: Page) => new PageModel(page),
    })
  }

  getFrontPage (contextID: string): ?PageModel {
    return this.get(`courses/${contextID}/front_page`, {
      transform: (page: Page) => new PageModel(page),
    })
  }

  updatePage (context: CanvasContext, contextID: string, url: string, parameters: PageParameters): ApiPromise<PageModel> {
    return this.put(`${context}/${contextID}/pages/${url}`, { wiki_page: parameters }, {
      transform: (page: Page) => new PageModel(page),
    })
  }

  deletePage (context: CanvasContext, contextID: string, url: string): ApiPromise<null> {
    return this.delete(`${context}/${contextID}/pages/${url}`)
  }
}
