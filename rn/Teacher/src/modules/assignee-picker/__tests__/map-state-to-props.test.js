/**
 * @flow
 */

import 'react-native'
import { searchMapStateToProps, pickerMapStateToProps, type AssigneeSearchProps, type AssigneePickerProps } from '../map-state-to-props'

const template = {
  ...require('../__template__/Assignee.js'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/enrollments'),
  ...require('../../../api/canvas-api/__templates__/section'),
  ...require('../../../api/canvas-api/__templates__/group'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../__templates__/helm'),
}

test('correct output from searchMapStateToProps', () => {
  let course = template.course()
  let assignment = template.assignment({
    group_category_id: '9999',
  })
  let group = template.group({
    group_category_id: '9999',
  })
  let enrollmentOne = template.enrollment({
    id: '1',
    course_id: course.id,
  })
  let enrollmentTwo = template.enrollment({
    id: '2',
    course_id: course.id,
    type: 'TeacherEnrollment',
  })
  let enrollmentThree = template.enrollment({
    id: '3',
    course_id: course.id,
    enrollment_state: 'inactive',
  })
  let enrollmentFour = template.enrollment({
    id: '4',
    course_id: '87987987349857394875934875',
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
      assignments: {
        [assignment.id]: {
          data: assignment,
        },
      },
      gradingPeriods: {},
      enrollments: {
        [enrollmentOne.id]: enrollmentOne,
        [enrollmentTwo.id]: enrollmentTwo,
        [enrollmentThree.id]: enrollmentThree,
        [enrollmentFour.id]: enrollmentFour,
      },
      sections: {
        [section.id]: section,
      },
      groups: {
        [group.id]: {
          group,
        },
        '999999': {},
      },
    },
  })

  const props: AssigneeSearchProps = {
    courseID: course.id,
    assignmentID: assignment.id,
    assignment,
    sections: [],
    enrollments: [],
    groups: [],
    onSelection: jest.fn(),
    navigator: template.navigator(),
    refreshSections: jest.fn(),
    refreshEnrollments: jest.fn(),
    refreshGroupsForCategory: jest.fn(),
  }

  const result = searchMapStateToProps(state, props)
  expect(result).toMatchObject({
    enrollments: [enrollmentOne, enrollmentThree],
    sections: [section],
  })
})

test('correct output from pickerMapStateToProps', () => {
  let course = template.course()
  let assignment = template.assignment()
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
      users: {
        [enrollment.user_id]: enrollment.user,
      },
    },
  })

  let assigneeOne = template.enrollmentAssignee({
    dataId: enrollment.user_id,
  })

  let assigneeTwo = template.sectionAssignee({
    dataId: section.id,
  })

  let assigneeThree = template.everyoneAssignee()

  let props: AssigneePickerProps = {
    courseID: course.id,
    assignmentID: assignment.id,
    assignees: [assigneeOne, assigneeTwo, assigneeThree],
    callback: jest.fn(),
    navigator: template.navigator(),
    refreshUsers: jest.fn(),
    refreshSections: jest.fn(),
  }

  let result = pickerMapStateToProps(state, props)
  expect(result).toMatchObject({
    assignees: [{
      dataId: enrollment.user_id,
      name: 'Donald Trump',
    },
    {
      name: 'the section 1',
      dataId: section.id,
    },
    {
      dataId: 'everyone',
      name: 'Everyone else',
    }],
  })

  props.assignees = [assigneeThree]
  result = pickerMapStateToProps(state, props)
  expect(result).toMatchObject({
    assignees: [
      {
        dataId: 'everyone',
        name: 'Everyone',
      }],
  })

  state = template.appState({
    entities: {
      courses: {
        [course.id]: {
          course: course,
        },
      },
      assignmentGroups: {},
      assignments: {},
      gradingPeriods: {},
      enrollments: {},
      sections: {},
      users: {},
    },
  })

  // This tests the cases where the data is missing in the global app state
  props.assignees = [assigneeOne, assigneeTwo, assigneeThree]
  result = pickerMapStateToProps(state, props)
  expect(result).toMatchObject({
    assignees: [{
      dataId: enrollment.user_id,
      name: 'Bill Murray',
    },
    {
      name: 'Section 1',
      dataId: section.id,
    },
    {
      dataId: 'everyone',
      name: 'Everyone else',
    }],
  })
})

test('pickerMapStateToProps should not explode when user data is missing', () => {
  let course = template.course()
  let assignment = template.assignment()
  let state = template.appState()

  let enrollment = template.enrollment({
    course_id: course.id,
  })

  let assigneeOne = template.enrollmentAssignee({
    dataId: enrollment.user_id,
  })

  let props: AssigneePickerProps = {
    courseID: course.id,
    assignmentID: assignment.id,
    assignees: [assigneeOne],
    callback: jest.fn(),
    navigator: template.navigator(),
    refreshUsers: jest.fn(),
    refreshSections: jest.fn(),
  }

  let result = pickerMapStateToProps(state, props)
  expect(result).toMatchObject({})
})
