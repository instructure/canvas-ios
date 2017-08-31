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

/* @flow */

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import ColorPicker from '../ColorPicker'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')

describe('ColorPicker', () => {
  const defaultProps = {
    pickedColor: jest.fn(),
  }

  it('renders', () => {
    expect(
      renderer.create(
        <ColorPicker {...defaultProps} />
      ).toJSON()
    ).toMatchSnapshot()
  })

  it('triggers picked color', () => {
    const pickedColor = jest.fn()
    const tree = renderer.create(
      <ColorPicker {...defaultProps} pickedColor={pickedColor} />
    ).toJSON()

    const white: any = explore(tree).selectByID('color-picker-option-white')
    white.props.onPress()

    expect(pickedColor).toHaveBeenCalledWith('white')

    const black: any = explore(tree).selectByID('color-picker-option-black')
    black.props.onPress()

    expect(pickedColor).toHaveBeenCalledWith('black')
  })
})
