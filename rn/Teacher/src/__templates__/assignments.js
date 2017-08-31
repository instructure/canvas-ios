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

export const assignment: Template<Assignment> = template({
  id: 123456789,
  course_id: 987654321,
  name: 'learn to write code',
  description: 'a course that can take any beginner to professional in a matter of microseconds.  Harness the power of your favorite languages like PHP and Cold Fusion.',
  due_at: '2037-06-01T05:59:00Z',
  unlock_at: '2017-03-17T06:00:00Z',
  lock_at: '2037-06-01T05:59:59Z',
  created_at: '2017-03-17T19:15:25Z',
  updated_at: '2017-03-17T19:15:25Z',
  points_possible: 20,
  grading_type: 'points',
  assignment_group_id: 1376,
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
})

export const assignmentGroup: Template<AssignmentGroup> = template({
  id: 1,
  name: 'Learn React Native',
  position: 1,
  assignments: [assignment()],
})

export const assignmentDueDate: Template<AssignmentDate> = template({
  due_at: '2037-06-01T05:59:00Z',
  unlock_at: '2017-03-17T06:00:00Z',
  lock_at: '2037-06-01T05:59:59Z',
})

export const assignmentOverride: Template<assignmentOverride> = template({
  due_at: '2037-06-01T05:59:00Z',
  unlock_at: '2017-03-17T06:00:00Z',
  lock_at: '2037-06-01T05:59:59Z',
})
