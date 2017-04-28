// @flow

import 'react-native'
import React from 'react'
import Avatar from '../Avatar'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('Avatar renders with image', () => {
  let tree = renderer.create(
    <Avatar
      userName="Dirk Diggles"
      avatarURL="http://www.fillmurray.com/200/300"
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('Avatar renders without image', () => {
  let tree = renderer.create(
    <Avatar
      userName="Lumpy Lumpkin"
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
