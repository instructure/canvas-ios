/* @flow */

import httpClient from '../httpClient'

export function getCustomColors (): Promise<AxiosResponse<CustomColors>> {
  return httpClient().get('users/self/colors')
}

export function getUserProfile (userID: string): Promise<AxiosResponse<User>> {
  return httpClient().get(`/users/${userID}/profile`)
}
