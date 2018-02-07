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
/* global XMLHttpRequest:true, FormData:true, Blob:true */

import httpClient, { isAbort } from '../httpClient'
import { setSession } from '../session'

const templates = {
  ...require('../../__templates__/session'),
}

describe('httpClient', () => {
  const originalXHR = XMLHttpRequest

  let request
  beforeEach(() => {
    setSession(null)
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
    XMLHttpRequest = function () { return request }
    Blob = function Blob () {}
    FormData = function FormData () {}
  })

  afterEach(() => {
    XMLHttpRequest = originalXHR
  })

  it('has blank defaults if no session is set', () => {
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
