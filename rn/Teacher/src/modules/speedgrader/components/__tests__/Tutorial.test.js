// @flow

import React from 'react'
import { Animated } from 'react-native'
import renderer from 'react-test-renderer'
import Tutorial from '../Tutorial'
import Images from '../../../../images'
import explore from '../../../../../test/helpers/explore'

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
  .mock('react-native-button', () => 'Button')

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
})
