/* @flow */

import template, { type Template } from '../../../utils/template'

export const externalTool: Template<AddressBookResult> = template({
  id: '1',
  name: 'LTI FTW',
  url: 'https://canvas.instructure.com/lti',
})

export const ltiLaunchDefinition: Template<LtiLaunchDefinition> = template({
  definition_id: 42,
  placements: {
    course_navigation: {
      url: 'https://rollcall.instructure.com/launchy-launch',
    },
  },
})
