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

import { mapStateToProps } from '../map-state-to-props'
import type { SubmissionDataProps } from '../submission-prop-types'
import shuffle from 'knuth-shuffle-seeded'

jest.mock('knuth-shuffle-seeded', () => jest.fn())

let t = {
  ...require('../../../../__templates__/assignments'),
  ...require('../../../../__templates__/course'),
  ...require('../../../../__templates__/submissions'),
  ...require('../../../../__templates__/enrollments'),
  ...require('../../../../__templates__/users'),
  ...require('../../../../__templates__/assignments'),
  ...require('../../../../__templates__/group'),
  ...require('../../../../__templates__/section'),
  ...require('../../../../redux/__templates__/app-state'),
  ...require('../__templates__/submission-props'),
}

const submissionProps: Array<SubmissionDataProps> = [
  t.submissionProps({
    name: 'S1',
    status: 'none',
    grade: 'not_submitted',
    userID: '1',
  }),
  t.submissionProps({
    name: 'S2',
    status: 'none',
    grade: 'excused',
    userID: '2',
  }),
  t.submissionProps({
    name: 'S3',
    status: 'late',
    grade: 'ungraded',
    userID: '3',
  }),
  t.submissionProps({
    name: 'S4',
    status: 'submitted',
    grade: 'A-',
    userID: '4',
  }),
]

function createHappyPathTestState () {
  const enrollments: EnrollmentsState = {
    '0': t.enrollment({ id: '0', user_id: '0', type: 'TeacherEnrollment' }),
    '1': t.enrollment({ id: '1', user_id: '1', user: t.user({ id: '1', name: 'S1', sortable_name: 'S1' }) }),
    '2': t.enrollment({ id: '2', user_id: '2', user: t.user({ id: '2', name: 'S2', sortable_name: 'S2' }) }),
    '3': t.enrollment({ id: '3', user_id: '3', user: t.user({ id: '3', name: 'S3', sortable_name: 'S3' }) }),
    '4': t.enrollment({ id: '4', user_id: '4', user: t.user({ id: '4', name: 'S4', sortable_name: 'S4' }) }),
    // user in two sections or as a TA & Student
    '5': t.enrollment({ id: '5', user_id: '4', user: t.user({ id: '4', name: 'S4', sortable_name: 'S5' }) }),
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
        grade: 'A-',
        submitted_at: '2017-04-05T15:12:45Z',
        workflow_state: 'graded',
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
    refs: ['0', '1', '2', '3', '4'],
  }

  const courses = {
    '100': { enrollments: enrRefs, color: '#000', course: { name: 'fancy name' }, enabledFeatures: [] },
  }

  const subRefs = { pending: 0, refs: ['20', '30', '40'] }
  const assignments = {
    '1000': {
      submissions: subRefs,
      data: t.assignment({
        points_possible: 5,
        muted: true,
        name: "Trump's Tweets",
      }),
      anonymousGradingOn: false,
    },
  }

  return t.appState({
    entities: {
      enrollments,
      submissions,
      courses,
      assignments,
      sections: [t.section({ course_id: '100' })],
    },
  })
}

beforeEach(() => jest.resetAllMocks())

test('submissions', () => {
  let state = createHappyPathTestState()
  expect(mapStateToProps(state, { courseID: '100', assignmentID: '1000' })).toMatchObject({
    courseColor: '#000',
    courseName: 'fancy name',
    pending: false,
    submissions: submissionProps,
    pointsPossible: 5,
    anonymous: false,
    muted: true,
  })
})

test('submissions with missing data', () => {
  const state = t.appState({
    entities: {
      enrollments: {},
      submissions: {},
      courses: {},
      assignments: {},
      sections: [],
    },
  })

  expect(mapStateToProps(state, { courseID: '100', assignmentID: '1000' })).toMatchObject({
    courseColor: '#FFFFFF',
    courseName: '',
    pending: true,
  })
})

test('anonymous grading on shuffles the data', () => {
  let state = createHappyPathTestState()
  state.entities.assignments['1000'].anonymousGradingOn = true

  let props = mapStateToProps(state, { courseID: '100', assignmentID: '1000' })
  expect(props.anonymous).toEqual(true)
  expect(shuffle).toHaveBeenCalled()
})

test('course level anonymous grading shuffles the data', () => {
  let state = createHappyPathTestState()
  state.entities.courses['100'].enabledFeatures = ['anonymous_grading']

  let props = mapStateToProps(state, { courseID: '100', assignmentID: '1000' })
  expect(props.anonymous).toEqual(true)
  expect(shuffle).toHaveBeenCalled()
})

