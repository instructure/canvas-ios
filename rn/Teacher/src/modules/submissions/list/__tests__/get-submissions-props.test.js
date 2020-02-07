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

/* eslint-disable flowtype/require-valid-file-annotation */

import { gradeProp, statusProp, dueDate, getGroup, getSubmissionsProps } from '../get-submissions-props'
import app from '../../../app'
import * as template from '../../../../__templates__'

describe('GetSubmissionsProps gradeProp', () => {
  beforeEach(() => {
    app.setCurrentApp('teacher')
  })

  test('null submission', () => {
    const result = gradeProp(null)
    expect(result).toEqual('not_submitted')
  })

  test('unsubmitted submission', () => {
    const submission = template.submission({
      grade: null,
      submitted_at: null,
    })

    const result = gradeProp(submission)
    expect(result).toEqual('not_submitted')
  })

  test('excused submission', () => {
    const submission = template.submission({
      excused: true,
    })

    const result = gradeProp(submission)
    expect(result).toEqual('excused')
  })

  test('graded submission', () => {
    const grade = '33'
    const submission = template.submission({
      grade: grade,
      workflow_state: 'graded',
    })

    const result = gradeProp(submission)
    expect(result).toEqual(grade)
  })

  test('ungraded submission', () => {
    const submission = template.submission({
      grade_matches_current_submission: false,
    })

    const result = gradeProp(submission)
    expect(result).toEqual('ungraded')
  })

  test('pending review', () => {
    const submission = template.submission({
      grade: 12,
      workflow_state: 'pending_review',
    })
    expect(gradeProp(submission)).toEqual('ungraded')
  })

  describe('dueDate', () => {
    it('returns null if there is no assignment', () => {
      expect(dueDate(null, template.user())).toBeUndefined()
    })

    it('returns the assignment due_at if there are no overrides', () => {
      let assignment = template.assignment({
        overrides: undefined,
        due_at: '2019-04-03T17:37:02.051Z',
      })
      expect(dueDate(assignment, template.user())).toEqual('2019-04-03T17:37:02.051Z')
      assignment.overrides = []
      expect(dueDate(assignment, template.user())).toEqual('2019-04-03T17:37:02.051Z')
    })

    it('returns the assignment due at if there is no user or group', () => {
      let assignment = template.assignment({
        overrides: [template.assignmentOverride()],
        due_at: '2019-04-03T17:37:02.051Z',
      })
      expect(dueDate(assignment, null)).toEqual('2019-04-03T17:37:02.051Z')
    })

    it('returns the assignment due at if there is no override listing the student user id', () => {
      let assignment = template.assignment({
        overrides: [template.assignmentOverride({
          student_ids: ['1'],
        })],
        due_at: '2019-04-03T17:37:02.051Z',
      })
      let user = template.user({ id: '2' })
      expect(dueDate(assignment, user)).toEqual('2019-04-03T17:37:02.051Z')
    })

    it('returns the override when one for the user exists', () => {
      let assignment = template.assignment({
        overrides: [template.assignmentOverride({
          student_ids: ['1'],
          due_at: '2019-04-03T17:37:02.051Z',
        })],
      })
      let user = template.user({ id: '1' })
      expect(dueDate(assignment, user)).toEqual('2019-04-03T17:37:02.051Z')
    })

    it('returns the assignment due at if the override does not have a group id', () => {
      let assignment = template.assignment({
        overrides: [template.assignmentOverride({ group_id: undefined })],
        due_at: '2019-04-03T17:37:02.051Z',
      })
      let group = template.group({ id: '2' })
      expect(dueDate(assignment, template.user(), group)).toEqual('2019-04-03T17:37:02.051Z')
    })

    it('returns the assignment due at if the override does not match the group id', () => {
      let assignment = template.assignment({
        overrides: [template.assignmentOverride({ group_id: '1' })],
        due_at: '2019-04-03T17:37:02.051Z',
      })
      let group = template.group({ id: '2' })
      expect(dueDate(assignment, template.user(), group)).toEqual('2019-04-03T17:37:02.051Z')
    })

    it('returns the override due at when the group id matches the group', () => {
      let assignment = template.assignment({
        overrides: [template.assignmentOverride({
          group_id: '1',
          due_at: '2019-04-03T17:37:02.051Z',
        })],
      })
      let group = template.group({
        id: '1',
      })
      expect(dueDate(assignment, template.user(), group)).toEqual('2019-04-03T17:37:02.051Z')
    })
  })

  describe('getGroup', () => {
    it('returns the group from the id on the submission if the group exists', () => {
      let groupState = {
        '1': {
          group: template.group({ id: '1' }),
        },
      }
      let submission = template.submission({
        group: {
          id: '1',
          name: 'A test name',
        },
      })
      expect(getGroup(groupState, submission).id).toEqual('1')
    })

    it('returns nothing if the submission has no group and there is no group category id', () => {
      let groupState = {}
      let submission = template.submission({
        group: {
          id: null,
          name: null,
        },
      })
      expect(getGroup(groupState, submission)).toBeUndefined()
    })

    it('returns the group that includes the user and matches the group category id', () => {
      let groupState = {
        '1': { group: template.group({ id: '1' }) },
        '2': { group: template.group({
          id: '2',
          users: [template.user({ id: '1' })],
        }) },
        '3': { group: template.group({
          id: '3',
          users: [template.user({ id: '1' })],
          group_category_id: '1',
        }) },
      }
      let submission = template.submission({
        user_id: '1',
      })
      expect(getGroup(groupState, submission, '1').id).toEqual('3')
    })
  })

  describe('statusProp', () => {
    it('considers the submission missing if the flag is true', () => {
      const submission = template.submission({
        grade: 12,
        workflow_state: 'pending_review',
        missing: true,
      })
      const dueDate = '2018-04-11T05:59:00Z'
      expect(statusProp(submission, dueDate)).toEqual('missing')
    })

    it('considers null submission missing', () => {
      const dueDate = '2018-04-11T05:59:00Z'
      expect(statusProp(null, dueDate)).toEqual('missing')
    })

    it('considers worflow unsubmitted missing', () => {
      const submission = template.submission({
        grade: 12,
        workflow_state: 'unsubmitted',
      })

      const dueDate = new Date().toUTCString()
      expect(statusProp(submission, dueDate)).toEqual('missing')
    })

    it('considers pending_review submitted', () => {
      const submission = template.submission({
        grade: 12,
        workflow_state: 'pending_review',
      })
      const dueDate = '2018-04-11T05:59:00Z'
      expect(statusProp(submission, dueDate)).toEqual('submitted')
    })

    it('considers pending_review late is passed due date', () => {
      const submission = template.submission({
        grade: 12,
        workflow_state: 'pending_review',
        late: true,
      })
      const dueDate = '2018-04-11T05:59:00Z'
      expect(statusProp(submission, dueDate)).toEqual('late')
    })
  })

  it('returns grade for students', () => {
    app.setCurrentApp('student')
    const submission = template.submission({
      excused: false,
      grade: 'A-',
      submitted_at: '2018-04-11T05:59:00Z',
    })
    expect(gradeProp(submission)).toEqual('A-')
  })

  describe('getSubmissionsProps', () => {
    it('excludes inactive enrollments', () => {
      let courseID = '1'
      let assignmentID = '1'
      let activeEnrollment = template.enrollment({ id: '1', user_id: '1', enrollment_state: 'active' })
      let inactiveEnrollment = template.enrollment({ id: '2', user_id: '2', enrollment_state: 'inactive' })
      let entities = {
        courses: {
          [courseID]: {
            course: template.course({ id: courseID }),
            enrollments: {
              refs: ['1', '2'],
            },
          },
        },
        enrollments: {
          [activeEnrollment.id]: activeEnrollment,
          [inactiveEnrollment.id]: inactiveEnrollment,
        },
        assignments: {
          [assignmentID]: {
            data: template.assignment({ id: assignmentID }),
          },
        },
        submissions: {
          '1': {
            submission: template.submission({
              id: '1',
              assignment_id: assignmentID,
              user_id: activeEnrollment.user_id,
            }),
          },
          '2': {
            submission: template.submission({
              id: '2',
              assignment_id: assignmentID,
              user_id: inactiveEnrollment.user_id,
            }),
          },
        },
      }

      let props = getSubmissionsProps(entities, courseID, assignmentID)
      expect(props.submissions).toHaveLength(1)
      expect(props.submissions[0].userID).toEqual(activeEnrollment.user_id)
    })
  })
})
