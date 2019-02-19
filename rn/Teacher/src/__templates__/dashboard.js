//
// Copyright (C) 2019-present Instructure, Inc.
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

export const dashboardCardLink: Template<DashboardCardLink> = template({
  css_class: 'assignments',
  hidden: null,
  icon: 'icon-assignment',
  label: 'Assignments',
  path: '/courses/1/assignments',
})

export const dashboardCard: Template<DashboardCard> = template({
  assetString: 'course_1',
  courseCode: 'MET-132',
  enrollmentType: 'StudentEnrollment',
  href: '/courses/1',
  id: '1',
  image: null,
  links: [dashboardCardLink()],
  longName: 'A good course - MET',
  originalName: 'A good course',
  position: null,
  shortName: 'A good course',
  subtitle: 'enrolled as: Student',
  term: null,
})
