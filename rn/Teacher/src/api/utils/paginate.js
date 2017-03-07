import parseLink from './parseLinkHeader'
import httpClient from '../canvas-api/httpClient'
import type { ApiResponse } from '../apiResponse'

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

export function paginate<T> (url: string, config: AxiosRequestConfig = {}): Promise<ApiResponse<T>> {
  return httpClient().get(url, config).then((response: any) => {
    const next = parseNextFromLinkHeader(response) || parseNextFromJSON(response)
    return {
      ...response,
      next: next ? () => { return paginate(next) } : null,
    }
  })
}
