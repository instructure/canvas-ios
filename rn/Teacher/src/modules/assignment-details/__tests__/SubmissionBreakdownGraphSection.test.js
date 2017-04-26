/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { SubmissionBreakdownGraphSection } from '../components/SubmissionBreakdownGraphSection'
import renderer from 'react-test-renderer'
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
}))

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
