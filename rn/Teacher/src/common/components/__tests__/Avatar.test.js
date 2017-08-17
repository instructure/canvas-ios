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
