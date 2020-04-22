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

import { shallow } from 'enzyme'
import 'react-native'
import React from 'react'
import SubmissionRow from '../SubmissionRow'
import explore from '../../../../../test/helpers/explore'
import renderer from 'react-test-renderer'

import * as templates from '../../../../canvas-api-v2/__templates__'

jest
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../../common/components/Avatar', () => 'Avatar')

const defaultProps = {
  user: templates.user({
    id: '1',
    name: 'Green Latern',
    avatarUrl: 'https://cats.pajamas/',
  }),
  submissionID: null,
  submission: templates.submission(),
  anonymous: false,
  onPress: jest.fn(),
  onAvatarPress: jest.fn(),
  gradingType: 'points',
}

test('unsubmitted ungraded row renders correctly', () => {
  let submission = templates.submission({
    submittedAt: null,
    grade: null,
    state: 'unsubmitted',
  })
  let tree = renderer.create(
    <SubmissionRow {...defaultProps} submission={submission} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('missing ungraded row renders correctly', () => {
  let submission = templates.submission({
    state: 'unsubmitted',
    submittedAt: null,
    missing: true,
    grade: null,
  })
  let tree = renderer.create(
    <SubmissionRow {...defaultProps} submission={submission} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('late graded row renders correctly', () => {
  const submission = templates.submission({
    late: true,
    grade: 'B-',
  })
  let tree = renderer.create(
    <SubmissionRow {...defaultProps} submission={submission} gradingType='gpa_scale' />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('submitted ungraded row renders correctly', () => {
  const submission = templates.submission({
    submittedAt: new Date().toISOString(),
    gradingStatus: 'needs_grading',
  })

  let tree = renderer.create(
    <SubmissionRow {...defaultProps} submission={submission} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('submitted not_graded row renders correctly', () => {
  const submission = templates.submission({
    submittedAt: new Date().toISOString(),
    gradingStatus: 'needs_grading',
  })

  let tree = renderer.create(
    <SubmissionRow {...defaultProps} submission={submission} gradingType='not_graded' />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('excused row renders correctly', () => {
  const submission = templates.submission({
    missing: true,
    excused: true,
  })
  let tree = renderer.create(
    <SubmissionRow {...defaultProps} submission={submission} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('onPress called on tap', () => {
  const onPress = jest.fn()
  let submission = templates.submission()
  let row = explore(renderer.create(
    <SubmissionRow {...defaultProps} submission={submission} onPress={onPress} />
  ).toJSON()).selectByID(`submission-${defaultProps.user.id}`)
  row && row.props.onPress()
  expect(onPress).toHaveBeenCalledWith(defaultProps.user.id)
})

test('anonymous grading doesnt show users names', () => {
  let submission = templates.submission({
    state: 'unsubmitted',
    submittedAt: null,
    grade: null,
  })
  let tree = renderer.create(
    <SubmissionRow
      {...defaultProps}
      submission={submission}
      anonymous
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders name', () => {
  let user = templates.user({
    id: '1',
    name: 'Alice',
  })
  let tree = shallow(<SubmissionRow {...defaultProps} user={user} />)
  expect(tree.find('[children="Alice"]').exists()).toBe(true)
})

test('renders pronouns', () => {
  let user = templates.user({
    id: '1',
    name: 'Alice',
    pronouns: 'She/Her',
  })
  let tree = shallow(<SubmissionRow {...defaultProps} user={user} />)
  expect(tree.find('[children="Alice (She/Her)"]').exists()).toBe(true)
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

test('anonymous avatar press', () => {
  let spy = jest.fn()
  let tree = shallow(<SubmissionRow {...defaultProps} anonymous={true} onAvatarPress={spy} />)
  tree.find('Avatar').simulate('Press')
  expect(spy).not.toHaveBeenCalled()
})

test('shows the eyeball when grades are not posted', () => {
  let submission = templates.submission({
    submittedAt: '2017-04-05T15:12:45Z',
    grade: '20%',
    postedAt: null,
  })
  let tree = renderer.create(
    <SubmissionRow
      {...defaultProps}
      submission={submission}
    />
  ).toJSON()
  let eye = explore(tree).selectByID('SubmissionRow.hiddenIcon')
  expect(eye).toBeTruthy()
})

test('does not show the eyeball when grade is posted', () => {
  let submission = templates.submission({
    submittedAt: '2017-04-05T15:12:45Z',
    grade: '20%',
    postedAt: '2019-08-29T00:00:00.000Z',
  })
  let tree = renderer.create(
    <SubmissionRow
      {...defaultProps}
      submission={submission}
    />
  ).toJSON()
  let eye = explore(tree).selectByID('SubmissionRow.hiddenIcon')
  expect(eye).toBeFalsy()
})

test('does not show the eyeball when not graded', () => {
  let submission = templates.submission({
    submittedAt: null,
    grade: null,
    postedAt: null,
  })

  let tree = renderer.create(
    <SubmissionRow
      {...defaultProps}
      submission={submission}
    />
  ).toJSON()
  let eye = explore(tree).selectByID('SubmissionRow.hiddenIcon')
  expect(eye).toBeFalsy()
})
