//
// Copyright (C) 2017-present Instructure, Inc.
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

import Actions, {
  AssignmentListActions,
} from '../actions'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'
import { UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION } from '../../courses/actions'
import * as template from '../../../__templates__'

const { refreshAssignmentList } = Actions

describe('refreshAssignmentList', () => {
  it('gets assignments by assignment group', async () => {
    const course = template.course()
    const groups = [template.assignmentGroup()]
    let actions = AssignmentListActions({ getAssignmentGroups: apiResponse(groups), getAssignments: apiResponse(groups[0].assignments) })
    const result = await testAsyncAction(actions.refreshAssignmentList(course.id), {})

    expect(result).toMatchObject([{
      type: actions.refreshAssignmentList.toString(),
      pending: true,
      payload: {
        courseID: course.id,
      },
    },
    {
      type: actions.refreshAssignmentList.toString(),
      payload: {
        result: { data: groups },
        courseID: course.id,
      },
    },
    ])
  })

  it('can include a gradingPeriodID', () => {
    const action = refreshAssignmentList('', '2')
    expect(action).toMatchObject({
      payload: { gradingPeriodID: '2' },
    })
  })

  // TODO: this won't be necessary once CNVS-29053 is done
  // Makes sure we replace the group assignments with the assignments from the
  // assignments api
  it('filters by group assignments', async () => {
    const assignment = template.assignment({
      id: '1',
      name: 'Assignment 1',
      submission: null,
    })
    const lecture = template.assignment({
      id: '2',
      name: 'Lecture 1',
      submission: null,
    })

    const group1 = template.assignmentGroup({
      id: '1',
      name: 'Assignments',
      assignments: [assignment],
    })
    const group2 = template.assignmentGroup({
      id: '2',
      name: 'Lectures',
      assignments: [lecture],
    })
    const groups = [group1, group2]

    // getAssignments will have more correct assignment data then groups
    // but will not be filtered by grading period id
    const expectedAssignment = { ...assignment, submission: template.submission() }
    const expectedLecture = { ...lecture, submission: template.submission() }
    const otherAssignment = template.assignment({ id: '3', name: 'Not in the grading period' })
    const assignments = [
      expectedAssignment,
      expectedLecture,
      otherAssignment,
    ]

    const getAssignments = jest.fn(() => Promise.resolve({ data: assignments }))
    const getAssignmentGroups = jest.fn(() => Promise.resolve({ data: groups }))
    let actions = AssignmentListActions({
      getAssignmentGroups,
      getAssignments,
    })
    let action = actions.refreshAssignmentList('1', '2')
    const result = await action.payload.promise

    expect(result.data.length).toEqual(2)
    expect(result.data[0].name).toEqual('Assignments')
    expect(result.data[0].assignments.length).toEqual(1)
    expect(result.data[0].assignments[0]).toMatchObject(expectedAssignment)

    expect(result.data[1].name).toEqual('Lectures')
    expect(result.data[1].assignments.length).toEqual(1)
    expect(result.data[1].assignments[0]).toMatchObject(expectedLecture)

    expect(getAssignmentGroups).toHaveBeenCalledWith('1', '2', ['assignments'])
  })
})

test('refresh single assignment', async () => {
  const course = template.course()
  const assignment = template.assignment()
  let actions = AssignmentListActions({ getAssignment: apiResponse(assignment) })
  const result = await testAsyncAction(actions.refreshAssignment(course.id, assignment.id), {})

  expect(result).toMatchObject([{
    type: actions.refreshAssignment.toString(),
    pending: true,
    payload: {
      courseID: course.id,
      assignmentID: assignment.id,
    },
  },
  {
    type: actions.refreshAssignment.toString(),
    payload: {
      result: { data: assignment },
      courseID: course.id,
      assignmentID: assignment.id,
    },
  },
  ])
})

test('cancel update assignment action', () => {
  const assignment = template.assignment()
  let actions = AssignmentListActions()
  const result = actions.cancelAssignmentUpdate(assignment)
  expect(result).toMatchObject({
    type: 'assignment.cancel-update',
    payload: {
      originalAssignment: assignment,
    },
  })
})

test('should update selected assignment row', async () => {
  const rowID = '1'
  const actions = AssignmentListActions()
  const result = actions.updateCourseDetailsSelectedTabSelectedRow(rowID)

  expect(result).toMatchObject({
    type: UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION,
    payload: {
      rowID: rowID,
    },
  })
})

test('refresh assignment details', async () => {
  const course = template.course()
  const assignment = template.assignment()
  const summary = template.submissionSummary()
  let actions = AssignmentListActions({ getAssignment: apiResponse(assignment), refreshSubmissionSummary: apiResponse(summary) })
  const result = await testAsyncAction(actions.refreshAssignmentDetails(course.id, assignment.id, true), {})

  expect(result).toMatchObject([{
    type: actions.refreshAssignmentDetails.toString(),
    pending: true,
    payload: {
      courseID: course.id,
      assignmentID: assignment.id,
    },
  }, {
    type: actions.refreshAssignmentDetails.toString(),
    payload: {
      result: [{ data: assignment }, { data: summary }],
      courseID: course.id,
      assignmentID: assignment.id,
    },
  }])
})

test('refresh assignment details doesnt request the submission summary when told not to', async () => {
  const course = template.course()
  const assignment = template.assignment()
  const summary = template.submissionSummary()
  let actions = AssignmentListActions({ getAssignment: apiResponse(assignment), refreshSubmissionSummary: apiResponse(summary) })
  const result = await testAsyncAction(actions.refreshAssignmentDetails(course.id, assignment.id, false), {})

  expect(result).toMatchObject([{
    type: actions.refreshAssignmentDetails.toString(),
    pending: true,
    payload: {
      courseID: course.id,
      assignmentID: assignment.id,
    },
  }, {
    type: actions.refreshAssignmentDetails.toString(),
    payload: {
      result: [{ data: assignment }],
      courseID: course.id,
      assignmentID: assignment.id,
    },
  }])
})
