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
