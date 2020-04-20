//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import httpClient from '../httpClient'

export function getCustomColors (): ApiPromise<CustomColors> {
  return httpClient.get('users/self/colors')
}

export function getFakeStudent (courseID) {
  return httpClient.get(`courses/${courseID}/student_view_student`)
}

export function getUserProfile (userID: string): ApiPromise<User> {
  return httpClient.get(`/users/${userID}/profile`)
}

export function getUser (userID: string): ApiPromise<User> {
  return httpClient.get(`/users/${userID}`)
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
  return httpClient.post(`/accounts/self/users`, data)
}

export function getToDoCount (): ApiPromise<Object> {
  return httpClient.get('users/self/todo_item_count')
}

export function getUserSettings (userID: string = 'self'): ApiPromise<UserSettings> {
  return httpClient.get(`/users/${userID}/settings`)
}

export function updateUserSettings (userID: string = 'self', hideOverlay: boolean): ApiPromise<UserSettings> {
  return httpClient.put(`/users/${userID}/settings`, {
    hide_dashcard_color_overlays: hideOverlay,
  })
}
