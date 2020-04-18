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

// @flow

import React from 'react'
import ColorButton from '../ColorButton'
import explore from '../../../../../../test/helpers/explore'
import renderer from 'react-test-renderer'

jest.mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')

let defaultProps = {
  color: '#fff',
  onPress: jest.fn(),
  selected: false,
}

describe('ColorButton', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('renders unselected', () => {
    let tree = renderer.create(
      <ColorButton {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders selected', () => {
    // it doesn't like the defaultProps spread with the boolean prop
    let tree = renderer.create(
      <ColorButton color='#333' onPress={() => {}} selected />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('calls onPress when it is pressed', () => {
    let tree = renderer.create(
      <ColorButton {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID('colorButton.#fff') || {}
    button.props.onPress()

    expect(defaultProps.onPress).toHaveBeenCalledWith('#fff')
  })
})
