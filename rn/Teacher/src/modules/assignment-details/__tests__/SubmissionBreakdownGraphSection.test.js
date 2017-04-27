/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { SubmissionBreakdownGraphSection } from '../components/SubmissionBreakdownGraphSection'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'
const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../api/canvas-api/__templates__/submissions'),
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
  let a = template.submission({ id: 1, grade: '95' })
  let b = template.submission({ id: 2, grade: 'ungraded' })
  let c = template.submission({ id: 3, grade: 'not_submitted' })

  defaultProps = {
    courseID: course.id,
    assignmentID: assignment.assignmentID,
    refreshSubmissions: (courseID: string, assignmentID: string) => {},
    refreshEnrollments: (courseID: string) => {},
    submissions: [a, b, c],
    pending: 0,
    refresh: jest.fn(),
    refreshing: false,
    onPress: jest.fn(),
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
  let tree = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render multiple data points ', () => {
  let a = template.submission({ id: 1, grade: '95' })
  let b = template.submission({ id: 2, grade: 'A' })
  let c = template.submission({ id: 3, grade: 'B-' })
  let d = template.submission({ id: 4, grade: 'ungraded' })
  let e = template.submission({ id: 5, grade: 'ungraded' })
  let f = template.submission({ id: 6, grade: 'not_submitted' })
  defaultProps.submissions = [a, b, c, d, e, f]

  let tree = renderer.create(
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
  testDialOnPress('submission_dial_0', 'graded')
})

test('onPress is called ungraded dial', () => {
  testDialOnPress('submission_dial_1', 'notgraded')
})

test('onPress is called not_submitted dial', () => {
  testDialOnPress('submission_dial_2', 'notsubmitted')
})

function testDialOnPress (expectedID: string, expectedValueParameter: string) {
  let component = renderer.create(
    <SubmissionBreakdownGraphSection {...defaultProps} />
  )
  let dial: any = explore(component.toJSON()).selectByID(expectedID)
  dial.props.onPress()
  expect(defaultProps.onPress).toBeCalledWith(expectedValueParameter)
}

