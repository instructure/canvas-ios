// @flow
import httpClient from '../httpClient'
import { exhaust, paginate } from '../utils/pagination'
import {
  API,
  httpCache,
  PageModel,
  CourseModel,
} from '../model-api'
import * as template from '../../__templates__'

jest.mock('../httpClient')
jest.mock('../utils/pagination')

// make flow happy
const mock = (fn: any) => fn

describe('model api', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    httpCache.clear()
  })

  describe('cache-only policy', () => {
    const api = new API({ policy: 'cache-only' })

    it('immediately returns cached data', () => {
      expect(api.get('courses/1/pages/test')).toBe(null)
      const page = template.pageModel()
      httpCache.handle('GET', 'courses/1/pages/test', page)
      expect(api.get('courses/1/pages/test')).toBe(page)
    })

    it('does not hit the network api for GET', () => {
      api.get('courses/1/pages/test')
      expect(httpClient().get).not.toHaveBeenCalled()
    })

    it('still hits the network api for non-GET', () => {
      api.post('/one', {})
      expect(httpClient().post).toHaveBeenCalled()
      api.put('/two', {})
      expect(httpClient().put).toHaveBeenCalled()
      api.delete('/three')
      expect(httpClient().delete).toHaveBeenCalled()
    })
  })

  describe('network-only policy', () => {
    const api = new API({ policy: 'network-only' })

    it('immediately returns cached data', () => {
      expect(api.get('courses/1/pages/test')).toBe(null)
      const page = template.pageModel()
      httpCache.handle('GET', 'courses/1/pages/test', page)
      expect(api.get('courses/1/pages/test')).toBe(page)
    })

    it('hits the network api for cached GET', () => {
      const page = template.pageModel()
      httpCache.handle('GET', 'courses/1/pages/test', page)
      api.get('courses/1/pages/test')
      expect(httpClient().get).toHaveBeenCalledWith(
        'courses/1/pages/test',
        {}
      )
    })

    it('hits the network api for non-GET', () => {
      api.post('/one', {})
      expect(httpClient().post).toHaveBeenCalled()
      api.put('/two', {})
      expect(httpClient().put).toHaveBeenCalled()
      api.delete('/three')
      expect(httpClient().delete).toHaveBeenCalled()
    })
  })

  describe('cache-and-network policy', () => {
    const api = new API({ policy: 'cache-and-network' })

    it('immediately returns cached data', () => {
      expect(api.get('courses/1/pages/test')).toBe(null)
      const page = template.pageModel()
      httpCache.handle('GET', 'courses/1/pages/test', page)
      expect(api.get('courses/1/pages/test')).toBe(page)
    })

    it('does not hit the network api for cached GET', () => {
      const page = template.pageModel()
      httpCache.handle('GET', 'courses/1/pages/test', page)
      api.get('courses/1/pages/test')
      expect(httpClient().get).not.toHaveBeenCalled()
    })

    it('does hit the network api for expired GET', () => {
      const page = template.pageModel()
      httpCache.handle('GET', 'courses/1/pages/test', page, { ttl: -1 })
      api.get('courses/1/pages/test')
      expect(httpClient().get).toHaveBeenCalledWith(
        'courses/1/pages/test',
        {}
      )
    })

    it('hits the network api for non-GET', () => {
      api.post('/one', {})
      expect(httpClient().post).toHaveBeenCalled()
      api.put('/two', {})
      expect(httpClient().put).toHaveBeenCalled()
      api.delete('/three')
      expect(httpClient().delete).toHaveBeenCalled()
    })
  })

  it('exhausts pagination if 99 or more items are requested per page', async () => {
    const api = new API({ policy: 'network-only' })
    mock(exhaust).mockImplementation(() => Promise.resolve())
    api.get('/stars', { params: { per_page: 99 } })
    expect(exhaust).toHaveBeenCalled()
  })

  it('calls the listeners during the request lifecycle', async () => {
    const api = new API({
      policy: 'network-only',
      onStart: jest.fn(),
      onError: jest.fn(),
      onComplete: jest.fn(),
    })
    mock(httpClient().delete).mockImplementation(() => Promise.reject())
    const request = api.delete('/')
    expect(api.options.onStart).toHaveBeenCalled()
    await request.catch(() => {})
    expect(api.options.onError).toHaveBeenCalled()
    expect(api.options.onComplete).toHaveBeenCalled()
  })

  it('removes listeners when it cleans up', () => {
    const api = new API({
      policy: 'network-only',
      onStart: jest.fn(),
      onError: jest.fn(),
      onComplete: jest.fn(),
    })
    api.cleanup()
    expect(api.options.onStart).toBeUndefined()
    expect(api.options.onError).toBeUndefined()
    expect(api.options.onComplete).toBeUndefined()
  })

  describe('courses', () => {
    const api = new API({ policy: 'network-only' })

    it('can getCourseColor', () => {
      expect(api.getCourseColor('2')).toBe('#aaa')
      httpCache.handle('GET', 'users/self/colors', {
        custom_colors: { course_1: 'green' },
      })
      expect(api.getCourseColor('1')).toBe('green')
      expect(httpClient().get).toHaveBeenCalledWith(
        'users/self/colors',
        {}
      )
    })

    it('can getCourse', () => {
      expect(api.getCourse('1')).toBe(null)
      expect(httpClient().get).toHaveBeenCalledWith(
        'courses/1',
        {
          params: {
            include: [ 'permissions', 'term', 'favorites', 'course_image', 'sections' ],
          },
          transform: expect.any(Function),
        }
      )
      const { transform } = mock(httpClient().get).mock.calls[0][1]
      expect(transform(template.course())).toEqual(
        new CourseModel(template.course())
      )
    })
  })

  describe('pages', () => {
    const api = new API({ policy: 'network-only' })

    it('can getPages', () => {
      expect(api.getPages('courses', '1')).toEqual([])
      expect(paginate).toHaveBeenCalledWith(
        'courses/1/pages',
        {
          params: { per_page: 99 },
          transform: expect.any(Function),
        }
      )
      const args = mock(paginate).mock.calls[0]
      const result = args[1].transform([
        template.page({ title: 'syllabus' }),
        template.page({ title: 'another' }),
        template.page({ title: 'Front', front_page: true }),
      ])
      expect(result).toEqual([
        new PageModel(template.page({ title: 'Front', front_page: true })),
        new PageModel(template.page({ title: 'another' })),
        new PageModel(template.page({ title: 'syllabus' })),
      ])
      expect(args[1].transform([
        template.page({ title: 'Front', front_page: true }),
        template.page({ title: 'another' }),
      ])).toEqual([
        new PageModel(template.page({ title: 'Front', front_page: true })),
        new PageModel(template.page({ title: 'another' })),
      ])
    })

    it('can createPage', () => {
      const page = {
        title: 'Page 1',
        body: 'body',
        editing_roles: 'teachers',
        published: true,
        front_page: false,
      }
      const promise = api.createPage('courses', '1', page)
      expect(promise).toBeInstanceOf(Promise)
      expect(httpClient().post).toHaveBeenCalledWith(
        'courses/1/pages',
        { wiki_page: page },
        { transform: expect.any(Function) }
      )
      const { transform } = mock(httpClient().post).mock.calls[0][2]
      expect(transform(template.page())).toEqual(
        new PageModel(template.page())
      )
    })

    it('can getPage', () => {
      api.getPage('courses', '1', 'home')
      expect(httpClient().get).toHaveBeenCalledWith(
        'courses/1/pages/home',
        { transform: expect.any(Function) }
      )
      const { transform } = mock(httpClient().get).mock.calls[0][1]
      expect(transform(template.page())).toEqual(
        new PageModel(template.page())
      )
    })

    it('can updatePage', () => {
      const page = {
        title: 'Page 1',
        body: 'body',
        editing_roles: 'teachers',
        published: true,
        front_page: false,
      }
      const promise = api.updatePage('courses', '1', 'test', page)
      expect(promise).toBeInstanceOf(Promise)
      expect(httpClient().put).toHaveBeenCalledWith(
        'courses/1/pages/test',
        { wiki_page: page },
        { transform: expect.any(Function) }
      )
      const { transform } = mock(httpClient().put).mock.calls[0][2]
      expect(transform(template.page())).toEqual(
        new PageModel(template.page())
      )
    })

    it('can deletePage', () => {
      const promise = api.deletePage('courses', '1', 'test')
      expect(promise).toBeInstanceOf(Promise)
      expect(httpClient().delete).toHaveBeenCalledWith(
        'courses/1/pages/test',
        {}
      )
    })
  })
})
