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
import React from 'react'
import { SubmissionBreakdownGraphSection, mapStateToProps } from '../components/SubmissionBreakdownGraphSection'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'
const template = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/users'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/submissions'),
  ...require('../../../redux/__templates__/app-state'),
}
jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

let course: any = template.course()
let assignment: any = template.assignment()

let defaultProps = {}

beforeEach(() => {
  const a = template.submission({ id: 1, grade: '95' })
  const b = template.submission({ id: 2, grade: 'ungraded' })
  const c = template.submission({ id: 3, grade: 'not_submitted' })
  const submissions = [a, b, c]

  defaultProps = {
    courseID: course.id,
    assignmentID: assignment.assignmentID,
    refreshSubmissions: jest.fn(),
    refreshGradeableStudents: jest.fn(),
    refreshAssignment: jest.fn(),
    submissionTotalCount: submissions.length,
    pending: 0,
    refresh: jest.fn(),
    refreshing: false,
    onPress: jest.fn(),
    refreshSubmissionSummary: jest.fn(),
    submissionTypes: ['online'],
    graded: 1,
    ungraded: 1,
    not_submitted: 1,
  }
})

test('render', () => {
  let tree = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render 0 submissions', () => {
  defaultProps.graded = 0
  defaultProps.ungraded = 0
  defaultProps.not_submitted = 0
  defaultProps.submissionTotalCount = 0
  let tree = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render on paper submission type', () => {
  defaultProps.graded = 2
  defaultProps.ungraded = 1
  defaultProps.not_submitted = 1
  defaultProps.submissionTotalCount = 4
  defaultProps.submissionTypes = ['on_paper']
  let tree = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render on paper submission type', () => {
  defaultProps.graded = 0
  defaultProps.ungraded = 0
  defaultProps.not_submitted = 0
  defaultProps.submissionTotalCount = 0
  defaultProps.submissionTypes = ['none']
  let tree = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render undefined submission type', () => {
  defaultProps.graded = 2
  defaultProps.ungraded = 1
  defaultProps.not_submitted = 1
  defaultProps.submissionTotalCount = 4
  defaultProps.submissionTypes = undefined
  let tree = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render multiple data points ', () => {
  defaultProps.graded = 3
  defaultProps.ungraded = 2
  defaultProps.not_submitted = 1
  defaultProps.submissionTotalCount = 6
  const tree = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render 1 needs grading', () => {
  defaultProps.ungraded = 1
  defaultProps.submissionTotalCount = 2
  const tree = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render 2 need grading', () => {
  defaultProps.ungraded = 2
  defaultProps.submissionTotalCount = 2
  const tree = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render loading with pending set', () => {
  defaultProps.pending = 1
  let tree = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('onPress is called graded dial', () => {
  testDialOnPress('assignment-details.submission-breakdown-graph-section.graded-dial', 'graded')
})

test('onPress is called ungraded dial', () => {
  testDialOnPress('assignment-details.submission-breakdown-graph-section.ungraded-dial', 'ungraded')
})

test('onPress is called not_submitted dial', () => {
  testDialOnPress('assignment-details.submission-breakdown-graph-section.not_submitted-dial', 'not_submitted')
})

function testDialOnPress (expectedID: string, expectedValueParameter: string) {
  let component = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  )
  let dial: any = explore(component.toJSON()).selectByID(expectedID)
  dial.props.onPress()
  expect(defaultProps.onPress).toBeCalledWith(expectedValueParameter)
}

test('mapStateToProps with an assignment id', () => {
  const course = template.course()
  const assignment = template.assignment()

  const u1 = template.user({
    id: '1',
  })
  const s1 = template.submission({
    id: '1',
    assignment_id: assignment.id,
    user_id: u1.id,
    workflow_state: 'unsubmitted',
  })

  const appState = template.appState({
    entities: {
      assignments: {
        [assignment.id]: {
          assignment,
          submissions: { refs: [s1.id], pending: 0 },
          submissionSummary: { data: { graded: 0, ungraded: 0, not_submitted: 1 }, error: null, pending: 0 },
          gradeableStudents: { refs: ['1'], pending: 0 },
        },
      },
    },
  })

  const result = mapStateToProps(appState, { courseID: course.id, assignmentID: assignment.id })
  expect(result).toMatchObject({
    submissionTotalCount: 1,
    graded: 0,
    ungraded: 0,
    not_submitted: 1,
    pending: false,
  })
})

test('mapStateToProps no datas', () => {
  const course = template.course()
  const assignment = template.assignment()

  const appState = template.appState()

  const result = mapStateToProps(appState, { courseID: course.id, assignmentID: assignment.id })
  expect(result).toMatchObject({
    submissionTotalCount: 0,
    graded: 0,
    ungraded: 0,
    not_submitted: 0,
    pending: true,
  })
})

test('misc functions', () => {
  defaultProps.onPress = null
  let instance = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).getInstance()

  // Make sure this doesn't explode when there isn't an onPress handler
  expect(() => {
    instance.onPress(null)
  }).not.toThrow()
})

test('mapStateToProps no submissionSummary data', () => {
  const course = template.course()
  const assignment = template.assignment()

  const appState = template.appState()

  let state = {
    ...appState,
    entities: {
      assignments: {
        [assignment.id]: { data: assignment, pending: 0, submissionSummary: { pending: 1 } },
      },
    },
  }

  const result = mapStateToProps(state, { courseID: course.id, assignmentID: assignment.id })
  expect(result).toMatchObject({
    submissionTotalCount: 0,
    graded: 0,
    ungraded: 0,
    not_submitted: 0,
    pending: true,
  })
})
