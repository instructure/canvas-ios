/**
 * @flow
 */

import 'react-native'
import mapStateToProps, { type AssigneeSearchProps } from '../map-state-to-props'

const template = {
  ...require('../__template__/Assignee.js'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../api/canvas-api/__templates__/enrollments'),
  ...require('../../../api/canvas-api/__templates__/section'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/react-native-navigation'),
}

test('correct output from map state to props', () => {
  let course = template.course()
  let enrollment = template.enrollment({
    course_id: course.id,
  })
  let section = template.section({
    course_id: course.id,
  })

  let state = template.appState({
    entities: {
      courses: {
        [course.id]: {
          course: course,
        },
      },
      assignmentGroups: {},
      assignments: {},
      gradingPeriods: {},
      enrollments: {
        [enrollment.id]: enrollment,
      },
      sections: {
        [section.id]: section,
      },
    },
  })

  const props: AssigneeSearchProps = {
    courseID: course.id,
    sections: [],
    enrollments: [],
    onSelection: jest.fn(),
    navigator: template.navigator(),
    refreshSections: jest.fn(),
    refreshEnrollments: jest.fn(),
  }

  const result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    enrollments: [enrollment],
    sections: [section],
  })
})
