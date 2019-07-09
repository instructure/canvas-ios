//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
