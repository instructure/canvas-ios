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

/* eslint-disable flowtype/require-valid-file-annotation */
import 'react-native'
import React from 'react'
import FilterHeader from '../FilterHeader'
import explore from '../../../../../test/helpers/explore'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

it('renders correctly', () => {
  const tree = renderer.create(
    <FilterHeader selected={'all'} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('calls the passed in callback', () => {
  const callback = jest.fn()
  const tree = renderer.create(
    <FilterHeader selected={'all'} onFilterChange={callback}/>
  ).toJSON()
  const button = explore(tree).selectByID('inbox.filter-btn-unread') || {}
  button.props.onPress()
  expect(callback).toHaveBeenCalledWith('unread')
})
