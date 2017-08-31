// @flow
import httpClient from '../httpClient'

export function getAuthenticatedSessionURL (url: string): Promise<ApiResponse<any>> {
  const options = {
    params: {
      return_to: url,
    },
  }
  return httpClient(null).get('login/session_token', options)
}
