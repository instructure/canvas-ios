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

import httpClient from '../httpClient'
import { paginate, exhaust } from '../utils/pagination'

export function getLTILaunchDefinitions (courseID: string): Promise<ApiResponse<Array<getLTILaunchDefinitions>>> {
  const url = `courses/${courseID}/lti_apps/launch_definitions`

  const paginated = paginate(url, {
    params: {
      per_page: 99,
      placements: ['course_navigation'],
    },
  })
  return exhaust(paginated)
}

export function getExternalTool (courseID: string, id: string, options: GetExternalToolOptions): Promise<ApiResponse<ExternalTool>> {
  const { assignment } = options
  let params = {}
  const url = `courses/${courseID}/external_tools/${id}`

  if (assignment && assignment.external_tool_tag_attributes) {
    params.url = assignment.external_tool_tag_attributes.url
  }

  return httpClient().get(url, { params })
}

export function getSessionlessLaunchURL (courseID: string, options: GetExternalToolOptions): Promise<string> {
  return getExternalTool(courseID, 'sessionless_launch', options).then(response => response.data.url)
}
