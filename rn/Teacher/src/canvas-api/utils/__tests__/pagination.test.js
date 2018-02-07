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

/* @flow */

import httpClient from '../../httpClient'
import { paginate, exhaust } from '../pagination'
import { apiResponse, apiError } from '../testHelpers'

jest.mock('../../httpClient')

describe('paginate', () => {
  it('should return next promise', async () => {
    const headers = {
      link: '<https://example.com/items?page=1&per_page=1>; rel="current",\
             <https://example.com/items?page=2&per_page=1>; rel="next",\
             <https://example.com/items?page=1&per_page=1>; rel="first",\
             <https://example.com/items?page=4&per_page=1>; rel="last"',
    }

    const mock = apiResponse([], { headers: headers })
    httpClient().get = mock

    const result = await paginate('courses')

    expect(result.status).toBe(200)
    expect(result.data).toHaveLength(0)
    expect(result.next).not.toBeNull()
    expect(mock).toHaveBeenCalledWith('courses', {})

    await result.next()
    expect(mock).toHaveBeenCalledWith('https://example.com/items?page=2&per_page=1', {})
  })

  it('should set next to null on last page', async () => {
    const headers = {
      link: '<https://example.com/items?page=1&per_page=1>; rel="current",\
             <https://example.com/items?page=1&per_page=1>; rel="first",\
             <https://example.com/items?page=4&per_page=1>; rel="last"',
    }

    const mock = apiResponse([], { headers: headers })
    httpClient().get = mock

    const result = await paginate('courses')

    expect(result.status).toBe(200)
    expect(result.data).toHaveLength(0)
    expect(result.next).toBeNull()
  })

  it('should handle no links in header', async () => {
    const mock = apiResponse([], { headers: { link: null } })
    httpClient().get = mock

    const result = await paginate('courses')

    expect(result.status).toBe(200)
    expect(result.data).toHaveLength(0)
    expect(result.next).toBeNull()
  })

  it('should propagate errors', async () => {
    httpClient().get = apiError()

    let error
    let response
    try {
      response = await paginate('courses')
    } catch (e) {
      error = e
    }

    expect(response).toBeUndefined()
    expect(error).toBeDefined()
  })

  it('should parse json meta pagination', async () => {
    const mock = apiResponse({
      grading_periods: [],
      meta: {
        pagination: {
          next: 'grading_periods?page=2',
        },
      },
    })
    httpClient().get = mock

    const result = await paginate('grading_periods')
    expect(mock).toHaveBeenCalledWith('grading_periods', {})

    await result.next()
    expect(mock).toHaveBeenCalledWith('grading_periods?page=2', {})
  })

  it('should accept options', async () => {
    const mock = apiResponse([])
    httpClient().get = mock

    let options = {
      params: {
        yo: 1,
      },
    }

    await paginate('courses', options)

    expect(mock).toHaveBeenCalledWith('courses', options)
  })
})

describe('exhaust', () => {
  it('should exhaust pagination', async () => {
    const page3 = apiResponse([3])
    const page2 = apiResponse([2], { next: page3 })
    const page1 = apiResponse([1], { next: page2 })

    const result = await exhaust(page1())
    expect(result).toEqual({
      data: [1, 2, 3],
    })
  })

  it('should exhaust pagination with passed in keys', async () => {
    const page3 = apiResponse({ key: [3] })
    const page2 = apiResponse({ key: [2] }, { next: page3 })
    const page1 = apiResponse({ key: [1] }, { next: page2 })

    const result = await exhaust(page1(), ['key'])
    expect(result).toEqual({
      data: { key: [1, 2, 3] },
    })
  })

  it('should exhaust pagination with passed in keys but a response could be missing things', async () => {
    const page3 = apiResponse({ key: [3] })
    const page2 = apiResponse({ key: [2] }, { next: page3 })
    const page1 = apiResponse({ garbage: [4] }, { next: page2 })

    const result = await exhaust(page1(), ['key'])
    expect(result).toEqual({
      data: { key: [2, 3] },
    })
  })

  it('should propagate errors', async () => {
    const page2 = apiError()
    const page1 = apiResponse([1], { next: page2 })

    let error
    let response
    try {
      response = await exhaust(page1())
    } catch (e) {
      error = e
    }

    expect(response).toBeUndefined()
    expect(error).toBeDefined()
  })

  it('should only append results when there is data', async () => {
    const page2 = apiResponse(null)
    const page1 = apiResponse([1], { next: page2 })

    const result = await exhaust(page1())
    expect(result).toEqual({
      data: [1],
    })
  })
})
