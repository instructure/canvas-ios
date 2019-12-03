//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
/* global XMLHttpRequest, Blob */

import AsyncStorage from '@react-native-community/async-storage'
import { getSession } from './session'
import * as models from './model'

type Method = 'GET' | 'POST' | 'PUT' | 'DELETE'
type Body = null | void | string | Object | FormData | Blob | ArrayBuffer

export function resolveUrl (url: string, config: ApiConfig) {
  // FIXME: hardcoded url. MBL-13344
  const baseURL = (config.baseURL || getSession().baseURL || 'https://canvas.instructure.com').replace(/\/?$/, '')
  const version = config.excludeVersion ? '/' : '/api/v1/'
  return /^\w+:/.test(url) ? url : `${baseURL}${version}${url.replace(/^\//, '')}`
}

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

export const inFlight: Map<string, ApiPromise<any>> = new Map()

function xhr (method: Method, url: string, data: Body, config: ApiConfig = {}) {
  const params = { ...config.params }
  const query = serializeParams(params)

  let fullUrl = resolveUrl(url, config)
  if (query) fullUrl += (fullUrl.includes('?') ? '&' : '?') + query

  const key = `${method} ${fullUrl}`
  const match = inFlight.get(key)
  if (method === 'GET' && match) {
    return match // dedupe in-flight requests
  }

  const request = new XMLHttpRequest()
  const promise: ApiPromise<*> = new Promise((resolve, reject) => {
    request.open(method, fullUrl, true)
    request.responseType = config.responseType || 'json'
    request.timeout = config.timeout || 0

    const headers = {
      'X-Requested-With': 'XMLHttpRequest',
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

            if (!request.status || request.status >= 400) {
              throw new TypeError('Network request failed')
            }
            if (config.transform) {
              response.data = config.transform(response.data, response)
            }
            httpCache.handle(method, url, response.data, config, promise)
            resolve(response)
            break
          case 'error':
            throw new TypeError('Network request failed')
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
      inFlight.delete(key)
    } }
    request.addEventListener('abort', handler)
    request.addEventListener('error', handler)
    request.addEventListener('load', handler)
    request.addEventListener('timeout', handler)
    request.send(body)
  })
  promise.request = request
  inFlight.set(key, promise)
  return promise
}

export default {
  get: (url: string, config?: ApiConfig) => xhr('GET', url, null, config),
  delete: (url: string, config?: ApiConfig) => xhr('DELETE', url, null, config),
  post: (url: string, data?: Body, config?: ApiConfig) => xhr('POST', url, data, config),
  put: (url: string, data?: Body, config?: ApiConfig) => xhr('PUT', url, data, config),
}

/*
 * Assumptions:
 * urls are restful, so
 *   POST /pages invalidates /pages, since it added a list item
 *   DELETE|PUT /pages/1 invalidates /pages, since it changed a list item
 * no two GET requests will differ only by headers, params, transform, etc
 *   so resolved url is sufficient
 */
type CacheEntry = {
 value: any,
 expiresAt: number,
}
const cache: Map<string, CacheEntry> = new Map()
const listeners: Set<(?ApiPromise<any>) => void> = new Set()
export const httpCache = {
  CACHE_VERSION: 3,
  notFound: {
    value: null,
    expiresAt: 0,
  },
  get storageKey () {
    const { baseURL, user } = getSession()
    return `http.cache.${baseURL}.${user.id}.${httpCache.CACHE_VERSION}`
  },
  clear () {
    cache.clear()
    for (const fn of listeners) fn()
  },
  purgeUserData () {
    httpCache.clear()
    return AsyncStorage.removeItem(httpCache.storageKey)
  },
  cleanup () {
    for (const [ key, entry ] of cache) {
      if (entry.expiresAt < Date.now()) cache.delete(key)
    }
    httpCache.notify()
  },
  key (url: string, config?: ApiConfig = {}) {
    return config.cacheKey || resolveUrl(url, config)
  },
  get (url: string, config?: ApiConfig = {}) {
    return cache.get(httpCache.key(url, config)) || httpCache.notFound
  },
  handle (method: Method, url: string, value: any, config?: ApiConfig = {}, promise?: ApiPromise<any>) {
    const key = httpCache.key(url, config)
    if (method === 'GET') {
      cache.set(key, {
        value,
        expiresAt: Date.now() + (config.ttl || 60 * 60 * 1000), // 1 hour default
      })
    } else { // if 'DELETE' | 'POST' | 'PUT'
      cache.delete(key)
    }
    if (method === 'DELETE' || method === 'PUT') {
      cache.delete(key.replace(/\/[^/]+$/, ''))
    }
    httpCache.notify(promise)
  },
  subscribe (fn: (?ApiPromise<any>) => void) {
    listeners.add(fn)
    return () => { listeners.delete(fn) }
  },
  notify (promise: ?ApiPromise<any>) {
    for (const fn of listeners) fn(promise)
    return AsyncStorage.setItem(
      httpCache.storageKey,
      JSON.stringify([ ...cache ], modelReplacer)
    )
  },
  async hydrate () {
    const state = await AsyncStorage.getItem(httpCache.storageKey)
    if (state) {
      try {
        for (const [ key, entry ] of JSON.parse(state, modelReviver)) {
          if (entry.expiresAt > Date.now()) cache.set(key, entry)
        }
      } catch (err) {}
    } else {
      await AsyncStorage.multiRemove(
        (await AsyncStorage.getAllKeys()).filter(k =>
          k.startsWith('http.cache.') &&
          !k.endsWith(`.${httpCache.CACHE_VERSION}`)
        )
      )
    }
    httpCache.notify()
  },
}

const modelReplacer = (key: string, value: any) => {
  if (value instanceof models.Model) {
    for (const name of Object.keys(models)) {
      if (name === 'Model') continue
      if (value instanceof models[name]) {
        return {
          ...value.raw,
          modelConstructor: name,
        }
      }
    }
  }
  return value
}

const modelReviver = (key: string, value: any) => {
  if (value && value.modelConstructor && models[value.modelConstructor]) {
    const { modelConstructor, ...raw } = value
    return new models[modelConstructor](raw)
  }
  return value
}
