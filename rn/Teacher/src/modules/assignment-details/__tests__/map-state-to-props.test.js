/* @flow */

import { mapStateToProps, type AssignmentDetailsProps } from '../map-state-to-props'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/react-native-navigation'),
}

test('map state to props should work', async () => {
  let course = template.course()
  let assignmentGroup = template.assignmentGroup()
  let assignment = template.assignment()

  let state: AppState = {
    entities: {
      courses: {
        [course.id]: {
          assignmentGroups: { refs: [assignmentGroup.id] },
          course: course,
        },
      },
      assignmentGroups: {
        [assignmentGroup.id]: assignmentGroup,
      },
      assignments: {
        [assignment.id]: assignment,
      },
    },
    favoriteCourses: [],
  }

  let props: AssignmentDetailsProps = {
    courseID: course.id.toString(),
    assignmentID: assignment.id.toString(),
    refreshAssignmentDetails: jest.fn(),
    pending: 0,
    navigator: template.navigator(),
    assignmentDetails: assignment,
  }

  const result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    assignmentDetails: assignment,
  })
})

