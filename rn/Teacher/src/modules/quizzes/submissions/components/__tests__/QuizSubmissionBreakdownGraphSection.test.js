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

/* eslint-disable flowtype/require-valid-file-annotation */

import 'react-native'
import React from 'react'
import { QuizSubmissionBreakdownGraphSection, mapStateToProps } from '../QuizSubmissionBreakdownGraphSection'
import renderer from 'react-test-renderer'
import explore from '../../../../../../test/helpers/explore'
import setProps from '../../../../../../test/helpers/setProps'
const template = {
  ...require('../../../../../__templates__/quiz'),
  ...require('../../../../../__templates__/assignments'),
  ...require('../../../../../__templates__/course'),
  ...require('../../../../../__templates__/quizSubmission'),
  ...require('../../../../../__templates__/users'),
  ...require('../../../../../__templates__/enrollments'),
  ...require('../../../../../redux/__templates__/app-state'),
}
jest.mock('TouchableOpacity', () => 'TouchableOpacity')

let course: any = template.course()
let quiz: any = template.quiz()

let defaultProps = {}

beforeEach(() => {
  defaultProps = {
    assignmentID: '',
    courseID: course.id,
    quizID: quiz.id,
    refreshQuizSubmissions: jest.fn(),
    refreshEnrollments: jest.fn(),
    refreshAssignment: jest.fn(),
    refreshGradeableStudents: jest.fn(),
    submissionTotalCount: 3,
    pending: false,
    refresh: jest.fn(),
    refreshing: false,
    onPress: jest.fn(),
    graded: 1,
    ungraded: 1,
    notSubmitted: 1,
    refreshSubmissionSummary: jest.fn(),
  }
})

test('render', () => {
  let tree = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()

  expect(defaultProps.refreshQuizSubmissions).toHaveBeenCalledWith(course.id, quiz.id, '')
  expect(defaultProps.refreshEnrollments).toHaveBeenCalledWith(course.id)
})

test('render with an assignment id', () => {
  const assignment = template.assignment()
  defaultProps.assignmentID = assignment.id
  defaultProps.graded = 1
  defaultProps.ungraded = 1
  defaultProps.notSubmitted = 1
  defaultProps.submissionTotalCount = 3

  const tree = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()

  expect(defaultProps.refreshQuizSubmissions).toHaveBeenCalledWith(course.id, quiz.id, assignment.id)
  expect(defaultProps.refreshSubmissionSummary).toHaveBeenCalledWith(course.id, assignment.id)
})

test('render 0 submissions', () => {
  defaultProps.graded = 0
  defaultProps.ungraded = 0
  defaultProps.notSubmitted = 0
  defaultProps.submissionTotalCount = 0
  let tree = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render no graded', () => {
  defaultProps.graded = 0
  defaultProps.ungraded = 1
  defaultProps.notSubmitted = 1
  defaultProps.submissionTotalCount = 2
  let tree = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render 1 needs grading', () => {
  defaultProps.ungraded = 1
  defaultProps.submissionTotalCount = 2
  const tree = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render 2 need grading', () => {
  defaultProps.ungraded = 2
  defaultProps.submissionTotalCount = 2
  const tree = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render loading with pending set', () => {
  defaultProps.pending = true
  let tree = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('onPress is called graded dial', () => {
  testDialOnPress('quiz-submission_dial_0', 'graded')
})

test('onPress is called ungraded dial', () => {
  testDialOnPress('quiz-submission_dial_1', 'ungraded')
})

test('onPress is called not_submitted dial', () => {
  testDialOnPress('quiz-submission_dial_2', 'not_submitted')
})

test('misc functions', () => {
  defaultProps.onPress = null
  let instance = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  ).getInstance()

  // Make sure this doesn't explode when there isn't an onPress handler
  expect(() => {
    instance.onPress(null)
  }).not.toThrow()
})

test('refreshSubmissionSummary gets called once assignmentID gets passed in', () => {
  const spy = jest.fn()
  defaultProps.refreshSubmissionSummary = spy
  defaultProps.assignmentID = null
  defaultProps.courseID = '1'
  let view = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  )
  setProps(view, { assignmentID: '30984' })
  expect(spy).toHaveBeenCalledTimes(1)
  expect(spy).toHaveBeenCalledWith('1', '30984')
})

