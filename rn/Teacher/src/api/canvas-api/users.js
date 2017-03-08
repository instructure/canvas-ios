/* @flow */

import httpClient from './httpClient'

export function getCustomColors (): Promise<AxiosResponse<CustomColors>> {
  return httpClient().get('users/self/colors')
}
