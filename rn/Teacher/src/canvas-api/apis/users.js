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

import httpClient from '../httpClient'

export function getCustomColors (): ApiPromise<CustomColors> {
  return httpClient().get('users/self/colors')
}

export function getUserProfile (userID: string): ApiPromise<User> {
  return httpClient().get(`/users/${userID}/profile`)
}

export function createUser (createUserData: CreateUser): ApiPromise<User> {
  let data = {
    user: {
      short_name: createUserData.user.name,
      sortable_name: createUserData.user.name,
      time_zone: 'America/Denver',
      locale: 'en',
      birthdate: (new Date()).toISOString(),
      terms_of_use: true,
      skip_registration: true,
      ...createUserData.user,
    },
    pseudonym: {
      send_confirmation: false,
      ...createUserData.pseudonym,
    },
    communication_channel: createUserData.communication_channel,
  }
  return httpClient().post(`/accounts/self/users`, data)
}

export function getToDoCount (): ApiPromise<Object> {
  return httpClient().get('users/self/todo_item_count')
}
