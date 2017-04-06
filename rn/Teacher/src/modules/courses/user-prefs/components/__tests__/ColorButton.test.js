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
