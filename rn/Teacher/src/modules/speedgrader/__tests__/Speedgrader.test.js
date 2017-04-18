// @flow

import React from 'react'
import Speedgrader from '../Speedgrader'
import * as navigatorTemplates from '../../../__templates__/react-native-navigation'
import renderer from 'react-test-renderer'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

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
