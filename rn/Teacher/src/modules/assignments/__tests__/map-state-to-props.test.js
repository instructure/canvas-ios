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

import { mapStateToProps } from '../map-state-to-props'
import * as templates from '../../../__templates__/index'

describe('AssignmentList mapStateToProps', () => {
  let assignmentGroup = templates.assignmentGroup()
  let assignment = templates.assignment()
  let gradingPeriod = templates.gradingPeriod({ id: 1 })
  let gradingPeriodTwo = templates.gradingPeriod({ id: 2 })
  let course = templates.course({
    enrollments: [
      { type: 'teacher', current_grading_period_id: gradingPeriod.id },
      { type: 'student', current_grading_period_id: gradingPeriodTwo.id },
    ],
  })

  let defaultState = templates.appState({
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

  let defaultProps = {
    navigator: templates.navigator(),
    courseID: course.id,
  }

  it('map state to props should work', async () => {
    const result = mapStateToProps(defaultState, defaultProps)
    expect(result).toMatchObject({
      assignmentGroups: [assignmentGroup],
      gradingPeriods: [{
        ...gradingPeriod,
        assignmentRefs: [assignment.id],
      }, {
        ...gradingPeriodTwo,
        assignmentRefs: [],
      }],
      currentGradingPeriodID: gradingPeriodTwo.id,
      courseColor: 'blueish',
    })
  })

  it('returns default props when the course is not there', () => {
    let state = templates.appState()

    let result = mapStateToProps(state, defaultProps)
    expect(result).toMatchObject({
      courseName: '',
      courseColor: '',
      assignmentGroups: [],
      pending: 0,
    })
  })

  it('filters grading periods by course id', () => {
    const three = templates.gradingPeriod({ id: '3' })
    const state = {
      ...defaultState,
      entities: {
        ...defaultState.entities,
        gradingPeriods: {
          ...defaultState.entities.gradingPeriods,
          '3': {
            gradingPeriod: three,
            assignmentRefs: [],
          },
        },
      },
    }

    expect(mapStateToProps(state, defaultProps)).toMatchObject({
      gradingPeriods: [
        { ...gradingPeriod, assignmentRefs: [assignment.id] },
        { ...gradingPeriodTwo, assignmentRefs: [] },
      ],
    })
  })

  it('returns static props for AssignmentList', () => {
    let state = templates.appState()
    expect(mapStateToProps(state, defaultProps)).toMatchObject({
      screenTitle: 'Assignments',
      showTotalScore: false,
    })

    expect(mapStateToProps(defaultState, defaultProps)).toMatchObject({
      screenTitle: 'Assignments',
      showTotalScore: false,
    })
  })
})
