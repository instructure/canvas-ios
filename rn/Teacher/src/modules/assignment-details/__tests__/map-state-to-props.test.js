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

/* @flow */

import { mapStateToProps, updateMapStateToProps, type AssignmentDetailsProps } from '../map-state-to-props'
import * as template from '../../../__templates__'
import app from '../../app'

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

test('it returns showSubmissionSummary as false if the user is a student', () => {
  app.setCurrentApp('student')
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

  const result = mapStateToProps(state, props)
  expect(result.showSubmissionSummary).toEqual(false)
})
