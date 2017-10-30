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

import parseLink from './parse-link-header'
import httpClient from '../httpClient'

function parseNextFromLinkHeader (response: any): ?string {
  const links = parseLink(response.headers.link)
  if (links && links.next) {
    return links.next.url
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

export function paginate<T> (url: string, config: AxiosRequestConfig = {}): Promise<ApiResponse<T>> {
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
export async function exhaust<T> (initial: Promise<ApiResponse<[T]>>, keys?: string[] = []): Promise<ApiResponse<[T]>> {
  let result
  if (keys.length) {
    result = {}
  } else {
    result = []
  }

  let next = () => initial
  while (next) {
    const response = await next()
    if (response.data) {
      if (keys.length) {
        keys.forEach((key) => {
          const newData = response.data[key] || []
          const oldData = result[key] || []
          result[key] = [...oldData, ...newData]
        })
      } else {
        result = [...result, ...response.data]
      }
    }
    next = response.next
  }
  return {
    data: result,
    next: null,
  }
}
