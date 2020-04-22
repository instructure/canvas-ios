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

import React from 'react'
import { Animated, NativeModules } from 'react-native'
import renderer from 'react-test-renderer'
import Tutorial from '../Tutorial'
import Images from '../../../../images'
import explore from '../../../../../test/helpers/explore'

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
    let tree = renderer.create(
      <Tutorial {...defaultProps} />
    ).toJSON()

    expect(tree).toBeNull()
  })

  it('will render the tutorial after data from async storage has been retrieved', () => {
    let tree = renderer.create(
      <Tutorial {...defaultProps} />
    )
    tree.getInstance().setState({
      hasLoaded: true,
      hasSeen: {},
      currentTutorial: defaultProps.tutorials[0],
    })

    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('will figure out what tutorial to show in setup', async () => {
    let tree = renderer.create(
      <Tutorial {...defaultProps} />
    )

    await tree.getInstance().setup()

    expect(tree.getInstance().state).toEqual({
      hasLoaded: true,
      hasSeen: {},
      currentTutorial: defaultProps.tutorials[0],
    })
  })

  it('will update hasSeen when onPress is called', async () => {
    let oldTiming = Animated.timing
    let start = jest.fn()
    Animated.timing = () => ({ start })

    let tree = renderer.create(
      <Tutorial {...defaultProps} />
    )
    tree.getInstance().setState({
      hasLoaded: true,
      hasSeen: {},
      currentTutorial: defaultProps.tutorials[0],
    })

    let button = explore(tree.toJSON()).selectByID('tutorial.button-1') || {}
    let promise = button.props.onPress()

    start.mock.calls[0][0]()
    await promise

    expect(tree.getInstance().state).toEqual({
      hasLoaded: true,
      hasSeen: { '1': true },
      currentTutorial: undefined,
    })

    Animated.timing = oldTiming
  })

  it('focus current tutorial function should work', () => {
    let tree = renderer.create(
      <Tutorial {...defaultProps} />
    )
    const currentTutorial = defaultProps.tutorials[0]
    tree.getInstance().setState({
      hasLoaded: true,
      hasSeen: {},
      currentTutorial,
    })

    jest.useFakeTimers()
    tree.getInstance().focusCurrentTutorial()
    jest.runAllTimers()
    expect(NativeAccessibility.focusElement).toHaveBeenCalledWith(`${currentTutorial.id}-title`)
  })

  it('focus current tutorial function should not do anything when there is no current tutorial', () => {
    let tree = renderer.create(
      <Tutorial {...defaultProps} />
    )
    tree.getInstance().setState({
      hasLoaded: true,
      hasSeen: {},
      currentTutorial: null,
    })

    tree.getInstance().focusCurrentTutorial()
    expect(NativeAccessibility.focusElement).not.toHaveBeenCalled()
  })
})
