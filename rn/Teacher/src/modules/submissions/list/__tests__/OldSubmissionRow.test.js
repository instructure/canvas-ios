//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import 'react-native'
import React from 'react'
import OldSubmissionRow from '../OldSubmissionRow'
import explore from '../../../../../test/helpers/explore'
import renderer from 'react-test-renderer'

jest
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../../common/components/Avatar', () => 'Avatar')

const mockSubmission = (status = 'none', grade = null) => {
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
    <OldSubmissionRow {...submission} onPress={jest.fn()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('missing ungraded row renders correctly', () => {
  const submission = mockSubmission('missing')
  let tree = renderer.create(
    <OldSubmissionRow {...submission} onPress={jest.fn()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('late graded row renders correctly', () => {
  const submission = mockSubmission('late', 'B-')
  let tree = renderer.create(
    <OldSubmissionRow {...submission} onPress={jest.fn()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('submitted ungraded row renders correctly', () => {
  const submission = mockSubmission('submitted', 'ungraded')
  let tree = renderer.create(
    <OldSubmissionRow {...submission} onPress={jest.fn()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('submitted not_graded row renders correctly', () => {
  const submission = mockSubmission('submitted', 'ungraded')
  submission.gradingType = 'not_graded'
  let tree = renderer.create(
    <OldSubmissionRow {...submission} onPress={jest.fn()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('excused row renders correctly', () => {
  const submission = mockSubmission('missing', 'excused')
  let tree = renderer.create(
    <OldSubmissionRow {...submission} onPress={jest.fn()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('onPress called on tap', () => {
  const submission = mockSubmission()
  const onPress = jest.fn()
  let row = explore(renderer.create(
    <OldSubmissionRow {...submission} onPress={onPress} />
  ).toJSON()).selectByID(`submission-${submission.userID}`)
  row && row.props.onPress()
  expect(onPress).toHaveBeenCalledWith(submission.userID)
})

test('anonymous grading doesnt show users names', () => {
  const submission = mockSubmission()
  let tree = renderer.create(
    <OldSubmissionRow {...submission} anonymous />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('pressing the avatar calls onAvatarPress', () => {
  const submission = mockSubmission()
  const onAvatarPress = jest.fn()
  let tree = renderer.create(
    <OldSubmissionRow {...submission} onAvatarPress={onAvatarPress} />
  ).toJSON()
  let avatar = explore(tree).selectByType('Avatar')
  avatar.props.onPress()
  expect(onAvatarPress).toHaveBeenCalledWith('1')
})
