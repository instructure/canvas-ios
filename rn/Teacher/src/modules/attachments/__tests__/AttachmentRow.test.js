//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import React from 'react'
import { AlertIOS } from 'react-native'
import renderer from 'react-test-renderer'
import AttachmentRow, { type Props } from '../AttachmentRow'
import explore from '../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')

describe('AttachmentRow', () => {
  let props
  beforeEach(() => {
    props = {
      completed: true,
      title: 'Attachment 1',
      subtitle: 'Uploading...',
      onPress: jest.fn(),
      testID: 'attachment-row.0',
      onRemovePressed: jest.fn(),
      progress: { loaded: 0, total: 0 },
    }
  })

  it('renders', () => {
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('prompts to remove', () => {
    props.testID = 'attachment-row'
    const spy = jest.fn()
    // $FlowFixMe
    AlertIOS.alert = spy
    const removeBtn: any = explore(render(props).toJSON()).selectByID('attachment-row.remove.btn')
    removeBtn.props.onPress()
    expect(spy).toHaveBeenCalledWith(
      'Remove this attachment?',
      'This action can not be undone.',
      [
        { text: 'Cancel', onPress: null, style: 'cancel' },
        { text: 'Remove', onPress: expect.any(Function), style: 'destructive' },
      ],
    )
  })

  it('calls onRemovePressed when alert confirms', () => {
    const spy = jest.fn()
    props.onRemovePressed = spy
    props.testID = 'attachment-row'
    // $FlowFixMe
    AlertIOS.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
    const removeBtn: any = explore(render(props).toJSON()).selectByID('attachment-row.remove.btn')
    removeBtn.props.onPress()
    expect(spy).toHaveBeenCalled()
  })

  function render (props: Props): any {
    return renderer.create(<AttachmentRow {...props} />)
  }
})
