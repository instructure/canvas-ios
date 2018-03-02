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
import SubmissionRow from '../SubmissionRow'
import type {
  SubmissionDataProps,
  GradeProp,
} from '../submission-prop-types'
import explore from '../../../../../test/helpers/explore'
import renderer from 'react-test-renderer'

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../../common/components/Avatar', () => 'Avatar')

const mockSubmission = (status: SubmissionStatus = 'none', grade: ?GradeProp = null): SubmissionDataProps => {
  return {
    userID: '1',
    avatarURL: 'https://cats.pajamas/',
    name: 'Green Latern',
    status,
    grade,
    submissionID: null,
    submission: null,
    anonymous: false,
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

test('submitted not_graded row renders correctly', () => {
  const submission = mockSubmission('submitted', 'ungraded')
  submission.gradingType = 'not_graded'
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

test('anonymous grading doesnt show users names', () => {
  const submission = mockSubmission()
  let tree = renderer.create(
    <SubmissionRow {...submission} anonymous />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('pressing the avatar calls onAvatarPress', () => {
  const submission = mockSubmission()
  const onAvatarPress = jest.fn()
  let tree = renderer.create(
    <SubmissionRow {...submission} onAvatarPress={onAvatarPress} />
  ).toJSON()
  let avatar = explore(tree).selectByType('Avatar')
  avatar.props.onPress()
  expect(onAvatarPress).toHaveBeenCalledWith('1')
})
