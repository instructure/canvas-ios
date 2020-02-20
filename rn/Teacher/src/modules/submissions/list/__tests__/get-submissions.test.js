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

import { getSubmissionsProps } from '../get-submissions-props'
import * as t from '../../../../__templates__'
import { submissionProps } from '../__templates__/submission-props'

test('submissions', () => {
  const enrollments: EnrollmentsState = {
    '0': t.enrollment({ id: '0', user_id: '0', type: 'TeacherEnrollment' }),
    '1': t.enrollment({ id: '1', user_id: '1', user: t.user({ id: '1', name: 'S1', sortable_name: 'S1' }) }),
    '2': t.enrollment({ id: '2', user_id: '2', user: t.user({ id: '2', name: 'S2', sortable_name: 'S2' }) }),
    '3': t.enrollment({ id: '3', user_id: '3', user: t.user({ id: '3', name: 'S3', sortable_name: 'S3' }) }),
    '4': t.enrollment({ id: '4', user_id: '4', user: t.user({ id: '4', name: 'S4', sortable_name: 'S4' }) }),
    // user in two sections or as a TA & Student
    '5': t.enrollment({ id: '5', user_id: '4', user: t.user({ id: '4', name: 'S4', sortable_name: 'S4' }) }),
    '6': t.enrollment({ id: '6', user_id: '6', user: t.user({ id: '6', name: 'S6', sortable_name: 'S6' }) }),
    // user in two sections where one is inactive
    '7': t.enrollment({ id: '7', user_id: '7', enrollment_state: 'inactive', course_section_id: '2', user: t.user({ id: '7', name: 'S7', sortable_name: 'S7' }) }),
    '8': t.enrollment({ id: '8', user_id: '7', user: t.user({ id: '7', name: 'S7', sortable_name: 'S7' }) }),
  }

  const submissions: SubmissionsState = {
    '10': {
      submission: t.submissionHistory([{
        id: '10',
        user_id: '1',
        assignment_id: '1000',
        grade: undefined,
        submitted_at: undefined,
        workflow_state: 'unsubmitted',
        attempt: null,
        missing: false,
        excused: false,
        late: false,
      }]),
      pending: 0,
      error: null,
      selectedIndex: null,
      selectedAttachmentIndex: null,
      rubricGradePending: false,
    },
    '20': {
      submission: t.submissionHistory([{
        id: '20',
        user_id: '2',
        assignment_id: '1000',
        grade: undefined,
        submitted_at: undefined,
        workflow_state: 'unsubmitted',
        attempt: null,
        missing: true,
        excused: true,
        late: true,
      }]),
      pending: 0,
      error: null,
      selectedIndex: null,
      selectedAttachmentIndex: null,
      rubricGradePending: false,
    },
    '30': {
      submission: t.submissionHistory([{
        id: '30',
        user_id: '3',
        assignment_id: '1000',
        grade: undefined,
        submitted_at: '2017-04-05T15:12:45Z',
        workflow_state: 'submitted',
        attempt: 1,
        excused: false,
        late: true,
      }]),
      pending: 0,
      error: null,
      selectedIndex: null,
      selectedAttachmentIndex: null,
      rubricGradePending: false,
    },
    '40': {
      submission: t.submissionHistory([{
        id: '40',
        user_id: '4',
        assignment_id: '1000',
        grade: null,
        submitted_at: '2017-04-05T15:12:45Z',
        workflow_state: 'submitted',
        attempt: 1,
        excused: false,
        late: false,
      }]),
      pending: 0,
      error: null,
      selectedIndex: null,
      selectedAttachmentIndex: null,
      rubricGradePending: false,
    },
    '50': {
      submission: t.submissionHistory([{
        id: '50',
        user_id: '6',
        assignment_id: '1000',
        grade: 'B+',
        workflow_state: 'graded',
        attempt: null,
        missing: true,
        excused: false,
        late: false,
      }]),
      pending: 0,
      error: null,
      selectedIndex: null,
      selectedAttachmentIndex: null,
      rubricGradePending: false,
    },
  }

  const enrRefs = { pending: 0,
    refs: ['0', '1', '2', '3', '4', '6', '7', '8'],
  }

  const groupRefs = { pending: 0 }

  const courses = {
    '100': {
      enrollments: enrRefs,
      groups: groupRefs,
    },
  }

  const subRefs = { pending: 0, refs: ['10', '20', '30', '40', '50'] }
  const assignments = {
    '1000': {
      data: t.assignment({
        id: '1000',
      }),
      submissions: subRefs,
    },
  }

  const template = t.appState()
  const state = t.appState({
    entities: {
      ...template.entities,
      enrollments,
      submissions,
      courses,
      assignments,
    },
  })
  expect(getSubmissionsProps(state.entities, '100', '1000')).toMatchObject({
    submissions: [
      submissionProps({
        name: 'S1',
        status: 'none',
        grade: 'not_submitted',
        userID: '1',
        submission: submissions['10'].submission,
      }),
      submissionProps({
        name: 'S2',
        status: 'none',
        grade: 'excused',
        userID: '2',
        submission: submissions['20'].submission,
      }),
      submissionProps({
        name: 'S3',
        status: 'late',
        grade: 'ungraded',
        userID: '3',
        submission: submissions['30'].submission,
      }),
      submissionProps({
        name: 'S4',
        status: 'submitted',
        grade: 'ungraded',
        userID: '4',
        submission: submissions['40'].submission,
      }),
      submissionProps({
        name: 'S6',
        status: 'none',
        grade: 'B+',
        userID: '6',
        submission: submissions['50'].submission,
      }),
    ],
    pending: false,
  })
})

