/* @flow */

import template from '../../../utils/template'

export const assignment: Template<Assignment> = template({
  id: 123456789,
  name: 'learn to write code',
  description: 'a course that can take any beginner to professional in a matter of microseconds.  Harness the power of your favorite languages like PHP and Cold Fusion.',
  due_at: '2017-06-01T05:59:00Z',
  unlock_at: '2017-03-17T06:00:00Z',
  lock_at: '2017-06-01T05:59:59Z',
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
})

export const assignmentGroup: Template<AssignmentGroup> = template({
  id: 1,
  name: 'Learn React Native',
  position: 1,
  assignments: [assignment()],
})

export const assignmentDueDate: Template<AssignmentDate> = template({
  due_at: '2017-06-01T05:59:00Z',
  unlock_at: '2017-03-17T06:00:00Z',
  lock_at: '2017-06-01T05:59:59Z',
})
