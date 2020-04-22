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

/* @flow */

import React from 'react'
import renderer from 'react-test-renderer'

import RichTextToolbar from '../RichTextToolbar'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/LayoutAnimation/LayoutAnimation', () => ({
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
    pressItem(component, 'setTextColor')
    component.getInstance()._pickColor('#fff')
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
    pressItem(component, 'setTextColor')
    expect(component.toJSON()).toMatchSnapshot()
  })
})

function pressItem (component: any, item: string) {
  const touchable: any = explore(component.toJSON()).selectByID(`rich-text-toolbar-item-${item}`)
  touchable.props.onPress()
}