test('doesnt return submissions if we have enrollments but no submissions yet', () => {
  const enrollments: EnrollmentsState = {
    '1': t.enrollment({ id: '1', user_id: '1', user: t.user({ id: '1', name: 'S1', sortable_name: 'S1' }) }),
  }

  const submissions: SubmissionsState = {}

  const enrRefs = { pending: 0,
    refs: ['1'],
  }

  const groupRefs = { pending: 0 }

  const courses = {
    '100': {
      enrollments: enrRefs,
      groups: groupRefs,
    },
  }

  const subRefs = { pending: 0, refs: [] }
  const assignments = {
    '1000': { submissions: subRefs },
  }

  const template = t.appState()
  const state = t.appState({
    entities: {
      ...template.entities,
      enrollments,
      submissions,
      courses,
      assignments,
    },
  })
  expect(getSubmissionsProps(state.entities, '100', '1000')).toMatchObject({
    submissions: [],
    pending: false,
  })
})

test('can work on group assignments', () => {
  const enrollments: EnrollmentsState = {
    '1': t.enrollment({ id: '1', user_id: '1', user: t.user({ id: '1', name: 'S1', sortable_name: 'S1' }) }),
    '2': t.enrollment({ id: '2', user_id: '2', user: t.user({ id: '2', name: 'S2', sortable_name: 'S2' }) }),
    '3': t.enrollment({ id: '3', user_id: '3', user: t.user({ id: '3', name: 'S3', sortable_name: 'S3' }) }),
  }

  const submissions: SubmissionsState = {
    '10': {
      submission: t.submissionHistory([{
        id: '10',
        user_id: '1',
        assignment_id: '1000',
        grade: undefined,
        submitted_at: undefined,
        workflow_state: 'unsubmitted',
        attempt: null,
        missing: false,
        excused: false,
        late: false,
        group: {
          id: '1',
          name: 'Group 1',
        },
      }]),
      pending: 0,
      error: null,
      selectedIndex: null,
      selectedAttachmentIndex: null,
      rubricGradePending: false,
    },
    '30': {
      submission: t.submissionHistory([{
        id: '30',
        user_id: '3',
        assignment_id: '1000',
        grade: undefined,
        submitted_at: undefined,
        workflow_state: 'unsubmitted',
        attempt: null,
        missing: true,
        excused: true,
        late: true,
        group: {
          id: null,
          name: null,
        },
      }]),
      pending: 0,
      error: null,
      selectedIndex: null,
      selectedAttachmentIndex: null,
      rubricGradePending: false,
    },
  }

  const enrRefs = { pending: 0,
    refs: ['1', '2', '3'],
  }

  const groupRefs = {
    pending: 0,
    refs: ['1'],
  }

  const courses = {
    '100': {
      enrollments: enrRefs,
      groups: groupRefs,
    },
  }

  const subRefs = { pending: 0, refs: ['10', '20'] }
  const assignments = {
    '1000': {
      data: t.assignment({
        id: '1000',
        group_category_id: '1',
        grade_group_students_individually: false,
      }),
      submissions: subRefs,
    },
  }

  const groups = {
    '1': {
      group: t.group({
        id: '1',
        name: 'Group 1',
      }),
    },
  }

  const template = t.appState()
  const state = t.appState({
    entities: {
      ...template.entities,
      groups,
      enrollments,
      submissions,
      courses,
      assignments,
    },
  })
  let { submissions: mixedSubmissionProps } = getSubmissionsProps(state.entities, '100', '1000')
  expect(mixedSubmissionProps.length).toEqual(2)
  expect(mixedSubmissionProps[0].name).toEqual('Group 1')
  expect(mixedSubmissionProps[0].groupID).toEqual('1')
  expect(mixedSubmissionProps[1].userID).toEqual('3')
})
