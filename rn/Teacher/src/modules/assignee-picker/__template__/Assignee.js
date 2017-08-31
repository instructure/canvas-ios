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

import template, { type Template } from '../../../utils/template'
import { type Assignee } from '../map-state-to-props'

export const enrollmentAssignee: Template<Assignee> = template({
  id: 'student-1234',
  dataId: '1234',
  type: 'student',
  name: 'Bill Murray',
  info: 'john@schimdt.com',
  imageURL: 'http://www.fillmurray.com/100/100',
})

export const sectionAssignee: Template<Assignee> = template({
  id: 'section-1234',
  dataId: '1234',
  type: 'section',
  name: 'Section 1',
  info: '9834 students',
})

export const groupAssignee: Template<Assignee> = template({
  id: 'group-1234',
  dataId: '1234',
  type: 'group',
  name: 'Horrible Students',
  info: '889334 students',
})

export const everyoneAssignee: Template<Assignee> = template({
  id: 'everyone',
  dataId: 'everyone',
  type: 'everyone',
  name: 'Everyone',
})
