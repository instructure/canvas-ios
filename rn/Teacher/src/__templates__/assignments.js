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

/* @flow */

import template, { type Template } from '../utils/template'

export const assignment: Template<Assignment> = template({
  id: '123456789',
  course_id: '987654321',
  name: 'learn to write code',
  description: 'a course that can take any beginner to professional in a matter of microseconds.  Harness the power of your favorite languages like PHP and Cold Fusion.',
  due_at: '2037-06-01T05:59:00Z',
  unlock_at: '2017-03-17T06:00:00Z',
  lock_at: '2037-06-01T05:59:59Z',
  created_at: '2017-03-17T19:15:25Z',
  updated_at: '2017-03-17T19:15:25Z',
  points_possible: 20,
  grading_type: 'points',
  assignment_group_id: '1376',
  peer_reviews: false,
  automatic_peer_reviews: false,
  position: 1,
  submission_types:
  [ 'online_text_entry',
    'online_url',
    'media_recording',
    'online_upload' ],
  needs_grading_count: 0,
  html_url: 'http://hostname.tld/whatever',
  overrides: [],
  grade_group_students_individually: false,
  group_category_id: null,
  has_overrides: false,
  only_visible_to_overrides: false,
  published: true,
  unpublishable: false,
  rubric_assessment: {},
  rubric_settings: null,
  rubric: null,
  anonymize_students: false,
})

export const assignmentGroup: Template<AssignmentGroup> = template({
  id: '1',
  name: 'Learn React Native',
  position: 1,
  assignments: [assignment({ assignment_group_id: '1' })],
  group_weight: 1,
  integration_data: {},
  sis_source_id: '',
})

export const assignmentDueDate: Template<AssignmentDate> = template({
  title: 'due',
  due_at: '2037-06-01T05:59:00Z',
  unlock_at: '2017-03-17T06:00:00Z',
  lock_at: '2037-06-01T05:59:59Z',
})

export const assignmentOverride: Template<AssignmentOverride> = template({
  id: '1',
  assignment_id: '1',
  student_ids: [],
  group_id: '1',
  course_section_id: '1',
  title: 'override',
  all_day: false,
  all_date_date: '',
  due_at: '2037-06-01T05:59:00Z',
  unlock_at: '2017-03-17T06:00:00Z',
  lock_at: '2037-06-01T05:59:59Z',
})
