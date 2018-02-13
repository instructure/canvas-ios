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
import renderer from 'react-test-renderer'
import SubmittedContent from '../SubmittedContent'
import images from '../../../../images'
import explore from '../../../../../test/helpers/explore'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')

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

beforeEach(() => jest.resetAllMocks())

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
