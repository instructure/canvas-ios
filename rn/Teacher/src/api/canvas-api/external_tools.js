// @flow

import httpClient from './httpClient'

type GetExternalToolOptions = {
  assignment?: Assignment,
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
