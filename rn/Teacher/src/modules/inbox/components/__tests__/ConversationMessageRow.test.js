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
import 'react-native'
import React from 'react'
import ConversationMessage from '../ConversationMessageRow'
import { getSession, setSession } from '../../../../canvas-api'
import explore from '../../../../../test/helpers/explore'

const template = {
  ...require('../../../../__templates__/conversations'),
  ...require('../../../../__templates__/users'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../__templates__/session'),
}

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../common/components/Avatar', () => 'Avatar')

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

it('renders correctly', () => {
  const convo = template.conversation({
    id: '1',
  })
  const message = template.conversationMessage()

  const tree = renderer.create(
    <ConversationMessage conversation={convo} message={message} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders correctly with author being the logged in user', () => {
  const session = getSession()
  const convo = template.conversation({
    id: '1',
    participants: [
      { id: session.user.id, name: 'hey there i am bob' },
      { id: '99999999', name: 'hey there i am jane' },
    ],
    audience: ['99999999'],
  })
  const message = template.conversationMessage({
    author_id: session.user.id,
  })

  const tree = renderer.create(
    <ConversationMessage conversation={convo} message={message} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders correctly with author lots of participants', () => {
  const session = getSession()

  const convo = template.conversation({
    id: '1',
    participants: [
      { id: session.user.id, name: 'hey there i am bob' },
      { id: '1', name: 'hey there i am jane' },
      { id: '2', name: 'hey there i am joe' },
      { id: '3', name: 'hey there i am jim' },
    ],
    audience: ['1', '2', '3'],
  })
  const message = template.conversationMessage({
    author_id: session.user.id,
  })

  const tree = renderer.create(
    <ConversationMessage conversation={convo} message={message} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('navigates to compose when reply to first message button pressed', () => {
  const session = template.session({
    user: {
      ...template.session().user,
      id: '1',
    },
  })
  setSession(session)
  const conversation = template.conversation({
    id: '1',
    participants: [
      { id: '1', name: 'hey there i am bob' },
      { id: '2', name: 'hey there i am joe' },
      { id: '3', name: 'hey there i am jim' },
    ],
    audience: ['2', '3'],
    context_name: 'Course 1',
    context_code: 'course_1',
    subject: 'Subject 1',
  })
  const navigator = template.navigator({ show: jest.fn() })
  const message = template.conversationMessage({
    author_id: session.user.id,
  })
  const props = {
    conversation,
    navigator,
    message,
    firstMessage: true,
  }
  const tree = renderer.create(
    <ConversationMessage {...props} />
  ).toJSON()
  const replyButton: any = explore(tree).selectByID('inbox.conversation-message-row.reply-button')
  replyButton.props.onPress()
  expect(navigator.show).toHaveBeenCalledWith(
    '/conversations/1/add_message',
    { modal: true },
    {
      recipients: [
        { id: '2', name: 'hey there i am joe' },
        { id: '3', name: 'hey there i am jim' },
      ],
      contextName: 'Course 1',
      contextCode: 'course_1',
      subject: 'Subject 1',
      canSelectCourse: false,
      canEditSubject: false,
      navBarTitle: 'Reply',
    },
  )
})

it('navigates to context card when the avatar is pressed', () => {
  const convo = template.conversation({
    id: '1',
  })
  const message = template.conversationMessage()
  const navigator = template.navigator()

  let view = renderer.create(
    <ConversationMessage navigator={navigator} conversation={convo} message={message} />
  ).toJSON()
  let avatar = explore(view).selectByType('Avatar')
  avatar.props.onPress()

  expect(navigator.show).toHaveBeenCalledWith(
    `/courses/1/users/1234`,
    { modal: true, modalPresentationStyle: 'currentContext' },
  )
})

it('navigates to a link when pressed', () => {
  const convo = template.conversation({})
  const message = template.conversationMessage()
  const navigator = template.navigator()

  let instance = renderer.create(
    <ConversationMessage navigator={navigator} conversation={convo} message={message} />
  ).getInstance()

  const link = 'http://www.google.com'
  instance.handleLink(link)

  expect(navigator.show).toHaveBeenCalledWith(link, { deepLink: true })
})
