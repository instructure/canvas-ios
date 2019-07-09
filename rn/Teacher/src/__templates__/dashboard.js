//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
