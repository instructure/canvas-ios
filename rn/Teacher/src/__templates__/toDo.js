// @flow

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
