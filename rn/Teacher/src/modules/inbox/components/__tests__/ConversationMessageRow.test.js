//
// Copyright (C) 2017-present Instructure, Inc.
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

// @flow

import { shallow } from 'enzyme'
import * as React from 'react'
import Hyperlink from 'react-native-hyperlink'
import ConversationMessage from '../ConversationMessageRow'
import { getSession } from '../../../../canvas-api'
import * as template from '../../../../__templates__'

describe('ConversationMessageRow', () => {
  let props
  beforeEach(() => {
    props = {
      conversation: template.conversation(),
      message: template.conversationMessage(),
      firstMessage: false,
      showOptionsActionSheet: jest.fn(),
      navigator: template.navigator(),
      onReply: jest.fn(),
    }
  })

  it('renders the message text', () => {
    const tree = shallow(<ConversationMessage {...props} />)
    expect(tree.find(`[children="${props.message.body}"]`).exists()).toBe(true)
  })

  it('renders attachments', () => {
    const attachment = template.attachment()
    props.message = template.conversationMessage({
      attachments: [ attachment ],
    })
    const tree = shallow(<ConversationMessage {...props} />)
    tree.find(`[testID="inbox.conversation-message-${props.message.id}.attachment-${attachment.id}"]`)
      .simulate('Press')
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/attachment', { modal: true }, { attachment }
    )
  })

  it('renders correctly with author being the logged in user', () => {
    const session = getSession()
    props.conversation = template.conversation({
      id: '1',
      participants: [
        { id: session.user.id, name: session.user.name },
        { id: '99999999', name: 'hey there i am jane' },
      ],
      audience: ['99999999'],
    })
    props.message = template.conversationMessage({
      author_id: session.user.id,
    })

    const tree = shallow(<ConversationMessage {...props} />)
    expect(tree.find('Avatar').props()).toMatchObject({
      userName: session.user.name,
    })
    expect(tree.find('[children="me "]').exists()).toBe(true)
  })

  it('renders correctly with author lots of participants', () => {
    const session = getSession()
    props.conversation = template.conversation({
      id: '1',
      participants: [
        { id: session.user.id, name: 'hey there i am bob' },
        { id: '1', name: 'hey there i am jane' },
        { id: '2', name: 'hey there i am joe' },
        { id: '3', name: 'hey there i am jim' },
      ],
      audience: ['1', '2', '3'],
    })
    props.message = template.conversationMessage({
      author_id: session.user.id,
    })

    const tree = shallow(<ConversationMessage {...props} />)
    expect(tree.find('[children="to 2 others"]').exists()).toBe(true)
  })

  it('renders correctly when there is only one author (current user) and one receiver', () => {
    const session = getSession()
    props.conversation = template.conversation({
      id: '1',
      participants: [
        { id: session.user.id, name: 'hey there i am bob' },
        { id: '5', name: 'hey there i am jane' },
      ],
      audience: ['5', '7'], // This covers a tiny edge case where there is a item in the audience array that doesn't exist in the participants array
    })
    props.message = template.conversationMessage({
      author_id: session.user.id,
    })

    const tree = shallow(<ConversationMessage {...props} />)
    expect(tree.find('[children="me "]').exists()).toBe(true)
    expect(tree.find('[children="to hey there i am jane"]').exists()).toBe(true)
  })

  it('renders correctly when there is only one author (not current user) and one receiver', () => {
    const session = getSession()
    props.conversation = template.conversation({
      id: '1',
      participants: [
        { id: session.user.id, name: 'hey there i am bob' },
        { id: '5', name: 'hey there i am jane' },
      ],
      audience: [session.user.id],
    })
    props.message = template.conversationMessage({
      author_id: '5',
    })

    const tree = shallow(<ConversationMessage {...props} />)
    expect(tree.find('[children="hey there i am jane "]').exists()).toBe(true)
    expect(tree.find('[children="to me"]').exists()).toBe(true)
  })

  it('can be replied to', () => {
    const tree = shallow(<ConversationMessage {...props} />)
    tree.find('[testID="inbox.conversation-message-row.reply-button"]')
      .simulate('Press')
    expect(props.onReply).toHaveBeenCalledWith(props.message.id)
  })

  it('navigates to context card when the avatar is pressed', () => {
    const tree = shallow(<ConversationMessage {...props} />)
    tree.find('Avatar').simulate('Press')
    expect(props.navigator.show).toHaveBeenCalledWith(
      `/courses/1/users/1234`,
      { modal: true, modalPresentationStyle: 'currentContext' },
    )
  })

  it('navigates to a link when pressed', () => {
    const tree = shallow(<ConversationMessage {...props} />)
    const link = 'http://www.google.com'
    tree.find(Hyperlink).simulate('Press', link)
    expect(props.navigator.show).toHaveBeenCalledWith(link, { deepLink: true })
  })
})