test('filters out StudentViewEnrollment', () => {
  const student = t.enrollment({ id: '1', type: 'StudentEnrollment', user_id: '1' })
  const testStudent = t.enrollment({ id: '2', type: 'StudentViewEnrollment', user_id: '2' })
  const course = t.course()
  const assignment = t.assignment()
  const submission = t.submissionHistory([t.submission({ id: '1', user_id: '1', assignment_id: assignment.id })])
  const state = t.appState({
    entities: {
      enrollments: {
        [student.id]: student,
        [testStudent.id]: testStudent,
      },
      courses: {
        [course.id]: {
          enrollments: { pending: 0, refs: [student.id, testStudent.id] },
          enabledFeatures: [],
        },
      },
      assignments: {
        [assignment.id]: {
          submissions: { pending: 0, refs: ['1'] },
          data: assignment,
        },
      },
      sections: [t.section({ course_id: course.id })],
      submissions: {
        '1': {
          submission,
        },
      },
    },
  })
  const result = mapStateToProps(state, { courseID: course.id, assignmentID: assignment.id })
  expect(result.submissions.map(u => u.userID)).toEqual(['1'])
})

test('gets all submissions if group doesnt exist', () => {
  const s1 = t.enrollment({
    id: '1',
    type: 'StudentEnrollment',
    user_id: '1',
    user: t.user({ id: '1' }),
  })
  const s2 = t.enrollment({
    id: '2',
    type: 'StudentEnrollment',
    user_id: '2',
    user: t.user({ id: '2' }),
  })
  const course = t.course()
  const assignment = t.assignment({
    group_category_id: '555',
  })
  const submission = t.submissionHistory([t.submission({ user_id: '1', assignment_id: assignment.id })])
  const submission2 = t.submissionHistory([t.submission({ user_id: '2', assignment_id: assignment.id })])
  const state = t.appState({
    entities: {
      enrollments: {
        [s1.id]: s1,
        [s2.id]: s2,
      },
      courses: {
        [course.id]: {
          enrollments: { pending: 0, refs: [s1.id, s2.id] },
          groups: { pending: 0, refs: ['1'] },
          enabledFeatures: [],
        },
      },
      assignments: {
        [assignment.id]: {
          submissions: { pending: 0, refs: ['1', '2'] },
          data: assignment,
        },
      },
      groups: {
        '1': {
          group: t.group({ group_category_id: '111' }),
        },
      },
      sections: [t.section({ course_id: course.id })],
      submissions: {
        '1': {
          submission,
        },
        '2': {
          submission: submission2,
        },
      },
    },
  })
  const { submissions } = mapStateToProps(state, { courseID: course.id, assignmentID: assignment.id })
  const userIDs = submissions.map(u => u.userID)
  expect(userIDs).toContain('1')
  expect(userIDs).toContain('2')
})

test('detect missing groups data', () => {
  const s1 = t.enrollment({
    id: '1',
    type: 'StudentEnrollment',
    user_id: '1',
    user: t.user({ id: '1' }),
  })
  const s2 = t.enrollment({
    id: '2',
    type: 'StudentEnrollment',
    user_id: '2',
    user: t.user({ id: '2' }),
  })
  const course = t.course()
  const assignment = t.assignment({
    group_category_id: '555',
    grade_group_students_individually: false,
  })
  const submission = t.submissionHistory([t.submission({ user_id: '1', assignment_id: assignment.id })])
  const submission2 = t.submissionHistory([t.submission({ user_id: '2', assignment_id: assignment.id })])
  const state = t.appState({
    entities: {
      enrollments: {
        [s1.id]: s1,
        [s2.id]: s2,
      },
      courses: {
        [course.id]: {
          enrollments: { pending: 0, refs: [s1.id, s2.id] },
          groups: { pending: 0, refs: ['1'] },
          enabledFeatures: [],
        },
      },
      assignments: {
        [assignment.id]: {
          submissions: { pending: 0, refs: ['1', '2'] },
          data: assignment,
        },
      },
      groups: { },
      sections: [t.section({ course_id: course.id })],
      submissions: {
        '1': {
          submission,
        },
        '2': {
          submission: submission2,
        },
      },
    },
  })

  const { isMissingGroupsData, isGroupGradedAssignment } = mapStateToProps(state, { courseID: course.id, assignmentID: assignment.id })
  expect(isMissingGroupsData).toBe(true)
  expect(isGroupGradedAssignment).toBe(false) // Should be true but is false because we are missing the entities.groups lookup data
})
