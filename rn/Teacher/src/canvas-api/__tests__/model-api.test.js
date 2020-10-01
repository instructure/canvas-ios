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
import httpClient from '../httpClient'
import {
  API,
  httpCache,
  CourseModel,
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
      expect(api.get('courses/1')).toBe(null)
      const course = template.courseModel()
      httpCache.handle('GET', 'courses/1', course)
      expect(api.get('courses/1')).toBe(course)
    })

    it('does not hit the network api for GET', () => {
      api.get('courses/1')
      expect(httpClient.get).not.toHaveBeenCalled()
    })

    it('still hits the network api for non-GET', () => {
      api.post('/one', {})
      expect(httpClient.post).toHaveBeenCalled()
      api.put('/two', {})
      expect(httpClient.put).toHaveBeenCalled()
      api.delete('/three')
      expect(httpClient.delete).toHaveBeenCalled()
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
      expect(api.get('courses/1')).toBe(null)
      const course = template.courseModel()
      httpCache.handle('GET', 'courses/1', course)
      expect(api.get('courses/1')).toBe(course)
    })

    it('hits the network api for cached GET', () => {
      const course = template.courseModel()
      httpCache.handle('GET', 'courses/1', course)
      api.get('courses/1')
      expect(httpClient.get).toHaveBeenCalledWith('courses/1', {})
    })

    it('hits the network api for non-GET', () => {
      api.post('/one', {})
      expect(httpClient.post).toHaveBeenCalled()
      api.put('/two', {})
      expect(httpClient.put).toHaveBeenCalled()
      api.delete('/three')
      expect(httpClient.delete).toHaveBeenCalled()
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
      expect(httpClient.get).toHaveBeenCalledWith(
        'users/self/todo?page=bookmark:asdf',
        { transform: expect.any(Function) }
      )
    })
  })

  describe('cache-and-network policy', () => {
    const api = new API({ policy: 'cache-and-network' })

    it('immediately returns cached data', () => {
      expect(api.get('courses/1')).toBe(null)
      const course = template.courseModel()
      httpCache.handle('GET', 'courses/1', course)
      expect(api.get('courses/1')).toBe(course)
    })

    it('does not hit the network api for cached GET', () => {
      const course = template.courseModel()
      httpCache.handle('GET', 'courses/1', course)
      api.get('courses/1')
      expect(httpClient.get).not.toHaveBeenCalled()
    })

    it('does hit the network api for expired GET', () => {
      const course = template.courseModel()
      httpCache.handle('GET', 'courses/1', course, { ttl: -1 })
      api.get('courses/1')
      expect(httpClient.get).toHaveBeenCalledWith('courses/1', {})
      httpCache.handle('GET', 'users/self/todo', { list: [] }, { ttl: -1 })
      api.paginate('users/self/todo')
      expect(httpClient.get).toHaveBeenCalledWith(
        'users/self/todo',
        { transform: expect.any(Function) }
      )
    })

    it('hits the network api for non-GET', () => {
      api.post('/one', {})
      expect(httpClient.post).toHaveBeenCalled()
      api.put('/two', {})
      expect(httpClient.put).toHaveBeenCalled()
      api.delete('/three')
      expect(httpClient.delete).toHaveBeenCalled()
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
      expect(httpClient.get).toHaveBeenCalledWith(
        'users/self/todo?page=bookmark:asdf',
        { transform: expect.any(Function) }
      )
    })
  })

  describe('pagination', () => {
    const api = new API({ policy: 'network-only' })

    it('adds the subsequent pages to the base cache entry', () => {
      api.paginate('users/self/todo')
      const config = mock(httpClient.get).mock.calls[0][1]
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
      api.paginate('users/self/todo', { params: { per_page: 100 } })
      const config = mock(httpClient.get).mock.calls[0][1]
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
      expect(httpClient.get).toHaveBeenCalledWith(
        'users/self/todo?page=2',
        {
          params: { per_page: 100 },
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
    mock(httpClient.delete).mockImplementation(() => Promise.reject())
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
      expect(httpClient.get).toHaveBeenCalledWith(
        'users/self/colors',
        {}
      )
    })

    it('can getCourse', () => {
      expect(api.getCourse('1')).toBe(null)
      expect(httpClient.get).toHaveBeenCalledWith(
        'courses/1',
        {
          params: {
            include: [ 'permissions', 'term', 'favorites', 'course_image', 'sections' ],
          },
          transform: expect.any(Function),
        }
      )
      const { transform } = mock(httpClient.get).mock.calls[0][1]
      expect(transform(template.course())).toEqual(
        new CourseModel(template.course())
      )
    })
  })

  describe('To Dos', () => {
    const api = new API({ policy: 'network-only' })

    it('can getToDos', () => {
      api.getToDos()
      expect(httpClient.get).toHaveBeenCalledWith(
        'users/self/todo',
        { transform: expect.any(Function) }
      )
      const { transform } = mock(httpClient.get).mock.calls[0][1]
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
