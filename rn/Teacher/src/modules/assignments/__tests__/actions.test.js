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

import { AssignmentListActions } from '../actions'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'
import { UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION } from '../../courses/actions'

const template = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/submissions'),
}

test('refresh assignment list', async () => {
  const course = template.course()
  const groups = [template.assignmentGroup()]
  let actions = AssignmentListActions({ getAssignmentGroups: apiResponse(groups) })
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

test('refresh assignment list can take an optional grading period id', async () => {
  const course = template.course()
  const groups = [template.assignmentGroup()]
  let actions = AssignmentListActions({ getAssignmentGroups: apiResponse(groups) })
  const result = await testAsyncAction(actions.refreshAssignmentList(course.id, 1), {})

  expect(result).toMatchObject([{
    type: actions.refreshAssignmentList.toString(),
    pending: true,
    payload: {
      courseID: course.id,
      gradingPeriodID: 1,
    },
  }, {
    type: actions.refreshAssignmentList.toString(),
    payload: {
      result: { data: groups },
      courseID: course.id,
      gradingPeriodID: 1,
    },
  }])
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

test('should dispatch anonymous grading', () => {
  let actions = AssignmentListActions()
  let action = actions.anonymousGrading('1', '2', true)
  expect(action).toEqual({
    type: actions.anonymousGrading.toString(),
    payload: {
      courseID: '1',
      assignmentID: '2',
      anonymous: true,
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
