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

import 'react-native'
import React from 'react'
import Avatar from '../Avatar'
import renderer from 'react-native-test-utils'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

test('Avatar renders with image', () => {
  let tree = renderer(
    <Avatar
      userName="Dirk Diggles"
      avatarURL="http://www.fillmurray.com/200/300"
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('Avatar renders without image', () => {
  let tree = renderer(
    <Avatar
      userName="Lumpy Lumpkin"
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('Avatar renders without image but it has a funky name', () => {
  let tree = renderer(
    <Avatar
      userName="   "
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('Avatar renders without default canvas avatar', () => {
  let tree = renderer(
    <Avatar
      userName="Lumpy Lumpkin"
      avatarURL="http://www.fillmurray.com/images/dotted_pic.png"
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('Avatar renders with border', () => {
  let tree = renderer(
    <Avatar
      userName="Lumpy Lumpkin"
      avatarURL="http://www.fillmurray.com/images/dotted_pic.png"
      border={true}
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('Avatar renders a TouchableHighlight when onPress is passed in', () => {
  let onPress = jest.fn()
  let view = renderer(
    <Avatar
      userName="Lumpy Lumpkin"
      avatarURL="http://www.fillmurray.com/images/dotted_pic.png"
      onPress={onPress}
    />
  )

  let button = view.query('TouchableHighlight')
  button.simulate('press')
  expect(onPress).toHaveBeenCalled()
})
