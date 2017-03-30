/* @flow */

import { mapStateToProps, type AssignmentDetailsProps } from '../map-state-to-props'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/react-native-navigation'),
  ...require('../../../redux/__templates__/app-state'),
}

test('map state to props should work', async () => {
  let course = template.course()
  let assignmentGroup = template.assignmentGroup()
  let assignment = template.assignment()

  let state = template.appState({
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
  })

  let props: AssignmentDetailsProps = {
    courseID: course.id.toString(),
    assignmentID: assignment.id.toString(),
    refreshAssignmentDetails: jest.fn(),
    pending: 0,
    navigator: template.navigator(),
    assignmentDetails: assignment,
    refresh: Function,
  }

  const result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    assignmentDetails: assignment,
  })
})

