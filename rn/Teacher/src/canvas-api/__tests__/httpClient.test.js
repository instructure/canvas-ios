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
/* global FormData:true, Blob:true */

import { AsyncStorage } from 'react-native'
import httpClient, { isAbort, httpCache, inFlight } from '../httpClient'
import { setSession } from '../session'
import * as templates from '../../__templates__'

jest.unmock('../httpClient')
jest.mock('AsyncStorage', () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  getAllKeys: jest.fn(),
  multiRemove: jest.fn(),
}))

describe('httpClient', () => {
  const originalXHR = global.XMLHttpRequest
  const warn = console.warn

  let request
  beforeEach(() => {
    inFlight.clear()
    setSession(templates.session({ baseURL: '' }))
    request = {
      abort: jest.fn(),
      open: jest.fn(),
      send: jest.fn(),
      setRequestHeader: jest.fn(),
      addEventListener: jest.fn(),
      removeEventListener: jest.fn(),
      responseText: '{}',
      response: undefined,
      status: 200,
      getAllResponseHeaders: jest.fn(),
    }
    global.XMLHttpRequest = function () { return request }
    console.warn = jest.fn()
    Blob = function Blob () {}
    FormData = function FormData () {}
  })

  afterEach(() => {
    global.XMLHttpRequest = originalXHR
    console.warn = warn
    setSession(templates.session())
  })

  it('has blank defaults if no session is set', () => {
    setSession(null)
    httpClient().get('')
    expect(request.open).toHaveBeenCalledWith('GET', '/api/v1/', true)
    expect(request.setRequestHeader).toHaveBeenCalledWith(
      'Authorization',
      'Bearer '
    )
  })

  it('uses the session that we set', () => {
    const session = templates.session({ actAsUserID: 2 })
    setSession(session)
    httpClient().get('')
    expect(request.open).toHaveBeenCalledWith(
      'GET',
      'http://mobiledev.instructure.com/api/v1/?as_user_id=2',
      true
    )
    expect(request.setRequestHeader).toHaveBeenCalledWith(
      'Authorization',
      `Bearer ${session.authToken}`
    )
    expect(request.setRequestHeader).toHaveBeenCalledWith(
      'Accept',
      'application/json+canvas-string-ids'
    )
  })

  it('handles baseURL without trailing slash', () => {
    const session = templates.session({ baseURL: 'https://canvas.sfu.ca' })
    setSession(session)
    httpClient().get('')
    expect(request.open).toHaveBeenCalledWith(
      'GET',
      'https://canvas.sfu.ca/api/v1/',
      true
    )
  })

  it('serializes params and adds them to the url', () => {
    httpClient().get('/params', {
      params: {
        array: [ 1, 2 ],
        string: 's',
        'un clean': '?&;=',
      },
    })
    expect(request.open).toHaveBeenCalledWith(
      'GET',
      '/api/v1/params?array[]=1&array[]=2&string=s&un%20clean=%3F%26%3B%3D',
      true
    )
  })

  it('handles params on url with params', () => {
    httpClient().get('/params?b=b', { params: { a: 'a' } })
    expect(request.open).toHaveBeenCalledWith(
      'GET',
      '/api/v1/params?b=b&a=a',
      true
    )
  })

  it('does not prepend base url to absolute urls', () => {
    httpClient().get('https://s3.amazon.com')
    expect(request.open).toHaveBeenCalledWith(
      'GET',
      'https://s3.amazon.com',
      true
    )
  })

  it('does not attach the version if excludeVersion is passed in', () => {
    httpClient().get('/courses/1', { excludeVersion: true })
    expect(request.open).toHaveBeenCalledWith(
      'GET',
      '/courses/1',
      true
    )
  })

  it('dedupes get requests', () => {
    const a = httpClient().get('/courses/22')
    const b = httpClient().get('/courses/22')
    expect(request.open).toHaveBeenCalledTimes(1)
    expect(b).toBe(a)
  })

  it('passes along headers', () => {
    httpClient().delete('', {
      headers: {
        'Authorization': '',
        'X-My-Header': 'value',
      },
    })
    expect(request.setRequestHeader).not.toHaveBeenCalledWith('Authorization', '')
    expect(request.setRequestHeader).toHaveBeenCalledWith('X-My-Header', 'value')
  })

  it('serializes object bodies as json', () => {
    httpClient().post('', { a: 1 })
    expect(request.setRequestHeader).toHaveBeenCalledWith('Content-Type', 'application/json')
    expect(request.send).toHaveBeenCalledWith('{"a":1}')
  })

  it('passes along string bodies', () => {
    httpClient().put('', 'some value')
    expect(request.setRequestHeader).not.toHaveBeenCalledWith('Content-Type', 'application/json')
    expect(request.send).toHaveBeenCalledWith('some value')
  })

  it('passes along blob bodies', () => {
    const blob = new Blob()
    httpClient().post('', blob)
    expect(request.setRequestHeader).not.toHaveBeenCalledWith('Content-Type', 'application/json')
    expect(request.send).toHaveBeenCalledWith(blob)
  })

  it('handles abort events', async () => {
    const fetching = httpClient().get('')
    expect(request.addEventListener).toHaveBeenCalledWith('abort', expect.any(Object))
    const handler = request.addEventListener.mock.calls[0][1]
    handler.handleEvent({ type: 'abort' })
    const error = await fetching.catch(error => error)
    expect(isAbort(error)).toBe(true)
    expect(error.message).toBe('Network request aborted')
  })

  it('handles timeout events', async () => {
    const fetching = httpClient().get('')
    expect(request.addEventListener).toHaveBeenCalledWith('timeout', expect.any(Object))
    const handler = request.addEventListener.mock.calls[0][1]
    handler.handleEvent({ type: 'timeout' })
    const error = await fetching.catch(error => error)
    expect(isAbort(error)).toBe(false)
    expect(error.message).toBe('Network request timed out')
  })

  it('handles error events with actual errors attached', async () => {
    const fetching = httpClient().get('')
    expect(request.addEventListener).toHaveBeenCalledWith('error', expect.any(Object))
    const handler = request.addEventListener.mock.calls[0][1]
    handler.handleEvent({ type: 'error', error: new Error('oops') })
    const error = await fetching.catch(error => error)
    expect(isAbort(error)).toBe(false)
    expect(error.message).toBe('oops')
  })

  it('handles error events with message attached', async () => {
    const fetching = httpClient().get('')
    expect(request.addEventListener).toHaveBeenCalledWith('error', expect.any(Object))
    const handler = request.addEventListener.mock.calls[0][1]
    handler.handleEvent({ type: 'error', message: 'oops2' })
    const error = await fetching.catch(error => error)
    expect(isAbort(error)).toBe(false)
    expect(error.message).toBe('oops2')
  })

  it('handles empty error events', async () => {
    const fetching = httpClient().get('')
    expect(request.addEventListener).toHaveBeenCalledWith('error', expect.any(Object))
    const handler = request.addEventListener.mock.calls[0][1]
    handler.handleEvent({ type: 'error' })
    const error = await fetching.catch(error => error)
    expect(isAbort(error)).toBe(false)
    expect(error.message).toBe('Network request failed')
  })

  it('parses response headers', async () => {
    const fetching = httpClient().get('')
    request.getAllResponseHeaders = () =>
      'Content-Type: application/json+canvas-string-ids\r\n' +
      'Link: <next>; rel=next'
    expect(request.addEventListener).toHaveBeenCalledWith('load', expect.any(Object))
    const handler = request.addEventListener.mock.calls[0][1]
    handler.handleEvent({ type: 'load' })
    const response = await fetching
    expect(response.headers).toEqual({
      'content-type': 'application/json+canvas-string-ids',
      'link': '<next>; rel=next',
    })
  })

  it('returns the response object as data', async () => {
    const fetching = httpClient().get('')
    request.response = {}
    request.responseText = '{"a":"a"}'
    expect(request.addEventListener).toHaveBeenCalledWith('load', expect.any(Object))
    const handler = request.addEventListener.mock.calls[0][1]
    handler.handleEvent({ type: 'load' })
    const response = await fetching
    expect(response.data).toBe(request.response)
  })

  it('can transform the response data', async () => {
    const fetching = httpClient().get('', { transform: () => 'transformed' })
    request.response = {}
    expect(request.addEventListener).toHaveBeenCalledWith('load', expect.any(Object))
    const handler = request.addEventListener.mock.calls[0][1]
    handler.handleEvent({ type: 'load' })
    const response = await fetching
    expect(response.data).toBe('transformed')
  })

  it('considers status >= 400 an error', async () => {
    const fetching = httpClient().get('')
    request.response = { error: [] }
    request.status = 400
    expect(request.addEventListener).toHaveBeenCalledWith('load', expect.any(Object))
    const handler = request.addEventListener.mock.calls[0][1]
    handler.handleEvent({ type: 'load' })
    const error = await fetching.catch(error => error)
    expect(isAbort(error)).toBe(false)
    expect(error.message).toBe('Network request failed')
    expect(error.response.data).toBe(request.response)
  })
})

