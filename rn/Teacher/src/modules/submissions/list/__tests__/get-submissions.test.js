//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import { getSubmissionsProps, dueDate } from '../get-submissions-props'
import type { SubmissionDataProps } from '../submission-prop-types'
import * as t from '../../../../__templates__'
import { submissionProps as tsubmissionProps } from '../__templates__/submission-props'

export const submissionProps: Array<SubmissionDataProps> = [
  tsubmissionProps({
    name: 'S1',
    status: 'none',
    grade: 'not_submitted',
    userID: '1',
  }),
  tsubmissionProps({
    name: 'S2',
    status: 'none',
    grade: 'excused',
    userID: '2',
  }),
  tsubmissionProps({
    name: 'S3',
    status: 'late',
    grade: 'ungraded',
    userID: '3',
  }),
  tsubmissionProps({
    name: 'S4',
    status: 'submitted',
    grade: 'ungraded',
    userID: '4',
  }),
  tsubmissionProps({
    name: 'S6',
    status: 'none',
    grade: 'B+',
    userID: '6',
  }),
]

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
  }

  const submissions: SubmissionsState = {
    // S1 has not submitted
    '20': {
      submission: t.submissionHistory([{
        id: '20',
        user_id: '2',
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
    refs: ['0', '1', '2', '3', '4', '6'],
  }

  const courses = {
    '100': { enrollments: enrRefs },
  }

  const subRefs = { pending: 0, refs: ['20', '30', '40', '50'] }
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
    submissions: submissionProps,
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

  const courses = {
    '100': { enrollments: enrRefs },
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

test('due date with normal due date', () => {
  const assignment = t.assignment({
    due_at: 'normal',
  })

  expect(dueDate(assignment)).toEqual('normal')
})

test('due date with overrides', () => {
  const user = t.user()
  const assignment = t.assignment({
    overrides: [{
      student_ids: [user.id],
      due_at: 'override',
    }],
  })

  expect(dueDate(assignment, user)).toEqual('override')
})

test('due date with edge 1', () => {
  const user = t.user()
  const assignment = t.assignment({
    overrides: [{
      due_at: 'override',
    }],
    due_at: 'normal',
  })

  expect(dueDate(assignment, user)).toEqual('normal')
})

test('due date with edge 2', () => {
  const assignment = t.assignment({
    overrides: [{
      due_at: 'override',
      student_ids: ['1'],
    }],
    due_at: 'normal',
  })

  expect(dueDate(assignment)).toEqual('normal')
})
