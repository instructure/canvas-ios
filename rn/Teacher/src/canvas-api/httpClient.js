//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow
/* global XMLHttpRequest, Blob */

import { getSession } from './session'

type Method = 'GET' | 'POST' | 'PUT' | 'DELETE'

export function serializeParams (params: { [string]: any }) {
  const clean = encodeURIComponent
  const search = []
  for (const key of Object.keys(params)) {
    if (Array.isArray(params[key])) {
      for (const value of params[key]) {
        search.push(`${clean(key)}[]=${clean(value)}`)
      }
    } else {
      search.push(`${clean(key)}=${clean(params[key])}`)
    }
  }
  return search.join('&')
}

export function parseHeaders (allHeaders: ?string) {
  const headers = {}
  for (const line of (allHeaders || '').split('\r\n')) {
    const [ key, value ] = line.split(': ')
    headers[key.toLowerCase()] = value
  }
  return headers
}

export function isAbort (error: Error) {
  return error.message === 'Network request aborted'
}

function xhr (method: Method, url: string, data: ?Object, config: ApiConfig = {}) {
  const request = new XMLHttpRequest()
  const promise = new Promise((resolve, reject) => {
    const {
      actAsUserID,
      authToken = '',
      baseURL = '',
    } = getSession() || {}

    const params = { ...config.params }
    if (actAsUserID) params.as_user_id = actAsUserID
    const query = serializeParams(params)

    let fullUrl = /^\w+:/.test(url) ? url
        : `${baseURL.replace(/\/?$/, '')}${config.excludeVersion ? '/' : '/api/v1/'}${url.replace(/^\//, '')}`
    if (query) fullUrl += (fullUrl.includes('?') ? '&' : '?') + query

    request.open(method, fullUrl, true)
    request.responseType = config.responseType || 'json'
    request.timeout = config.timeout || 0

    const headers = {
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': `Bearer ${authToken}`,
      'Accept': 'application/json+canvas-string-ids',
      ...config.headers,
    }
    for (const name of Object.keys(headers)) {
      if (headers[name]) request.setRequestHeader(name, headers[name])
    }

    let body = data
    if (
      data && typeof data === 'object' && !(
        data instanceof FormData ||
        data instanceof Blob ||
        data instanceof ArrayBuffer ||
        ArrayBuffer.isView(data)
      )
    ) {
      request.setRequestHeader('Content-Type', 'application/json')
      body = JSON.stringify(data)
    }

    const handler = { handleEvent (event: Event) {
      let response
      try {
        switch (event.type) {
          case 'load':
            response = {
              data: request.response,
              config,
              headers: parseHeaders(request.getAllResponseHeaders()),
              status: request.status,
              statusText: request.statusText,
            }

            if (request.status >= 400) {
              throw new TypeError('Network request failed')
            }
            resolve(response)
            break
          case 'error':
            throw event.error || new Error(event.message || 'Network request failed')
          case 'timeout':
            throw new TypeError('Network request timed out')
          case 'abort':
            throw new TypeError('Network request aborted')
        }
      } catch (error) {
        reject(Object.assign(error, {
          config,
          error,
          request,
          response,
        }))
      }

      request.removeEventListener('abort', handler)
      request.removeEventListener('error', handler)
      request.removeEventListener('load', handler)
      request.removeEventListener('timeout', handler)
    } }
    request.addEventListener('abort', handler)
    request.addEventListener('error', handler)
    request.addEventListener('load', handler)
    request.addEventListener('timeout', handler)
    request.send(body)
  })
  promise.request = request
  return promise
}

const client = {
  get: (url, config) => xhr('GET', url, null, config),
  delete: (url, config) => xhr('DELETE', url, null, config),
  post: (url, data, config) => xhr('POST', url, data, config),
  put: (url, data, config) => xhr('PUT', url, data, config),
}

export default function httpClient () { return client }
