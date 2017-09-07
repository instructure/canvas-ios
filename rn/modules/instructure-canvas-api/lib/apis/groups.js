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

// @flow
import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

export function getGroupsForCourse (courseID: string): Promise<ApiResponse<Array<Group>>> {
  const groups = paginate(`courses/${courseID}/groups`, {
    params: { include: ['users'] },
  })
  return exhaust(groups)
}

export function getGroupsForCategoryID (groupCategoryID: string): Promise<ApiResponse<Array<Group>>> {
  const groups = paginate(`group_categories/${groupCategoryID}/groups`, {
    params: { include: ['users'] },
  })
  return exhaust(groups)
}

export function getGroupByID (groupID: string): Promise<ApiResponse<Array<Group>>> {
  const url = `groups/${groupID}`
  return httpClient().get(url)
}

export function getUsersForGroupID (groupID: string): Promise<ApiResponse<Array<User>>> {
  const url = `groups/${groupID}/users`
  const options = {
    params: { include: ['avatar_url'] },
  }
  return httpClient().get(url, options)
}
