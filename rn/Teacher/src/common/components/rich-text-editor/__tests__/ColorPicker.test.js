/* @flow */

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import ColorPicker from '../ColorPicker'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')

describe('ColorPicker', () => {
  const defaultProps = {
    pickedColor: jest.fn(),
  }

  it('renders', () => {
    expect(
      renderer.create(
        <ColorPicker {...defaultProps} />
      ).toJSON()
    ).toMatchSnapshot()
  })

  it('triggers picked color', () => {
    const pickedColor = jest.fn()
    const tree = renderer.create(
      <ColorPicker {...defaultProps} pickedColor={pickedColor} />
    ).toJSON()

    const white: any = explore(tree).selectByID('color-picker-option-white')
    white.props.onPress()

    expect(pickedColor).toHaveBeenCalledWith('white')

    const black: any = explore(tree).selectByID('color-picker-option-black')
    black.props.onPress()

    expect(pickedColor).toHaveBeenCalledWith('black')
  })
})
