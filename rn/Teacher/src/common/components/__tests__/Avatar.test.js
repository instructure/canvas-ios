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

import { shallow } from 'enzyme'
import React from 'react'
import Avatar from '../Avatar'

jest.mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')

describe('Avatar', () => {
  it('renders with image', () => {
    let tree = shallow(
      <Avatar
        userName="Dirk Diggles"
        avatarURL="http://www.fillmurray.com/200/300"
      />
    )
    expect(tree.find('Image').prop('source')).toEqual({ uri: 'http://www.fillmurray.com/200/300' })
  })

  it('renders without image', () => {
    let tree = shallow(
      <Avatar
        userName="Lumpy Lumpkin"
      />
    )
    expect(tree.find('Text').prop('children')).toBe('LL')
  })

  it('renders without image but it has a funky name', () => {
    let tree = shallow(
      <Avatar
        userName="   "
      />
    )
    expect(tree.find('Text').prop('children')).toBe('')
  })

  it('renders without default canvas avatar', () => {
    let tree = shallow(
      <Avatar
        userName="Lumpy Lumpkin"
        avatarURL="http://www.fillmurray.com/images/dotted_pic.png"
      />
    )
    expect(tree.find('Text').prop('children')).toBe('LL')
    expect(tree.find('Image').exists()).toBe(false)
  })

  it('renders with border', () => {
    let tree = shallow(
      <Avatar
        userName="Lumpy Lumpkin"
        avatarURL="http://www.fillmurray.com/200/300"
        border={true}
      />
    )
    expect(tree.prop('style')[1].borderStyle).toBe('solid')
  })

  it('renders a TouchableHighlight when onPress is passed in', () => {
    let onPress = jest.fn()
    let tree = shallow(
      <Avatar
        userName="Lumpy Lumpkin"
        avatarURL="http://www.fillmurray.com/200/300"
        onPress={onPress}
      />
    )

    tree.find('TouchableHighlight').simulate('Press')
    expect(onPress).toHaveBeenCalled()
  })
})
