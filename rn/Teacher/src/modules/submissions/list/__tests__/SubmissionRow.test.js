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
import SubmissionRow from '../SubmissionRow'
import type {
  SubmissionDataProps,
  GradeProp,
} from '../submission-prop-types'
import explore from '../../../../../test/helpers/explore'
import renderer from 'react-test-renderer'
import * as templates from '../../../../__templates__';

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../../common/components/Avatar', () => 'Avatar')

const mockSubmission = (overrides): SubmissionDataProps => {
  return {
    userID: '1',
    avatarURL: 'https://cats.pajamas/',
    name: 'Green Latern',
    status: 'none',
    grade: null,
    submissionID: '32',
    submission: templates.submission({ grade: null, score: null }),
    anonymous: false,
    ...overrides
  }
}

let defaultProps = {
  onPress: jest.fn(),
  onAvatarPress: jest.fn(),
  anonymouse: false,
  gradingType: 'points',
  newGradebookEnabled: false,
  ...mockSubmission()
}

test('unsubmitted ungraded row renders correctly', () => {
  let tree = renderer.create(
    <SubmissionRow {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('missing ungraded row renders correctly', () => {
  const submission = mockSubmission({ status: 'missing' })
  let tree = renderer.create(
    <SubmissionRow {...defaultProps} {...submission} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('late graded row renders correctly', () => {
  const submission = mockSubmission({ status: 'late', grade: 'B-' })
  let tree = renderer.create(
    <SubmissionRow {...defaultProps} {...submission} gradingType='gpa_scale' />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('submitted ungraded row renders correctly', () => {
  const submission = mockSubmission({ status: 'submitted', grade: 'ungraded' })
  let tree = renderer.create(
    <SubmissionRow {...defaultProps} {...submission} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('submitted not_graded row renders correctly', () => {
  const submission = mockSubmission({ status: 'submitted', grade: 'ungraded' })
  let tree = renderer.create(
    <SubmissionRow {...defaultProps} {...submission}  gradingType='not_graded' />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('excused row renders correctly', () => {
  const submission = mockSubmission({ status: 'missing', grade: 'excused' })
  let tree = renderer.create(
    <SubmissionRow {...defaultProps} {...submission} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('onPress called on tap', () => {
  const onPress = jest.fn()
  let row = explore(renderer.create(
    <SubmissionRow {...defaultProps} onPress={onPress} />
  ).toJSON()).selectByID(`submission-${defaultProps.userID}`)
  row && row.props.onPress()
  expect(onPress).toHaveBeenCalledWith(defaultProps.userID)
})

test('anonymous grading doesnt show users names', () => {
  let tree = renderer.create(
    <SubmissionRow {...defaultProps} anonymous />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('pressing the avatar calls onAvatarPress', () => {
  const onAvatarPress = jest.fn()
  let tree = renderer.create(
    <SubmissionRow {...defaultProps} onAvatarPress={onAvatarPress} />
  ).toJSON()
  let avatar = explore(tree).selectByType('Avatar')
  avatar.props.onPress()
  expect(onAvatarPress).toHaveBeenCalledWith('1')
})

test('shows the eyeball when grades are not posted', () => {
  let submission = mockSubmission({
    status: 'submitted',
    grade: '20%',
    submission: templates.submission({ posted_at: null })
  })
  let tree = renderer.create(
    <SubmissionRow
      {...defaultProps}
      {...submission}
      newGradebookEnabled
    />
  ).toJSON()
  let eye = explore(tree).selectByID('SubmissionRow.hiddenIcon')
  expect(eye).toBeTruthy()
})

test('does not show the eyeball when grade is posted', () => {
  let submission = mockSubmission({
    status: 'submitted',
    grade: '20%',
    submission: templates.submission({ posted_at: '2019-08-29T00:00:00.000Z' })
  })
  let tree = renderer.create(
    <SubmissionRow
      {...defaultProps}
      {...submission}
      newGradebookEnabled
    />
  ).toJSON()
  let eye = explore(tree).selectByID('SubmissionRow.hiddenIcon')
  expect(eye).toBeFalsy()
})

test('does not show the eyeball when not graded', () => {
  let tree = renderer.create(
    <SubmissionRow
      {...defaultProps}
      newGradebookEnabled
    />
  ).toJSON()
  let eye = explore(tree).selectByID('SubmissionRow.hiddenIcon')
  expect(eye).toBeFalsy()
})
