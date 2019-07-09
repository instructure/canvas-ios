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

// @flow
import { shallow } from 'enzyme'
import React from 'react'

import RowWithTextInput from '../RowWithTextInput'

describe('RowWithTextInput', () => {
  const defaults = {
    title: '',
  }

  it('renders', () => {
    const tree = shallow(<RowWithTextInput {...defaults} />)
    expect(tree).toMatchSnapshot()
  })

  it('sends text changes', () => {
    const onChangeText = jest.fn()
    const tree = shallow(
      <RowWithTextInput
        {...defaults}
        onChangeText={onChangeText}
        identifier='test'
      />
    )
    tree.find('TextInput').simulate('ChangeText', 'changed')
    expect(onChangeText).toHaveBeenCalledWith('changed', 'test')
  })

  it('sets default value', () => {
    const tree = shallow(
      <RowWithTextInput
        {...defaults}
        defaultValue='test default value'
      />
    )
    expect(tree.find('TextInput').prop('defaultValue')).toBe('test default value')
  })

  it('renders with a title', () => {
    const tree = shallow(<RowWithTextInput title='Title' />)
    expect(tree).toMatchSnapshot()
  })

  it('focuses the input when title is pressed', () => {
    const tree = shallow(<RowWithTextInput title='Title' />)
    const accessories = shallow(tree.find('Row').prop('accessories'))
    const input = { focus: jest.fn() }
    accessories.find('TextInput').getElement().ref(input)
    tree.find('Row').simulate('Press')
    expect(input.focus).toHaveBeenCalled()
  })
})
