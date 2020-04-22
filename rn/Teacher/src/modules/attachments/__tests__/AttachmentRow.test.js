//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import React from 'react'
import { Alert } from 'react-native'
import renderer from 'react-test-renderer'
import AttachmentRow, { type Props } from '../AttachmentRow'
import explore from '../../../../test/helpers/explore'

jest
  .mock('react-native/Libraries/Components/Button', () => 'Button')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

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
    Alert.alert = spy
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
    Alert.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
    const removeBtn: any = explore(render(props).toJSON()).selectByID('attachment-row.remove.btn')
    removeBtn.props.onPress()
    expect(spy).toHaveBeenCalled()
  })

  function render (props: Props): any {
    return renderer.create(<AttachmentRow {...props} />)
  }
})
