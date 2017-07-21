// @flow

export function getAuthenticatedSessionURL (url: string): Promise<ApiResponse<any>> {
  return Promise.resolve({ data: { session_url: `${url}-authenticated` }, next: null })
}
