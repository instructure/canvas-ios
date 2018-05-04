//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @flow
import httpClient from '../httpClient'
import {
  API,
  httpCache,
  CourseModel,
  PageModel,
  ToDoModel,
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

    it('will not try to rehydrate getNextPage for pagination', () => {
      httpCache.handle('GET', 'users/self/todo', {
        list: [],
        next: 'users/self/todo?page=bookmark:asdf',
      })
      expect(api.paginate('users/self/todo')).toEqual({
        list: [],
        next: 'users/self/todo?page=bookmark:asdf',
      })
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

    it('will rehydrate getNextPage for pagination', () => {
      httpCache.handle('GET', 'users/self/todo', {
        list: [],
        next: 'users/self/todo?page=bookmark:asdf',
      })
      const result = api.paginate('users/self/todo')
      expect(result).toEqual({
        list: [],
        next: 'users/self/todo?page=bookmark:asdf',
        getNextPage: expect.any(Function),
      })
      result.getNextPage()
      expect(httpClient().get).toHaveBeenCalledWith(
        'users/self/todo?page=bookmark:asdf',
        { transform: expect.any(Function) }
      )
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
      httpCache.handle('GET', 'users/self/todo', { list: [] }, { ttl: -1 })
      api.paginate('users/self/todo')
      expect(httpClient().get).toHaveBeenCalledWith(
        'users/self/todo',
        { transform: expect.any(Function) }
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

    it('will rehydrate getNextPage for pagination', () => {
      httpCache.handle('GET', 'users/self/todo', {
        list: [],
        next: 'users/self/todo?page=bookmark:asdf',
      })
      const result = api.paginate('users/self/todo')
      expect(result).toEqual({
        list: [],
        next: 'users/self/todo?page=bookmark:asdf',
        getNextPage: expect.any(Function),
      })
      result.getNextPage()
      expect(httpClient().get).toHaveBeenCalledWith(
        'users/self/todo?page=bookmark:asdf',
        { transform: expect.any(Function) }
      )
    })
  })

  describe('pagination', () => {
    const api = new API({ policy: 'network-only' })

    it('adds the subsequent pages to the base cache entry', () => {
      api.paginate('users/self/todo')
      const config = mock(httpClient().get).mock.calls[0][1]
      let response = template.apiResponse({
        data: [ 2 ],
        headers: { link: template.apiLinkHeader({
          first: 'users/self/todo?page=1',
          current: 'users/self/todo?page=2',
          next: 'users/self/todo?page=3',
        }) },
      })
      const transformed = config.transform(response.data, response)
      expect(transformed).toBeNull() // we add to prev entry instead
      httpCache.handle('GET', 'users/self/todo', {
        list: [ 1 ],
        next: 'users/self/todo?page=2',
      })
      config.transform(response.data, response)
      const result = api.paginate('users/self/todo')
      expect(result).toEqual({
        list: [ 1, 2 ],
        next: 'users/self/todo?page=3',
        getNextPage: expect.any(Function),
      })
    })

    it('automatically calls getNextPage if page size >= 99', () => {
      api.paginate('users/self/todo', { params: { per_page: 99 } })
      const config = mock(httpClient().get).mock.calls[0][1]
      let response = template.apiResponse({
        data: [ 1 ],
        headers: { link: template.apiLinkHeader({
          first: 'users/self/todo?page=1',
          current: 'users/self/todo?page=1',
          next: 'users/self/todo?page=2',
        }) },
      })
      const transformed = config.transform(response.data, response)
      expect(transformed).toEqual({
        list: [ 1 ],
        next: 'users/self/todo?page=2',
        getNextPage: expect.any(Function),
      })
      expect(httpClient().get).toHaveBeenCalledWith(
        'users/self/todo?page=2',
        {
          params: { per_page: 99 },
          transform: expect.any(Function),
        }
      )
    })
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
      expect(api.getPages('courses', '1')).toEqual({
        list: [],
        next: null,
        getNextPage: null,
      })
      expect(httpClient().get).toHaveBeenCalledWith(
        'courses/1/pages',
        {
          params: { per_page: 99 },
          transform: expect.any(Function),
        }
      )
      const args = mock(httpClient().get).mock.calls[0]
      const response = template.apiResponse({ data: [
        template.page({ title: 'syllabus' }),
        template.page({ title: 'another' }),
        template.page({ title: 'Front', front_page: true }),
      ] })
      const result = args[1].transform(response.data, response)
      expect(result.list).toEqual([
        new PageModel(template.page({ title: 'syllabus' })),
        new PageModel(template.page({ title: 'another' })),
        new PageModel(template.page({ title: 'Front', front_page: true })),
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

    it('can getFrontPage', () => {
      api.getFrontPage('1')
      expect(httpClient().get).toHaveBeenCalledWith(
        'courses/1/front_page',
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

  describe('To Dos', () => {
    const api = new API({ policy: 'network-only' })

    it('can getToDos', () => {
      api.getToDos()
      expect(httpClient().get).toHaveBeenCalledWith(
        'users/self/todo',
        { transform: expect.any(Function) }
      )
      const { transform } = mock(httpClient().get).mock.calls[0][1]
      const response = template.apiResponse({
        data: [ template.toDoItem() ],
        headers: {
          link: template.apiLinkHeader({
            next: 'users/self/todo?page=bookmark:asdf',
          }),
        },
      })
      expect(transform(response.data, response)).toEqual({
        list: [ new ToDoModel(template.toDoItem()) ],
        next: 'users/self/todo?page=bookmark:asdf',
        getNextPage: expect.any(Function),
      })
    })
  })
})
