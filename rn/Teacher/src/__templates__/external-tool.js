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

/* @flow */

import template, { type Template } from '../utils/template'

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