test('refreshEnrollments gets called if assignmentID goes away', () => {
  const spy = jest.fn()
  defaultProps.refreshEnrollments = spy
  defaultProps.assignmentID = '1'
  defaultProps.courseID = '1'
  let view = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  )
  setProps(view, { assignmentID: null })
  expect(spy).toHaveBeenCalledTimes(1)
  expect(spy).toHaveBeenCalledWith('1')
})

function testDialOnPress (expectedID: string, expectedValueParameter: string) {
  let component = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  )
  let dial: any = explore(component.toJSON()).selectByID(expectedID)
  dial.props.onPress()
  expect(defaultProps.onPress).toBeCalledWith(expectedValueParameter)
}

test('mapStateToProps', () => {
  const course = template.course()
  const quiz = template.quiz()

  const u1 = template.user({
    id: '1',
  })
  const e1 = template.enrollment({
    id: '1',
    user_id: u1.id,
    user: u1,
  })
  const qs1 = template.quizSubmission({
    id: '1',
    quiz_id: quiz.id,
    user_id: e1.user.id,
    workflow_state: 'pending_review',
  })

  const appState = template.appState({
    entities: {
      courses: {
        [course.id]: { enrollments: { refs: [e1.id] } },
      },
      enrollments: {
        [e1.id]: e1,
      },
      quizzes: {
        [quiz.id]: {
          data: quiz,
          quizSubmissions: { refs: [qs1.id], pending: 0 },
        },
      },
      quizSubmissions: {
        [qs1.id]: { data: qs1 },
      },
    },
  })

  const result = mapStateToProps(appState, { courseID: course.id, quizID: quiz.id })
  expect(result).toEqual({
    submissionTotalCount: 1,
    graded: 0,
    notSubmitted: 0,
    ungraded: 1,
    pending: false,
  })
})

test('mapStateToProps with an assignment id', () => {
  const course = template.course()
  const quiz = template.quiz()
  const assignment = template.assignment()

  const u1 = template.user({
    id: '1',
  })
  const e1 = template.enrollment({
    id: '1',
    user_id: u1.id,
    user: u1,
  })
  const qs1 = template.quizSubmission({
    id: '1',
    quiz_id: quiz.id,
    user_id: e1.user.id,
    workflow_state: 'pending_review',
  })

  const appState = template.appState({
    entities: {
      courses: {
        [course.id]: { enrollments: { refs: [e1.id] } },
      },
      assignments: {
        [assignment.id]: {
          assignment,
          gradeableStudents: { refs: ['1'], pending: 0 },
          submissionSummary: { error: null, pending: 0, data: { graded: 0, ungraded: 0, not_submitted: 1 } },
        },
      },
      enrollments: {
        [e1.id]: e1,
      },
      quizzes: {
        [quiz.id]: {
          data: quiz,
          quizSubmissions: { refs: [qs1.id] },
        },
      },
      quizSubmissions: {
        [qs1.id]: { data: qs1 },
      },
    },
  })

  const result = mapStateToProps(appState, { courseID: course.id, quizID: quiz.id, assignmentID: assignment.id })
  expect(result).toEqual({
    submissionTotalCount: 1,
    graded: 0,
    ungraded: 0,
    notSubmitted: 1,
    pending: false,
  })
})

test('mapStateToProps with no data should not explode', () => {
  const course = template.course()
  const quiz = template.quiz()
  const assignment = template.assignment()
  const appState = template.appState()
  let result = mapStateToProps(appState, { courseID: course.id, quizID: quiz.id, assignmentID: assignment.id })
  expect(result).toEqual({
    submissionTotalCount: 0,
    graded: 0,
    ungraded: 0,
    notSubmitted: 0,
    pending: true,
  })

  result = mapStateToProps(appState, { courseID: course.id, quizID: quiz.id })
  expect(result).toEqual({
    submissionTotalCount: 0,
    graded: 0,
    ungraded: 0,
    notSubmitted: 0,
    pending: false,
  })
})
