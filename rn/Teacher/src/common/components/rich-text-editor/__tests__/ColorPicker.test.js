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

/* @flow */

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import ColorPicker from '../ColorPicker'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')

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

    const white: any = explore(tree).selectByID('color-picker-option-#FFFFFF')
    white.props.onPress()

    expect(pickedColor).toHaveBeenCalledWith('#FFFFFF')

    const black: any = explore(tree).selectByID('color-picker-option-#2D3B45')
    black.props.onPress()

    expect(pickedColor).toHaveBeenCalledWith('#2D3B45')
  })
})
