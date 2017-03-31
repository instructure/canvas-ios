/* @flow */

import httpClient from '../../canvas-api/httpClient'
import { paginate, exhaust } from '../pagination'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'

jest.mock('../../canvas-api/httpClient')

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
      next: null,
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
      next: null,
    })
  })
})
