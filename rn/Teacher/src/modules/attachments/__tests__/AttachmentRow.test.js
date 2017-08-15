/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import AttachmentRow from '../AttachmentRow'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')

describe('AttachmentRow', () => {
  it('renders', () => {
    expect(
      renderer.create(
        <AttachmentRow
          title='Attachment 1'
          subtitle='Uploading...'
          onPress={jest.fn()}
          testID='attachment-row.0'
          onRemovePressed={jest.fn()}
        />
      )
    ).toMatchSnapshot()
  })
})
