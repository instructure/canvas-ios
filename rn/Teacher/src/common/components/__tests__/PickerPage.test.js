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
import React from 'react'
import { shallow } from 'enzyme'

import PickerPage from '../PickerPage'

describe('PickerPage', () => {
  let props
  beforeEach(() => {
    props = {
      onSelect: jest.fn(),
      title: 'Pick Something',
      selectedValue: 'b',
      options: {
        a: 'First One',
        b: 'Second One',
        c: 'Third One',
      },
    }
  })

  it('renders the given options as rows', () => {
    const tree = shallow(<PickerPage {...props} />)
    expect(tree).toMatchSnapshot()
    for (const key of Object.keys(props.options)) {
      const row = shallow(tree.find('FlatList').prop('renderItem')({ item: key }))
      expect(row).toMatchSnapshot(key)
    }
  })

  it('calls the onSelect prop with a row is clicked', () => {
    const tree = shallow(<PickerPage {...props} />)
    const row = shallow(tree.find('FlatList').prop('renderItem')({ item: 'a' }))
    row.simulate('Press')
    expect(props.onSelect).toHaveBeenCalledWith('a')
  })
})
