// @flow

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import CommentInput from '../CommentInput'

test('CommentInput renders', () => {
  let tree = renderer.create(
    <CommentInput makeComment={jest.fn()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
