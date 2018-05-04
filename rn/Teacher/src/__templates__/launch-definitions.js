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

import template, { type Template } from '../utils/template'

export const launchDefinitionGlobalNavigationItem: Template<ExternalToolLaunchDefinitionGlobalNavigationItem> = template({
  message_type: 'basic-lti-launch-request',
  url: 'https://mobiledev.beta.instructuremedia.com/lti/launch?custom_gauge_launch_type=global_nav',
  title: 'Gauge',
})

export const launchDefinition: Template<ExternalToolLaunchDefinition> = template({
  definition_type: 'ContextExternalTool',
  definition_id: '360860',
  name: 'Gauge',
  description: 'Tools for Education',
  domain: 'gauge.instructure.com',
  placements: {
    global_navigation: launchDefinitionGlobalNavigationItem(),
  },
})
