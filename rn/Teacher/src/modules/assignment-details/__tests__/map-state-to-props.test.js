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
    course,
    refreshAssignmentDetails: jest.fn(),
    navigator: template.navigator(),
    assignmentDetails: assignment,
    refresh: jest.fn(),
    refreshing: false,
    updateAssignment: jest.fn(),
    cancelAssignmentUpdate: jest.fn(),
    getSessionlessLaunchURL: jest.fn(),
  }

  const result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    assignmentDetails: assignment,
    courseName: course.name,
  })
})

test('map state to props no assignment, no enrollment', async () => {
  let course = template.course({ enrollments: [] })
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
    course: null,
    refreshAssignmentDetails: jest.fn(),
    navigator: template.navigator(),
    assignmentDetails: null,
    refresh: jest.fn(),
    refreshing: false,
    updateAssignment: jest.fn(),
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
    course,
    refreshAssignmentDetails: jest.fn(),
    navigator: template.navigator(),
    assignmentDetails: assignment,
    refresh: jest.fn(),
    refreshing: false,
    updateAssignment: jest.fn(),
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
    course,
    refreshAssignmentDetails: jest.fn(),
    navigator: template.navigator(),
    assignmentDetails: assignment,
    refresh: jest.fn(),
    refreshing: false,
    updateAssignment: jest.fn(),
    cancelAssignmentUpdate: jest.fn(),
    getSessionlessLaunchURL: jest.fn(),
  }

  const result = updateMapStateToProps(state, props)
  expect(result).toMatchObject({
    assignmentDetails: assignment,
    pending: 0,
  })
})

test('it returns showSubmissionSummary as false if the user is a designer', () => {
  let course = template.course({ enrollments: [{ type: 'designer' }] })
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
    course,
    refreshAssignmentDetails: jest.fn(),
    navigator: template.navigator(),
    assignmentDetails: assignment,
    refresh: jest.fn(),
    refreshing: false,
    updateAssignment: jest.fn(),
    cancelAssignmentUpdate: jest.fn(),
    getSessionlessLaunchURL: jest.fn(),
  }

  const result = mapStateToProps(state, props)
  expect(result.showSubmissionSummary).toEqual(false)
})
