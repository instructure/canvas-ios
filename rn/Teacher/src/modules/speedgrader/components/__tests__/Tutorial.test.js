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

import { shallow } from 'enzyme'
import React from 'react'
import { Animated, NativeModules } from 'react-native'
import Tutorial from '../Tutorial'
import Images from '../../../../images'

const { NativeAccessibility } = NativeModules

jest
  .mock('@react-native-community/async-storage', () => ({
    getItem: jest.fn(() => Promise.resolve()),
    setItem: jest.fn(() => Promise.resolve()),
  }))
  .mock('react-native/Libraries/Animated/src/Animated', () => ({
    Value: jest.fn(),
    timing: () => ({ start: jest.fn() }),
    View: 'Animated.View',
  }))
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

let defaultProps = {
  tutorials: [{
    id: '1',
    text: 'Some text',
    image: Images.speedGrader.swipe,
  }],
}

describe('Tutorial', () => {
  beforeEach(() => jest.clearAllMocks())
  it('will render null before data from async storage has been retrieved', () => {
    let tree = shallow(
      <Tutorial {...defaultProps} />
    )
    expect(tree.isEmptyRender()).toBe(true)
  })

  it('will render the tutorial after data from async storage has been retrieved', async () => {
    let tree = shallow(
      <Tutorial {...defaultProps} />
    )
    await Promise.resolve() // wait for setup to finish

    expect(tree.find('Image').prop('source')).toBe(Images.speedGrader.swipe)
  })

  it('will update hasSeen when onPress is called', async () => {
    let oldTiming = Animated.timing
    let start = jest.fn((done) => { done() })
    Animated.timing = () => ({ start })

    let tree = shallow(
      <Tutorial {...defaultProps} />
    )
    await Promise.resolve() // wait for setup to finish

    await tree.find('[testID="tutorial.button-1"]').simulate('Press')

    expect(tree.state()).toEqual({
      hasLoaded: true,
      hasSeen: { '1': true },
      currentTutorial: undefined,
    })

    Animated.timing = oldTiming
  })

  it('focus current tutorial function should work', async () => {
    let tree = shallow(
      <Tutorial {...defaultProps} />
    )
    await Promise.resolve() // wait for setup to finish

    jest.useFakeTimers()
    tree.instance().focusCurrentTutorial()
    jest.runAllTimers()
    expect(NativeAccessibility.focusElement).toHaveBeenCalledWith(`1-title`)
  })

  it('focus current tutorial function should not do anything when there is no current tutorial', async () => {
    let tree = shallow(
      <Tutorial tutorials={[]} />
    )
    await Promise.resolve() // wait for setup to finish

    tree.instance().focusCurrentTutorial()
    expect(NativeAccessibility.focusElement).not.toHaveBeenCalled()
  })
})
