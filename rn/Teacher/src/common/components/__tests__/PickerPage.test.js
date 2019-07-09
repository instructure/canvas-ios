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
