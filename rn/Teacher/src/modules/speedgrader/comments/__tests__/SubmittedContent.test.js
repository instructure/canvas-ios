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
import renderer from 'react-test-renderer'
import SubmittedContent from '../SubmittedContent'
import images from '../../../../images'
import explore from '../../../../../test/helpers/explore'

jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

let defaultProps = {
  contentID: '1',
  icon: images.document,
  title: 'foo',
  subtitle: 'bar',
  submissionID: '1',
  attemptIndex: '0',
  attachmentIndex: '0',
  onPress: jest.fn(),
}

beforeEach(() => jest.clearAllMocks())

test('my chat bubbles render correctly', () => {
  const tree = renderer.create(
    <SubmittedContent {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('tapping calls onPress with the correct parameters', () => {
  const tree = renderer.create(
    <SubmittedContent {...defaultProps} />
  ).toJSON()
  const touchable = explore(tree).selectByID('submitted-content.item-1')
  touchable && touchable.props && touchable.props.onPress()
  expect(defaultProps.onPress).toHaveBeenCalledWith('1', '0', '0')
})
