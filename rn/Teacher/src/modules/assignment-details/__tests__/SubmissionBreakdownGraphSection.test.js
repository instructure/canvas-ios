/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { SubmissionBreakdownGraphSection, mapStateToProps } from '../components/SubmissionBreakdownGraphSection'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'
const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/users'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../api/canvas-api/__templates__/submissions'),
  ...require('../../../redux/__templates__/app-state'),
}
jest.mock('TouchableOpacity', () => 'TouchableOpacity')

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
  testDialOnPress('assignment-details.submission-breakdown-graph-section.ungraded-dial', 'notgraded')
})

test('onPress is called not_submitted dial', () => {
  testDialOnPress('assignment-details.submission-breakdown-graph-section.not-submitted-dial', 'notsubmitted')
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
