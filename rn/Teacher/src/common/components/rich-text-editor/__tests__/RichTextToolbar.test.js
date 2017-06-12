/* @flow */

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import RichTextToolbar from '../RichTextToolbar'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('../ColorPicker', () => 'ColorPicker')
  .mock('LayoutAnimation', () => ({
    configureNext: jest.fn(),
    easeInEaseOut: jest.fn(),
    Types: {
      easeInEaseOut: jest.fn(),
      spring: jest.fn(),
    },
    Properties: {
      opacity: 1,
    },
  }))

describe('RichTextToolbar', () => {
  const defaultProps = {
    onTappedDone: jest.fn(),
  }

  it('renders', () => {
    expect(
      renderer.create(
        <RichTextToolbar {...defaultProps} />
      ).toJSON()
    ).toMatchSnapshot()
  })

  it('handles undo', () => {
    const undo = jest.fn()
    const component = renderer.create(
      <RichTextToolbar {...defaultProps} undo={undo} />
    )
    pressItem(component, 'undo')
    expect(undo).toHaveBeenCalled()
  })

  it('handles redo', () => {
    const redo = jest.fn()
    const component = renderer.create(
      <RichTextToolbar {...defaultProps} redo={redo} />
    )
    pressItem(component, 'redo')
    expect(redo).toHaveBeenCalled()
  })

  it('handles setting text color', () => {
    const setTextColor = jest.fn()
    const component = renderer.create(
      <RichTextToolbar {...defaultProps} setTextColor={setTextColor} />
    )
    pressItem(component, 'textColor')
    const colorPicker: any = explore(component.toJSON()).query(({ type }) => type === 'ColorPicker')[0]
    colorPicker.props.pickedColor('#fff')
    expect(setTextColor).toHaveBeenCalled()
  })

  it('renders active items', () => {
    const component = renderer.create(
      <RichTextToolbar
        {...defaultProps}
        setTextColor={jest.fn()}
        setBold={jest.fn()}
        active={['textColor:white', 'bold']}
      />
    )
    pressItem(component, 'textColor')
    expect(component.toJSON()).toMatchSnapshot()
  })
})

function pressItem (component: any, item: string) {
  const touchable: any = explore(component.toJSON()).selectByID(`rich-text-toolbar-item-${item}`)
  touchable.props.onPress()
}
