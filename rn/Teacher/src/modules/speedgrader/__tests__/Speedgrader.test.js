// @flow

import React from 'react'
import Speedgrader from '../Speedgrader'
import * as navigatorTemplates from '../../../__templates__/react-native-navigation'
import renderer from 'react-test-renderer'

jest.mock('SegmentedControlIOS', () => 'SegmentedControlIOS')
jest.mock('react-native-interactable', () => ({
  View: 'Interactable.View',
}))

let templates = { ...navigatorTemplates }

let defaultProps = {
  navigator: templates.navigator(),
}

describe('Speedgrader', () => {
  beforeEach(() => {
    jest.resetAllMocks()
  })

  it('renders', () => {
    let tree = renderer.create(
      <Speedgrader {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
    expect(defaultProps.navigator.setTitle).toHaveBeenCalledWith({
      title: 'Speedgrader',
    })
    expect(defaultProps.navigator.setOnNavigatorEvent).toHaveBeenCalled()
  })

  it('switches between different tabs', () => {
    let tree = renderer.create(
      <Speedgrader {...defaultProps} />
    )

    let instance = tree.getInstance()
    instance.drawer.drawer = { snapTo: jest.fn() }
    let event = {
      nativeEvent: {
        selectedSegmentIndex: 0,
      },
    }
    instance.changeTab(event)
    expect(instance.state.selectedIndex).toEqual(0)

    event.nativeEvent.selectedSegmentIndex = 1
    instance.drawer.drawer = { snapTo: jest.fn() }
    instance.changeTab(event)
    expect(instance.state.selectedIndex).toEqual(1)

    event.nativeEvent.selectedSegmentIndex = 2
    instance.drawer.drawer = { snapTo: jest.fn() }
    instance.changeTab(event)
    expect(instance.state.selectedIndex).toEqual(2)
  })

  it('calls dismissModal when done is pressed', () => {
    let tree = renderer.create(
      <Speedgrader {...defaultProps} />
    )

    tree.getInstance().onNavigatorEvent({
      type: 'NavBarButtonPress',
      id: 'done',
    })

    expect(defaultProps.navigator.dismissModal).toHaveBeenCalled()
  })
})
