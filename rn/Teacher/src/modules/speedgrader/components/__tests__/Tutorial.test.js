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

import React from 'react'
import { Animated, NativeModules } from 'react-native'
import renderer from 'react-test-renderer'
import Tutorial from '../Tutorial'
import Images from '../../../../images'
import explore from '../../../../../test/helpers/explore'

const { NativeAccessibility } = NativeModules

jest
  .mock('AsyncStorage', () => ({
    getItem: jest.fn(() => Promise.resolve()),
    setItem: jest.fn(() => Promise.resolve()),
  }))
  .mock('Animated', () => ({
    Value: jest.fn(),
    timing: () => ({ start: jest.fn() }),
    View: 'Animated.View',
  }))
  .mock('TouchableOpacity', () => 'TouchableOpacity')

let defaultProps = {
  tutorials: [{
    id: '1',
    text: 'Some text',
    image: Images.speedGrader.swipe,
  }],
}

describe('Tutorial', () => {
  beforeEach(() => jest.resetAllMocks())
  it('will render null before data from async storage has been retrieved', () => {
    let tree = renderer.create(
      <Tutorial {...defaultProps} />
    ).toJSON()

    expect(tree).toBeNull()
  })

  it('will render the tutorial after data from async storage has been retrieved', async () => {
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

  it('focus current tutorial function should work', async () => {
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

  it('focus current tutorial function should not do anything when there is no current tutorial', async () => {
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
