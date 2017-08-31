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
