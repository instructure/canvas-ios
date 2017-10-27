// @flow

import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

export function getPages (courseID: string): Promise<ApiResponse<Page[]>> {
  const url = `courses/${courseID}/pages`
  const options = {
    params: {
      per_page: 99,
    },
  }
  let pages = paginate(url, options)
  return exhaust(pages)
}

export function getPage (courseID: string, url: string): Promise<ApiResponse<Page>> {
  return httpClient().get(`courses/${courseID}/pages/${url}`)
}
