// @flow

import React from 'react'
import Compose from '../Compose'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'

let template = {
  ...require('../../../__templates__/helm'),
}

let defaultProps = {
  navigator: template.navigator({
    dismiss: jest.fn(),
  }),
}

describe('Compose', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders', () => {
    let tree = renderer.create(
      <Compose {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('dismisses the modal when cancel is pressed', () => {
    let instance = renderer.create(
      <Compose {...defaultProps} />
    ).getInstance()

    instance.cancelCompose()
    expect(defaultProps.navigator.dismiss).toHaveBeenCalled()
  })

  it('toggles the send to all', () => {
    let tree = renderer.create(
      <Compose {...defaultProps} />
    )

    let toggle = explore(tree.toJSON()).selectByID('compose-message.send-all-toggle') || {}
    toggle.props.onValueChange(true)

    expect(tree.getInstance().state.sendToAll).toBeTruthy()
  })
})
