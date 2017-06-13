// @flow

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import SubmittedContent from '../SubmittedContent'
import images from '../../../../images'
import explore from '../../../../../test/helpers/explore'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')

let defaultProps = {
  contentID: '1',
  icon: images.document,
  title: 'foo',
  subtitle: 'bar',
  submissionID: '1',
  attemptIndex: '0',
  attachmentIndex: '0',
  onPress: jest.fn(),
}

beforeEach(() => jest.resetAllMocks())

test('my chat bubbles render correctly', () => {
  const tree = renderer.create(
    <SubmittedContent {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('tapping calls onPress with the correct parameters', () => {
  const tree = renderer.create(
    <SubmittedContent {...defaultProps} />
  ).toJSON()
  const touchable = explore(tree).selectByID('submitted-content.item-1')
  touchable && touchable.props && touchable.props.onPress()
  expect(defaultProps.onPress).toHaveBeenCalledWith('1', '0', '0')
})
