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

/* @flow */

import httpClient from '../httpClient'

export function getCustomColors (): Promise<AxiosResponse<CustomColors>> {
  return httpClient().get('users/self/colors')
}

export function getUserProfile (userID: string): Promise<AxiosResponse<User>> {
  return httpClient().get(`/users/${userID}/profile`)
}

export function createUser (createUserData: CreateUser): Promise<AxiosResponse<User>> {
  let data = {
    user: {
      short_name: createUserData.user.name,
      sortable_name: createUserData.user.name,
      time_zone: "America/Denver",
      locale: 'en',
      birthdate: (new Date()).toISOString(),
      terms_of_use: true,
      skip_registration: true,
      ...createUserData.user
    },
    pseudonym: {
      send_confirmation: false,
      ...createUserData.pseudonym
    },
    communication_channel: createUserData.communication_channel
  }
  return httpClient().post(`/accounts/self/users`, data)
}

export function getToDo (): Promise<AxiosResponse<ToDoItem[]>> {
  return httpClient().get('users/self/todo')
}
