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

import { mapStateToProps } from '../map-state-to-props'
import * as templates from '../../../__templates__/index'

describe('AssignmentList mapStateToProps', () => {
  let assignmentGroup = templates.assignmentGroup()
  let assignment = assignmentGroup.assignments[0]
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
      courseName: null,
      courseColor: null,
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
