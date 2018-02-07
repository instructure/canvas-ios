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

import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

export function getGroupsForCourse (courseID: string): ApiPromise<Group[]> {
  const groups = paginate(`courses/${courseID}/groups`, {
    params: { include: ['users'] },
  })
  return exhaust(groups)
}

export function getGroupsForCategoryID (groupCategoryID: string): ApiPromise<Group[]> {
  const groups = paginate(`group_categories/${groupCategoryID}/groups`, {
    params: { include: ['users'] },
  })
  return exhaust(groups)
}

export function getGroupByID (groupID: string): ApiPromise<Group[]> {
  const url = `groups/${groupID}`
  return httpClient().get(url)
}

export function getUsersForGroupID (groupID: string): ApiPromise<User[]> {
  const url = `groups/${groupID}/users`
  const options = {
    params: { include: ['avatar_url'] },
  }
  return httpClient().get(url, options)
}

export function getUsersGroups (userID: string): ApiPromise<Group[]> {
  const groups = paginate(`users/${userID}/groups`)
  return exhaust(groups)
}
