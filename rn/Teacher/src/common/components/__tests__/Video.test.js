// @flow

import 'react-native'
import React from 'react'
import Video from '../Video'
import renderer from 'react-test-renderer'

test('Avatar renders with image', () => {
  let tree = renderer.create(
    <Video
      source={{ uri: 'https://youtube.com/cat_video' }}
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
