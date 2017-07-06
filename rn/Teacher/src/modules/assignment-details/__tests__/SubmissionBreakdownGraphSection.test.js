/**
 * @flow
 */

import { LayoutAnimation } from 'react-native'
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
jest.mock('LayoutAnimation', () => ({
  create: jest.fn(),
  configureNext: jest.fn(),
  easeInEaseOut: jest.fn(),
  Types: { linear: null },
  Properties: { opacity: null },
  onPress: jest.fn(),
}))
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
    submissions,
    submissionTotalCount: submissions.length,
    pending: 0,
    refresh: jest.fn(),
    refreshing: false,
    onPress: jest.fn(),
    refreshSubmissionSummary: jest.fn(),
  }
})

test('render', () => {
  let tree = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render 0 submissions', () => {
  defaultProps.submissions = []
  defaultProps.submissionTotalCount = 0
  let tree = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render multiple data points ', () => {
  const a = template.submission({ id: 1, grade: '95' })
  const b = template.submission({ id: 2, grade: 'A' })
  const c = template.submission({ id: 3, grade: 'B-' })
  const d = template.submission({ id: 4, grade: 'ungraded' })
  const e = template.submission({ id: 5, grade: 'ungraded' })
  const f = template.submission({ id: 6, grade: 'not_submitted' })
  const submissions = [a, b, c, d, e, f]
  defaultProps.submissions = submissions
  defaultProps.submissionTotalCount = submissions.length

  const tree = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render loading with null submissions', () => {
  defaultProps.submissions = null
  let tree = renderer.create(
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
    pending: 0,
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
  instance.onPress(null)

  // Make sure animation is called
  instance.componentWillUpdate()
  expect(LayoutAnimation.easeInEaseOut).toHaveBeenCalled()
})
