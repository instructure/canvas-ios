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
