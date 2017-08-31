// @flow

import { getGroupSubmissionProps } from '../get-group-submission-props'

const t = {
  ...require('../../../../__templates__/assignments'),
  ...require('../../../../__templates__/course'),
  ...require('../../../../__templates__/group'),
  ...require('../../../../__templates__/users'),
  ...require('../../../../redux/__templates__/app-state'),
  ...require('../../../../__templates__/submissions'),
}

test('getGroupSubmissionProps', () => {
  const course = t.course()
  const { group_category_id } = { group_category_id: '441' }
  const assignment = t.assignment({
    group_category_id,
    grade_group_students_individually: false,
  })
  const red = t.group({
    group_category_id,
    name: 'Red Squadron',
    id: '5',
    users: [ t.user({ id: '76' }) ],
  })
  const yellow = t.group({
    group_category_id,
    name: 'Yellow Squadron',
    id: '3',
    users: [ t.user({ id: '39' }) ],
  })
  const blue = t.group({
    group_category_id,
    name: 'Blue Squadron',
    id: '2',
    users: [ t.user({ id: '72' }) ],
  })
  const gray = t.group({ name: 'Gray Team', id: '44' })
  const groups = [red, yellow, blue, gray].reduce((groups, group) => {
    return { ...groups, [group.id]: { group } }
  }, {})

  let submission = t.submissionHistory([{
    group: red,
  }])

  let state = t.appState({
    entities: {
      courses: {
        [course.id]: {
          course,
          groups: { pending: 0, refs: ['5', '3', '2'] },
        },
      },
      assignments: {
        [assignment.id]: {
          data: assignment,
          submissions: { pending: 0, refs: [submission.id] },
        },
      },
      submissions: {
        [submission.id]: { submission },
      },
      groups,
    },
  })
  expect(getGroupSubmissionProps(state.entities, course.id, assignment.id)).toMatchObject({
    pending: false,
    submissions: [
      {
        userID: '76',
        groupID: '5',
        name: 'Red Squadron',
        status: 'submitted',
        grade: 'B-',
        score: undefined,
        submissionID: '32',
        submission,
      },
      {
        userID: '39',
        groupID: '3',
        name: 'Yellow Squadron',
        status: 'none',
        grade: 'not_submitted',
        score: null,
        submissionID: null,
        submission: undefined,
      },
      {
        userID: '72',
        groupID: '2',
        name: 'Blue Squadron',
        status: 'none',
        grade: 'not_submitted',
        score: null,
        submissionID: null,
        submission: undefined,
      },
    ],
  })
})
