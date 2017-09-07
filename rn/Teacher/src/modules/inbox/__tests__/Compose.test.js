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

// @flow

import React from 'react'
import { Compose, mapStateToProps } from '../Compose'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'
import api from 'instructure-canvas-api'
import { apiResponse } from 'instructure-canvas-api/utils/testHelpers'

let template = {
  ...require('../../../__templates__/helm'),
  ...require('../../../__templates__/addressBook'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/conversations'),
}

let defaultProps = {
  navigator: template.navigator({
    dismiss: jest.fn(),
  }),
  refreshInboxSent: jest.fn(),
}

jest
  .mock('LayoutAnimation', () => ({
    configureNext: jest.fn(),
    easeInEaseOut: jest.fn(),
    Types: {
      easeInEaseOut: jest.fn(),
      spring: jest.fn(),
    },
    Properties: {
      opacity: 1,
    },
  }))
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('instructure-canvas-api')
  .mock('../../../routing/Screen')

describe('Compose', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders', () => {
    let tree = renderer.create(
      <Compose {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('allows for a navbar title to be passed in as a prop', () => {
    let tree = renderer.create(
      <Compose {...defaultProps} navBarTitle='title' />
    ).toJSON()

    let screen = explore(tree).selectByType('Screen') || {}
    expect(screen.props.title).toEqual('title')
  })

  it('doesnt show the course select when told not to', () => {
    let tree = renderer.create(
      <Compose {...defaultProps} showCourseSelect={false} />
    ).toJSON()
    let courseSelect = explore(tree).selectByID('compose.course-select')
    expect(courseSelect).toBeNull()
  })

  it('renders with passed in recipients', () => {
    const u1 = template.addressBookResult({
      id: '1',
    })
    const u2 = template.addressBookResult({
      id: '2',
    })

    let tree = renderer.create(
      <Compose {...defaultProps} recipients={[u1, u2]} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('doesnt show the To placeholder when there are recipients', () => {
    const recipient = template.addressBookResult({ id: '1' })
    let tree = renderer.create(
      <Compose {...defaultProps} recipients={[recipient]} />
    ).toJSON()
    let recipientsPlaceholder = explore(tree).selectByID('compose.recipients-placeholder')
    expect(recipientsPlaceholder).toBeNull()
  })

  it('renders after picking a course', () => {
    let course = template.course()
    let onSelect = jest.fn()
    const show = jest.fn((path, options, passthrough) => {
      onSelect = passthrough.onSelect
    })

    const navigator = template.navigator({ show, dismiss: jest.fn() })
    let component = renderer.create(
      <Compose {...defaultProps} navigator={navigator} />
    )

    component.getInstance().selectCourse()
    onSelect(course)
    expect(navigator.pop).toHaveBeenCalled()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('sets all the data and then send the message', () => {
    let course = template.course()
    const recipient = template.addressBookResult()
    let component = renderer.create(
      <Compose {...defaultProps} navigator={navigator} />
    )
    const instance = component.getInstance()
    instance._bodyChanged('body of the message')
    instance._subjectChanged('subject of the message')
    instance.setStateAndUpdate({ contextName: course.name, contextCode: `course_${course.id}` })
    instance.setStateAndUpdate({ recipients: [recipient] })
    expect(instance.state.sendDisabled).toEqual(false)
  })

  it('gets and sets recipients', () => {
    const recipient = template.addressBookResult()
    let onSelect = jest.fn()
    let onCancel = jest.fn()
    const show = jest.fn((path, options, passthrough) => {
      onSelect = passthrough.onSelect
      onCancel = passthrough.onCancel
    })

    const navigator = template.navigator({ show, dismiss: jest.fn() })
    let component = renderer.create(
      <Compose {...defaultProps} navigator={navigator} />
    )

    component.getInstance().selectCourse()
    onSelect(template.course())
    component.getInstance()._openAddressBook()
    onSelect([recipient])
    expect(navigator.dismiss).toHaveBeenCalled()
    expect(component.getInstance().state.recipients).toEqual([recipient])
    onCancel()
    expect(navigator.dismiss).toHaveBeenCalled()
  })

  it('dismisses the modal when cancel is pressed', () => {
    let instance = renderer.create(
      <Compose {...defaultProps} />
    ).getInstance()

    instance.cancelCompose()
    expect(defaultProps.navigator.dismiss).toHaveBeenCalled()
  })

  it('toggles the send to all', () => {
    let tree = renderer.create(
      <Compose {...defaultProps} />
    )

    let toggle = explore(tree.toJSON()).selectByID('compose-message.send-all-toggle') || {}
    toggle.props.onValueChange(true)

    expect(tree.getInstance().state.sendToAll).toBeTruthy()
  })

  it('deletes a recipient from state', () => {
    let tree = renderer.create(
      <Compose {...defaultProps} />
    )
    let instance = tree.getInstance()

    instance.setState({
      recipients: [
        {
          id: '1',
          name: 'Donald Trump',
        },
      ],
    })

    instance._deleteRecipient('1')

    expect(instance.state.recipients.length).toBe(0)
  })

  it('creates conversation on send', () => {
    const u1 = template.addressBookResult({
      id: '1',
    })
    const props = {
      ...defaultProps,
      recipients: [u1],
      subject: 'new conversation subject',
      onlySendIndividualMessages: false,
    }

    let response = apiResponse(template.conversation())
    api.createConversation.mockReturnValueOnce(response())

    const screen = renderer.create(
      <Compose {...props} />
    )
    const body: any = explore(screen.toJSON()).selectByID('compose-message.body-text-input')
    body.props.onChangeText('new conversation')
    const sendButton: any = explore(screen.toJSON()).selectRightBarButton('compose-message.send')
    sendButton.action()
    expect(api.createConversation).toHaveBeenCalledWith({
      recipients: ['1'],
      body: 'new conversation',
      subject: 'new conversation subject',
      group_conversation: true,
    })
  })

  it('adds message on send', () => {
    const u1 = template.addressBookResult({
      id: '1',
    })
    const props = {
      ...defaultProps,
      recipients: [u1],
      subject: 'new conversation subject',
      onlySendIndividualMessages: true,
      conversationID: '1',
      includedMessages: [template.conversationMessage({ id: '1' }), template.conversationMessage({ id: '2' })],
    }

    let response = apiResponse(template.conversation(props.includedMessages[0]))
    api.addMessage.mockReturnValueOnce(response())

    const screen = renderer.create(
      <Compose {...props} />
    )
    const body: any = explore(screen.toJSON()).selectByID('compose-message.body-text-input')
    body.props.onChangeText('new conversation')
    const sendButton: any = explore(screen.toJSON()).selectRightBarButton('compose-message.send')
    sendButton.action()
    expect(api.addMessage).toHaveBeenCalledWith('1', {
      recipients: ['1'],
      body: 'new conversation',
      subject: 'new conversation subject',
      group_conversation: true,
      bulk_message: 1,
      included_messages: ['1', '2'],
    })
  })

  it('refreshes conversation on unmount if adding reply', () => {
    const props = {
      ...defaultProps,
      refreshConversationDetails: jest.fn(),
      conversationID: '1',
    }
    const screen = renderer.create(
      <Compose {...props} />
    )
    screen.getInstance().componentWillUnmount()
    expect(props.refreshConversationDetails).toHaveBeenCalledWith('1')
  })

  it('does not refresh conversation on unmount', () => {
    const props = {
      ...defaultProps,
      refreshConversationDetails: jest.fn(),
    }
    const screen = renderer.create(
      <Compose {...props} />
    )
    screen.getInstance().componentWillUnmount()
    expect(props.refreshConversationDetails).not.toHaveBeenCalled()
  })

  it('renders reply', () => {
    const props = {
      ...defaultProps,
      contextName: 'Course 1',
      contextCode: 'course_1',
      canSelectCourse: false,
      canEditSubject: false,
    }
    expect(
      renderer.create(
        <Compose {...props} />
      ).toJSON()
    ).toMatchSnapshot()
  })

  it('renders the forwarded message body', () => {
    let includedMessages = [template.conversationMessage({ body: 'yo' })]
    let tree = renderer.create(
      <Compose {...defaultProps} includedMessages={includedMessages} />
    ).toJSON()
    let forwardedMessage = explore(tree).selectByID('compose.forwarded-message') || {}
    expect(forwardedMessage).not.toBeNull()
    expect(forwardedMessage.children[1].children[0]).toEqual(includedMessages[0].body)
  })

  it('mapStateToProps', () => {
    const result = mapStateToProps({})
    expect(result).toEqual({})
  })
})
