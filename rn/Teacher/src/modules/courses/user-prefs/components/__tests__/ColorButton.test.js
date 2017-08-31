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

// @flow

import React from 'react'
import ColorButton from '../ColorButton'
import explore from '../../../../../../test/helpers/explore'
import renderer from 'react-test-renderer'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

let defaultProps = {
  color: '#fff',
  onPress: jest.fn(),
  selected: false,
}

describe('ColorButton', () => {
  beforeEach(() => {
    jest.resetAllMocks()
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
