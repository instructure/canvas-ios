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

import { mapStateToProps, type AssignmentListProps } from '../map-state-to-props'

const template = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/grading-periods'),
  ...require('../../../__templates__/helm'),
  ...require('../../../redux/__templates__/app-state'),
}

test('map state to props should work', async () => {
  let course = template.course()
  let assignmentGroup = template.assignmentGroup()
  let assignment = template.assignment()
  let gradingPeriod = template.gradingPeriod({ id: 1 })
  let gradingPeriodTwo = template.gradingPeriod({ id: 2 })

  let state = template.appState({
    entities: {
      courses: {
        [course.id]: {
          assignmentGroups: { refs: [assignmentGroup.id] },
          gradingPeriods: { refs: [gradingPeriod.id, gradingPeriodTwo.id] },
          course: course,
          color: 'blueish',
        },
      },
      assignmentGroups: {
        [assignmentGroup.id]: { group: assignmentGroup, assignmentRefs: [assignment.id] },
      },
      assignments: {
        [assignment.id]: { data: assignment },
      },
      gradingPeriods: {
        [gradingPeriod.id]: {
          gradingPeriod,
          assignmentRefs: [assignment.id],
        },
        [gradingPeriodTwo.id]: {
          gradingPeriod: gradingPeriodTwo,
          assignmentRefs: [],
        },
      },
      courseDetailsTabSelectedRow: { rowID: '' },
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
    refreshAssignment: jest.fn(),
    refreshAssignmentDetails: jest.fn(),
    refresh: jest.fn(),
    cancelAssignmentUpdate: jest.fn(),
    updateCourseDetailsSelectedTabSelectedRow: jest.fn(),
    refreshGradeableStudents: jest.fn(),
    refreshing: false,
    pending: 0,
    navigator: template.navigator(),
    gradingPeriods: [],
    courseColor: 'greenish',
    courseName: 'blah blah',
    selectedRowID: '0',
    anonymousGrading: jest.fn(),
  }

  const result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    assignmentGroups: [assignmentGroup],
    gradingPeriods: [{
      ...gradingPeriod,
      assignmentRefs: [assignment.id],
    }, {
      ...gradingPeriodTwo,
      assignmentRefs: [],
    }],
    courseColor: 'blueish',
  })
})

test('returns default props when the course is not there', () => {
  let state = template.appState()

  let props = {
    courseID: '1',
    refreshAssignmentList: jest.fn(),
    refreshGradingPeriods: jest.fn(),
    refresh: jest.fn(),
    refreshing: false,
    navigator: template.navigator(),
    assignmentGroups: [],
    course: {
      course: template.course(),
      color: '#fff',
    },
    gradingPeriods: [],
    pending: 0,
  }

  let result = mapStateToProps(state, props)
  expect(result).toMatchObject({
    courseName: '',
    courseColor: '',
    assignmentGroups: [],
    pending: 0,
  })
})

it('filters grading periods by course id', () => {
  const one = template.gradingPeriod({ id: '1' })
  const two = template.gradingPeriod({ id: '2' })
  const three = template.gradingPeriod({ id: '3' })
  const state = template.appState({
    entities: {
      courseDetailsTabSelectedRow: { rowID: '' },
      courses: {
        '1': {
          course: template.course(),
          gradingPeriods: {
            refs: [one.id, two.id],
          },
          assignmentGroups: {
            refs: [],
            pending: 0,
            error: null,
          },
        },
      },
      gradingPeriods: {
        '1': {
          gradingPeriod: one,
          assignmentRefs: [],
        },
        '2': {
          gradingPeriod: two,
          assignmentRefs: [],
        },
        '3': {
          gradingPeriod: three,
          assignmentRefs: [],
        },
      },
    },
  })

  expect(mapStateToProps(state, { courseID: '1' })).toMatchObject({
    gradingPeriods: [
      { ...one, assignmentRefs: [] },
      { ...two, assignmentRefs: [] },
    ],
  })
})
