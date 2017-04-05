// @flow

import 'react-native'
import React from 'react'
import SubmissionRow from '../SubmissionRow'
import type {
  SubmissionProp,
  SubmissionStatusProp,
  GradeProp,
} from '../submission-prop-types'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

const mockSubmission = (status: SubmissionStatusProp = 'none', grade: ?GradeProp = null): SubmissionProp => {
  return {
    onPress: () => {},
    userID: '1',
    avatarURL: 'https://cats.pajamas/',
    name: 'Green Latern',
    status,
    grade,
  }
}

test('unsubmitted ungraded row renders correctly', () => {
  const submission = mockSubmission()

  let tree = renderer.create(
    <SubmissionRow {...submission} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('missing ungraded row renders correctly', () => {
  const submission = mockSubmission('missing')
  let tree = renderer.create(
    <SubmissionRow {...submission} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('late graded row renders correctly', () => {
  const submission = mockSubmission('late', 'B-')
  let tree = renderer.create(
    <SubmissionRow {...submission} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('submitted ungraded row renders correctly', () => {
  const submission = mockSubmission('submitted', 'ungraded')
  let tree = renderer.create(
    <SubmissionRow {...submission} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
