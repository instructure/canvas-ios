/* @flow */

import { mapStateToProps, updateMapStateToProps, type AssignmentDetailsProps } from '../map-state-to-props'

const template = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/helm'),
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
        [assignment.id]: { data: assignment, pending: 0 },
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
    updateAssignment: jest.fn(),
    refreshAssignment: jest.fn(),
    cancelAssignmentUpdate: jest.fn(),
    getSessionlessLaunchURL: jest.fn(),
  }

  const result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    assignmentDetails: assignment,
    courseName: course.name,
  })
})

test('map state to props without course', async () => {
  let course = template.course()
  let assignmentGroup = template.assignmentGroup()
  let assignment = template.assignment()

  let state = template.appState({
    entities: {
      courses: {
        [course.id]: {
          assignmentGroups: { refs: [assignmentGroup.id] },
        },
      },
      assignmentGroups: {
        [assignmentGroup.id]: assignmentGroup,
      },
      assignments: {
        [assignment.id]: { data: assignment, pending: 0 },
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
    updateAssignment: jest.fn(),
    refreshAssignment: jest.fn(),
    cancelAssignmentUpdate: jest.fn(),
    getSessionlessLaunchURL: jest.fn(),
  }

  const result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    assignmentDetails: assignment,
    courseName: '',
  })
})

test('map state to props update assignment', async () => {
  let course = template.course()
  let assignment = template.assignment()
  let assignmentGroup = template.assignmentGroup()

  let state = template.appState({
    entities: {
      assignments: {
        [assignment.id]: { data: assignment, pending: 0 },
      },
      courses: {
        [course.id]: {
          assignmentGroups: { refs: [assignmentGroup.id] },
          course: course,
        },
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
    updateAssignment: jest.fn(),
    refreshAssignment: jest.fn(),
    cancelAssignmentUpdate: jest.fn(),
    getSessionlessLaunchURL: jest.fn(),
  }

  const result = updateMapStateToProps(state, props)
  expect(result).toMatchObject({
    assignmentDetails: assignment,
    pending: 0,
  })
})
