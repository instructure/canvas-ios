import parseLink from './parseLinkHeader'
import httpClient from '../canvas-api/httpClient'
import type { ApiResponse } from '../response'

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
