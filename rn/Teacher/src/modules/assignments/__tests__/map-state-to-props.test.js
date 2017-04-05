/* @flow */

import { mapStateToProps, type AssignmentListProps } from '../map-state-to-props'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../api/canvas-api/__templates__/grading-periods'),
  ...require('../../../__templates__/react-native-navigation'),
  ...require('../../../redux/__templates__/app-state'),
}

test('map state to props should work', async () => {
  let course = template.course()
  let assignmentGroup = template.assignmentGroup()
  let gradingPeriod = template.gradingPeriod({ id: 1 })
  let gradingPeriodTwo = template.gradingPeriod({ id: 2 })

  let state = template.appState({
    entities: {
      courses: {
        [course.id]: {
          assignmentGroups: { refs: [assignmentGroup.id] },
          course: course,
          color: 'blueish',
        },
      },
      assignmentGroups: {
        [assignmentGroup.id]: assignmentGroup,
      },
      gradingPeriods: {
        [gradingPeriod.id]: {
          gradingPeriod,
          assignmentRefs: [assignmentGroup.assignments[0].id],
        },
        [gradingPeriodTwo.id]: {
          gradingPeriod: gradingPeriodTwo,
          assignmentRefs: [],
        },
      },
    },
    favoriteCourses: [],
  })

  let props: AssignmentListProps = {
    courseID: course.id,
    course: {
      course,
      color: '#fff',
    },
    assignmentGroups: [],
    updateAssignment: jest.fn(),
    refreshAssignmentList: jest.fn(),
    refreshGradingPeriods: jest.fn(),
    refresh: jest.fn(),
    pending: 0,
    navigator: template.navigator(),
    gradingPeriods: [],
    courseColor: 'greenish',
  }

  const result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    assignmentGroups: [assignmentGroup],
    gradingPeriods: [{
      ...gradingPeriod,
      assignmentRefs: [assignmentGroup.assignments[0].id],
    }, {
      ...gradingPeriodTwo,
      assignmentRefs: [],
    }],
    courseColor: 'blueish',
  })
})
