// @flow

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import SubmittedContent from '../SubmittedContent'
import images from '../../../../images'
import explore from '../../../../../test/helpers/explore'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')

test('my chat bubbles render correctly', () => {
  const tree = renderer.create(
    <SubmittedContent
      contentID='1'
      icon={images.document}
      title='foo'
      subtitle='bar'
      onPress={jest.fn()}
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('tapping calls onPress', () => {
  const onPress = jest.fn()
  const tree = renderer.create(
    <SubmittedContent
      contentID='1'
      icon={images.document}
      title='foo'
      subtitle='bar'
      onPress={onPress}
    />
  ).toJSON()
  const touchable = explore(tree).selectByID('submitted-content.item-1')
  touchable && touchable.props && touchable.props.onPress()
  expect(onPress).toHaveBeenCalled()
})
