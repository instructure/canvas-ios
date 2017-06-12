/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import RichTextEditor from '../RichTextEditor'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../common/components/rich-text-editor/RichTextEditor')
  .mock('../../../routing/Screen')

describe('RichTextEditor', () => {
  it('renders RichTextEditor in a Screen', () => {
    expect(
      renderer.create(<RichTextEditor />).toJSON()
    ).toMatchSnapshot()
  })
})
