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
import 'react-native'
import GroupRow from '../GroupRow'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'

jest.mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')

let props = {
  style: { margin: 8 },
  id: '1',
  color: 'blue',
  name: 'Study Group 3',
  contextName: 'Bio 101',
  term: 'Spring 2020',
  onPress: jest.fn(),
}

describe('GroupRow', () => {
  beforeEach(() => jest.clearAllMocks())

  it('renders', () => {
    const tree = renderer.create(
      <GroupRow {...props} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders without a term', () => {
    const tree = renderer.create(
      <GroupRow {...props} term={undefined} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('calls onPress with the group id when pressed', () => {
    const view = renderer.create(
      <GroupRow {...props} />
    )
    let group = explore(view.toJSON()).selectByID('group-row-1') || {}
    group.props.onPress()
    expect(props.onPress).toHaveBeenCalledWith('1')
  })
})
