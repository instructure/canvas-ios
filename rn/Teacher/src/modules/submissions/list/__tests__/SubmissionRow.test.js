// @flow

import 'react-native'
import React from 'react'
import SubmissionRow from '../SubmissionRow'
import type {
  SubmissionDataProps,
  SubmissionStatusProp,
  GradeProp,
} from '../submission-prop-types'
import explore from '../../../../../test/helpers/explore'
import renderer from 'react-test-renderer'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

const mockSubmission = (status: SubmissionStatusProp = 'none', grade: ?GradeProp = null): SubmissionDataProps => {
  return {
    userID: '1',
    avatarURL: 'https://cats.pajamas/',
    name: 'Green Latern',
    status,
    grade,
    submissionID: null,
    submission: null,
  }
}

test('unsubmitted ungraded row renders correctly', () => {
  const submission = mockSubmission()

  let tree = renderer.create(
    <SubmissionRow {...submission} onPress={jest.fn()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('missing ungraded row renders correctly', () => {
  const submission = mockSubmission('missing')
  let tree = renderer.create(
    <SubmissionRow {...submission} onPress={jest.fn()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('late graded row renders correctly', () => {
  const submission = mockSubmission('late', 'B-')
  let tree = renderer.create(
    <SubmissionRow {...submission} onPress={jest.fn()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('submitted ungraded row renders correctly', () => {
  const submission = mockSubmission('submitted', 'ungraded')
  let tree = renderer.create(
    <SubmissionRow {...submission} onPress={jest.fn()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('excused row renders correctly', () => {
  const submission = mockSubmission('missing', 'excused')
  let tree = renderer.create(
    <SubmissionRow {...submission} onPress={jest.fn()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('onPress called on tap', () => {
  const submission = mockSubmission()
  const onPress = jest.fn()
  let row = explore(renderer.create(
    <SubmissionRow {...submission} onPress={onPress} />
  ).toJSON()).selectByID(`submission-${submission.userID}`)
  row && row.props.onPress()
  expect(onPress).toHaveBeenCalledWith(submission.userID)
})

