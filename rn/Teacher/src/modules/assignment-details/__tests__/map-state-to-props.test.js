/* @flow */

import { mapStateToProps, updateMapStateToProps, type AssignmentDetailsProps } from '../map-state-to-props'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/react-native-navigation'),
  ...require('../../../redux/__templates__/app-state'),
}

test('map state to props assignment', async () => {
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
        [assignment.id]: { assignment: assignment, pending: 0 },
      },
      gradingPeriods: {},
    },
  })

  let props: AssignmentDetailsProps = {
    courseID: course.id,
    assignmentID: assignment.id,
    refreshAssignmentDetails: jest.fn(),
    navigator: template.navigator(),
    assignmentDetails: assignment,
    refresh: jest.fn(),
    refreshing: false,
    updateAssignment: Function,
  }

  const result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    assignmentDetails: assignment,
  })
})

test('map state to props update assignment', async () => {
  let course = template.course()
  let assignment = template.assignment()

  let state = template.appState({
    entities: {
      assignments: {
        [assignment.id]: { assignment: assignment, pending: 0 },
      },
    },
  })

  let props: AssignmentDetailsProps = {
    courseID: course.id,
    assignmentID: assignment.id,
    refreshAssignmentDetails: jest.fn(),
    navigator: template.navigator(),
    assignmentDetails: assignment,
    refresh: jest.fn(),
    refreshing: false,
    updateAssignment: Function,
  }

  const result = updateMapStateToProps(state, props)
  expect(result).toMatchObject({
    assignmentDetails: assignment,
    pending: 0,
  })
})
