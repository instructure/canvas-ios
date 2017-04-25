/* @flow */

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import RichTextToolbar from '../RichTextToolbar'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')

describe('RichTextToolbar', () => {
  const defaultProps = {
    onTappedDone: jest.fn(),
  }

  it('renders', () => {
    expect(
      renderer.create(
        <RichTextToolbar {...defaultProps} />
      ).toJSON()
    )
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
})

function pressItem (component: any, item: string) {
  const touchable: any = explore(component.toJSON()).selectByID(`rich-text-toolbar-item-${item}`)
  touchable.props.onPress()
}
