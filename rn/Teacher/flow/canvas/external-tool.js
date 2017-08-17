// @flow

export type ExternalTool = {
  id: string,
  name: string,
  url: string,
}

export type LtiLaunchDefinition = {
  definition_id: number,
  placements: {
    course_navigation?: {
      url: string,
    },
  },
}