describe('httpCache', () => {
  const now = Date.now
  beforeEach(() => {
    // $FlowFixMe
    Date.now = jest.fn(() => 1000000000000)
    setSession(templates.session({ baseURL: '' }))
  })
  afterEach(() => {
    // $FlowFixMe
    Date.now = now
    httpCache.clear()
    setSession(templates.session())
  })

  it('includes baseURL in storageKey', () => {
    setSession(templates.session({ baseURL: 'https://canvas.docker' }))
    expect(httpCache.storageKey).toContain('https://canvas.docker')
  })

  it('exposes key generation', () => {
    expect(httpCache.key('/nowhere')).toBe('/api/v1/nowhere')
  })

  it('returns not found entry on cache misses', () => {
    expect(httpCache.get('/nowhere')).toBe(httpCache.notFound)
    expect(httpCache.notFound).toEqual({
      value: null,
      expiresAt: 0,
    })
  })

  it('saves get requests', () => {
    httpCache.handle('GET', '/nowhere', 'test')
    expect(httpCache.get('/nowhere')).toEqual({
      value: 'test',
      expiresAt: 1000003600000,
    })
  })

  it('will use cacheKey if present', () => {
    httpCache.handle('GET', '/anywhere', 'test', { cacheKey: 'abc' })
    expect(httpCache.get('/nowhere', { cacheKey: 'abc' })).toEqual({
      value: 'test',
      expiresAt: 1000003600000,
    })
  })

  it('will use ttl if present', () => {
    httpCache.handle('GET', '/nowhere', 'test', { ttl: 1 })
    expect(httpCache.get('/nowhere')).toEqual({
      value: 'test',
      expiresAt: 1000000000001,
    })
  })

  it('can clear the whole cache', () => {
    httpCache.handle('GET', '/nowhere', 'test')
    httpCache.clear()
    expect(httpCache.get('/nowhere')).toBe(httpCache.notFound)
  })

  it('can clear all expired entries', () => {
    // $FlowFixMe
    Date.now = jest.fn(() => 1000)
    httpCache.handle('GET', '/a', 'a', { ttl: 10 })
    httpCache.handle('GET', '/b', 'b', { ttl: 100 })
    // $FlowFixMe
    Date.now = jest.fn(() => 1080)
    httpCache.cleanup()
    expect(httpCache.get('/a')).toBe(httpCache.notFound)
    expect(httpCache.get('/b')).toEqual({
      value: 'b',
      expiresAt: 1100,
    })
  })

  it('can purge the user data', () => {
    httpCache.purgeUserData()
    expect(AsyncStorage.removeItem).toHaveBeenCalledWith(
      httpCache.storageKey,
    )
  })

  it('clears the entry and parent entry on put', () => {
    httpCache.handle('GET', '/dwarfs', [ 'pluto', 'ceres', 'eris' ])
    httpCache.handle('GET', '/dwarfs/eris', { name: 'Eris' })
    expect(httpCache.get('/dwarfs').value).toEqual([ 'pluto', 'ceres', 'eris' ])
    expect(httpCache.get('/dwarfs/eris').value).toEqual({ name: 'Eris' })
    httpCache.handle('PUT', '/dwarfs/eris', { name: 'Eris' })
    expect(httpCache.get('/dwarfs')).toBe(httpCache.notFound)
    expect(httpCache.get('/dwarfs/eris')).toBe(httpCache.notFound)
  })

  it('clears the entry and parent entry on delete', () => {
    httpCache.handle('GET', '/dwarfs', [ 'pluto', 'ceres', 'eris' ])
    httpCache.handle('GET', '/dwarfs/eris', { name: 'Eris' })
    expect(httpCache.get('/dwarfs').value).toEqual([ 'pluto', 'ceres', 'eris' ])
    expect(httpCache.get('/dwarfs/eris').value).toEqual({ name: 'Eris' })
    httpCache.handle('DELETE', '/dwarfs/eris', null)
    expect(httpCache.get('/dwarfs')).toBe(httpCache.notFound)
    expect(httpCache.get('/dwarfs/eris')).toBe(httpCache.notFound)
  })

  it('clears the entry on POST', () => {
    httpCache.handle('GET', '/dwarfs', [ 'pluto', 'ceres', 'eris' ])
    expect(httpCache.get('/dwarfs').value).toEqual([ 'pluto', 'ceres', 'eris' ])
    httpCache.handle('POST', '/dwarfs', { name: 'Makemake' })
    expect(httpCache.get('/dwarfs')).toBe(httpCache.notFound)
  })

  it('can have subscribers', () => {
    const listener = jest.fn()
    const unsub = httpCache.subscribe(listener)
    const promise = Promise.resolve()
    httpCache.handle('GET', '/dwarfs', [ 'pluto', 'ceres', 'eris' ], {}, promise)
    expect(listener).toHaveBeenCalledWith(promise)
    unsub()
    listener.mockClear()
    httpCache.handle('GET', '/dwarfs', [ 'pluto', 'ceres', 'eris' ])
    expect(listener).not.toHaveBeenCalled()
  })

  it('persists to async storage', async () => {
    const page = templates.pageModel()
    httpCache.handle('GET', '/pages', [ page ])
    httpCache.handle('GET', 'expired', null, { ttl: -1 })
    expect(AsyncStorage.setItem).toHaveBeenCalledWith(
      httpCache.storageKey,
      expect.stringContaining('"modelConstructor":"PageModel"'),
    )
    const item = AsyncStorage.setItem.mock.calls.slice(-1)[0][1]
    AsyncStorage.getItem.mockImplementationOnce(() => Promise.resolve(item))
    httpCache.clear()
    await httpCache.hydrate()
    expect(httpCache.get('/pages')).toEqual({
      value: [ page ],
      expiresAt: 1000003600000,
    })
    expect(httpCache.get('expired')).toEqual(httpCache.notFound)
  })

  it('clears stale items from async storage when no item is found', async () => {
    AsyncStorage.getAllKeys.mockImplementationOnce(() => [
      'http.cache.0.1',
      'http.cache.1.2',
      'redux.stuff',
    ])
    await httpCache.hydrate()
    expect(AsyncStorage.multiRemove).toHaveBeenCalledWith([
      'http.cache.0.1',
      'http.cache.1.2',
    ])
  })
})
