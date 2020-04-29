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
import { paginate, exhaust } from '../utils/pagination'

export function getLTILaunchDefinitions (courseID: string): ApiPromise<LTILaunchDefinition[]> {
  const url = `courses/${courseID}/lti_apps/launch_definitions`

  const paginated = paginate(url, {
    params: {
      per_page: 100,
      placements: ['course_navigation'],
    },
  })
  return exhaust(paginated)
}

export function getExternalTool (courseID: string, id: string, options: GetExternalToolOptions): ApiPromise<ExternalTool> {
  const { assignment } = options
  let params = {}
  const url = `courses/${courseID}/external_tools/${id}`

  if (assignment) {
    params['launch_type'] = 'assessment'
    params['assignment_id'] = assignment.id
  }

  return httpClient.get(url, { params })
}

export function getExternalTools (courseID: string, params: { include_parents?: boolean }): ApiPromise<Array<ExternalTool>> {
  const tools = paginate(`courses/${courseID}/external_tools`, { params })
  return exhaust(tools)
}

export function getSessionlessLaunchURL (courseID: string, options: GetExternalToolOptions): Promise<string> {
  return getExternalTool(courseID, 'sessionless_launch', options).then(response => response.data.url)
}

export function refreshAccountExternalTools (): ApiPromise<ExternalToolLaunchDefinition[]> {
  return httpClient.get(`accounts/self/lti_apps/launch_definitions?placements[]=global_navigation`)
}
