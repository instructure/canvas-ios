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

import parseLink from './parse-link-header'
import httpClient from '../httpClient'

function parseNextFromLinkHeader (response: any): ?string {
  const links = parseLink(response.headers.link)
  if (links && links.next) {
    return links.next
  }
  return null
}

function parseNextFromJSON (response: any): ?string {
  if (response.data && response.data.meta && response.data.meta.pagination) {
    return response.data.meta.pagination.next
  }
  return null
}

export function parseNext (response: any): ?string {
  return parseNextFromLinkHeader(response) || parseNextFromJSON(response)
}

export function paginate<T> (url: string, config: ApiConfig = {}): ApiPromise<T> {
  return httpClient().get(url, config).then((response: any) => {
    const next = parseNext(response)
    return {
      ...response,
      next: next ? () => { return paginate(next) } : null,
    }
  })
}

// If keys are supplied, the result is implied to be a object instead of an array
// The keys are then used to extract and append the data from the result
export async function exhaust<T> (initial: ApiPromise<T[]>, keys?: string[] = []): ApiPromise<T[]> {
  let result = []
  let resultMap = {}

  let next = () => initial
  while (next) {
    const response = await next()
    if (response.data) {
      if (keys.length) {
        keys.forEach((key) => {
          const newData = response.data[key] || []
          const oldData = resultMap[key] || []
          resultMap[key] = [...oldData, ...newData]
        })
      } else {
        result = [...result, ...response.data]
      }
    }
    next = response.next
  }
  return {
    data: keys.length ? resultMap : result,
  }
}
