// @flow

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import ChatBubble from '../ChatBubble'

test('my chat bubbles render correctly', () => {
  let tree = renderer.create(
    <ChatBubble from="me" message="Hello, World!"/>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('their chat bubbles render correctly', () => {
  let tree = renderer.create(
    <ChatBubble from="them" message="Hello, back!" />
  )
  expect(tree).toMatchSnapshot()
})
