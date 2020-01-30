//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import 'react-native'
import { searchMapStateToProps, pickerMapStateToProps, type AssigneeSearchProps, type AssigneePickerProps } from '../map-state-to-props'
import * as template from '../../../__templates__'

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
  let assignment = template.assignment({
    group_category_id: '9999',
  })
  let group = template.group({
    group_category_id: '9999',
  })
  let enrollment = template.enrollment({
    course_id: course.id,
    user_id: '1',
    user: template.user({ id: '1' }),
  })
  let enrollment2 = template.enrollment({
    course_id: course.id,
    user_id: '2',
    user: template.user({ id: '2', name: 'Eve', pronouns: 'She/Her' }),
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
        [enrollment2.id]: enrollment2,
      },
      sections: {
        [section.id]: section,
      },
      users: {
        [enrollment.user_id]: {
          data: enrollment.user,
        },
        [enrollment2.user_id]: {
          data: enrollment2.user,
        },
      },
      groups: {
        [group.id]: {
          group,
        },
        '999999': {},
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
  let assigneeFour = template.groupAssignee({
    dataId: group.id,
  })

  let assigneeFive = template.enrollmentAssignee({
    dataId: enrollment2.user_id,
  })

  let props: AssigneePickerProps = {
    courseID: course.id,
    assignmentID: assignment.id,
    assignees: [assigneeOne, assigneeTwo, assigneeThree, assigneeFour, assigneeFive],
    callback: jest.fn(),
    navigator: template.navigator(),
    refreshUsers: jest.fn(),
    refreshSections: jest.fn(),
    refreshGroup: jest.fn(),
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
    },
    {
      dataId: group.id,
      name: group.name,
    },
    {
      dataId: enrollment2.user_id,
      name: 'Eve (She/Her)',
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
    refreshGroup: jest.fn(),
  }

  let result = pickerMapStateToProps(state, props)
  expect(result).toMatchObject({})
})
