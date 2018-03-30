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

import { ToDoModel } from '../canvas-api/model'
import template, { type Template } from '../utils/template'
import { assignment } from './assignments'

export const toDoItem: Template<ToDoItem> = template({
  type: 'grading',
  assignment: assignment(),
  ignore: 'https://api.instructure.com/api/v1/path/to/ignore',
  ignore_permanently: 'https://api.instructure.com/api/v1/path/to/ignore_permanently',
  html_url: 'https://api.instructure.com/api/v1/path/to/html_url',
  needs_grading_count: 5,
  context_type: 'course',
  course_id: '1',
  group_id: null,
})

export const toDoModel: Template<ToDoModel> = overrides =>
  Object.assign(new ToDoModel(toDoItem()), overrides)
