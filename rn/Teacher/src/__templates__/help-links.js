//
// Copyright (C) 2018-present Instructure, Inc.
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

import template, { type Template } from '../utils/template'

export const helpLink: Template<HelpLink> = template({
  id: '1',
  text: 'Custom Link!',
  type: 'custom',
  available_to: ['user', 'student'],
  url: 'https://google.com',
})

export const helpLinks: Template<HelpLinks> = template({
  help_link_name: 'Help and Policies',
  help_link_icon: 'help',
  default_help_links: [],
  custom_help_links: [helpLink()],
})
