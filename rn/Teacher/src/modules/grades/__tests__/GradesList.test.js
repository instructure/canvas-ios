//
// Copyright (C) 2018-present Instructure, Inc.
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

// @flow

import { shallow } from 'enzyme'
import React from 'react'
import { mapStateToProps, Refreshed } from '../GradesList'
import * as templates from '../../../__templates__/index'
import { setSession } from '../../../canvas-api'
import GradesListRow from '../GradesListRow'

describe('mapStateToProps', () => {
  const userID = '10'

  let assignmentGroup
  let assignment
  let gradingPeriod
  let gradingPeriodTwo
  let course
  let enrollment
  let defaultState
  let defaultProps
  beforeEach(() => {
    let session = templates.session()
    session.user.id = userID
    setSession(session)

    assignmentGroup = templates.assignmentGroup()
    assignment = assignmentGroup.assignments[0]
    gradingPeriod = templates.gradingPeriod({ id: 1 })
    gradingPeriodTwo = templates.gradingPeriod({ id: 2 })
    course = templates.course({
      enrollments: [
        { type: 'teacher', current_grading_period_id: gradingPeriod.id },
        { type: 'student', current_grading_period_id: gradingPeriodTwo.id, computed_current_score: 92 },
      ],
    })
    enrollment = templates.enrollment({ course_id: course.id, user_id: userID })

    defaultState = templates.appState({
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
        enrollments: {
          '1': enrollment,
        },
      },
      favoriteCourses: [],
    })

    defaultProps = {
      navigator: templates.navigator(),
      courseID: '1',
      assignmentGroups: [],
      gradingPeriods: [],
      currentScore: null,
      pending: false,
      refreshAssignmentList: jest.fn(),
      refreshGradingPeriods: jest.fn(),
      refreshUserEnrollments: jest.fn(),
      refreshCourse: jest.fn(),
    }
  })

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

  it('returns the user from the session', () => {
    const result = mapStateToProps(defaultState, defaultProps)
    expect(result.user).toMatchObject({ id: '10' })
    expect(mapStateToProps(defaultState, defaultProps).user).toMatchObject({ id: '10' })
  })

  it('returns the current_score from the enrollment', () => {
    // $FlowFixMe
    expect(mapStateToProps(defaultState, defaultProps).currentScore).toEqual(course.enrollments[1].computed_current_score)
  })

  it('returns the static props for AssignmentList', () => {
    expect(mapStateToProps(defaultState, defaultProps)).toMatchObject({
      screenTitle: 'Grades',
      showTotalScore: true,
      ListRow: GradesListRow,
    })
  })

  it('filters out not_graded assignments', () => {
    const notGraded = templates.assignment({ id: '1', grading_type: 'not_graded' })
    const points = templates.assignment({ id: '2', grading_type: 'points' })
    const state = {
      ...defaultState,
      entities: {
        ...defaultState.entities,
        assignmentGroups: {
          [assignmentGroup.id]: {
            group: assignmentGroup,
            assignmentRefs: [notGraded.id, points.id],
          },
        },
        assignments: {
          [notGraded.id]: {
            data: notGraded,
          },
          [points.id]: {
            data: points,
          },
        },
      },
    }

    const result = mapStateToProps(state, defaultProps)
    expect(result.assignmentGroups[0].assignments.length).toEqual(1)
    expect(result.assignmentGroups[0].assignments[0].grading_type).toEqual('points')
  })

  it('filters out assignments where the only submission type is not_graded', () => {
    const notGraded = templates.assignment({ id: '1', submission_types: ['not_graded'] })
    const points = templates.assignment({ id: '2', grading_type: 'points' })
    const state = {
      ...defaultState,
      entities: {
        ...defaultState.entities,
        assignmentGroups: {
          [assignmentGroup.id]: {
            group: assignmentGroup,
            assignmentRefs: [notGraded.id, points.id],
          },
        },
        assignments: {
          [notGraded.id]: {
            data: notGraded,
          },
          [points.id]: {
            data: points,
          },
        },
      },
    }

    const result = mapStateToProps(state, defaultProps)
    expect(result.assignmentGroups[0].assignments.length).toEqual(1)
    expect(result.assignmentGroups[0].assignments[0].grading_type).toEqual('points')
  })

  it('does not include currentScore if hide_final_grades is true', () => {
    defaultState.entities.courses[course.id].course.hide_final_grades = true
    const result = mapStateToProps(defaultState, defaultProps)
    expect(result).toMatchObject({ currentScore: null })
  })

  it('does not include currentScore if mgp enabled and totals_for_all_grading_periods_option is false', () => {
    const enrollment = templates.enrollment({
      course_id: course.id,
      user_id: userID,
      has_grading_periods: true,
      totals_for_all_grading_periods_option: false,
      type: 'student',
    })
    defaultState.entities.courses[course.id].course.enrollments = [enrollment]
    const result = mapStateToProps(defaultState, defaultProps)
    expect(result).toMatchObject({ currentScore: null })
  })

  it('includes currentScore if mgp enabled and totals_for_all_grading_periods_option is true', () => {
    const enrollment = templates.enrollment({
      course_id: course.id,
      user_id: userID,
      has_grading_periods: true,
      totals_for_all_grading_periods_option: true,
      computed_current_score: 13,
      type: 'student',
    })
    defaultState.entities.courses[course.id].course.enrollments = [enrollment]
    const result = mapStateToProps(defaultState, defaultProps)
    expect(result).toMatchObject({ currentScore: 13 })
  })

  it('refreshes course on refresh', () => {
    const view = shallow(<Refreshed {...defaultProps} />)
    view.instance().refresh()
    expect(defaultProps.refreshCourse).toHaveBeenCalledWith(defaultProps.courseID)
  })
})
