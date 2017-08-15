/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import EmptyAttachments from '../EmptyAttachments'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')

test('render', () => {
  expect(
    renderer.create(<EmptyAttachments />).toJSON()
  ).toMatchSnapshot()
})
