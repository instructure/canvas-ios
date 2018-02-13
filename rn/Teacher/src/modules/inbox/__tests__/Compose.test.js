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
import { shallow } from 'enzyme'
import { Compose, mapStateToProps } from '../Compose'
import api from '../../../canvas-api'
import { apiResponse } from '../../../canvas-api/utils/testHelpers'

let template = {
  ...require('../../../__templates__/helm'),
  ...require('../../../__templates__/addressBook'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/conversations'),
  ...require('../../../__templates__/attachment'),
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
  .mock('../../../canvas-api')
  .mock('../../../routing/Screen')

describe('Compose', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders', () => {
    let tree = shallow(<Compose {...defaultProps} />)
    expect(tree).toMatchSnapshot()
  })

  it('allows for a navbar title to be passed in as a prop', () => {
    let tree = shallow(<Compose {...defaultProps} navBarTitle='title' />)
    expect(tree.find('Screen').prop('title')).toEqual('title')
  })

  it('doesnt show the course select when told not to', () => {
    let tree = shallow(<Compose {...defaultProps} showCourseSelect={false} />)
    expect(tree.find('[testID="compose.course-select"]').exists()).toBe(false)
  })

  it('renders with passed in recipients', () => {
    const u1 = template.addressBookResult({ id: '1' })
    const u2 = template.addressBookResult({ id: '2' })
    let tree = shallow(<Compose {...defaultProps} recipients={[u1, u2]} />)
    expect(tree).toMatchSnapshot()
  })

  it('doesnt show the To placeholder when there are recipients', () => {
    const recipient = template.addressBookResult({ id: '1' })
    let tree = shallow(<Compose {...defaultProps} recipients={[recipient]} />)
    expect(tree.find('[testID="compose.recipients-placeholder"]').exists()).toBe(false)
  })

  it('renders after picking a course', () => {
    let course = template.course()
    let onSelect = jest.fn()
    const show = jest.fn((path, options, passthrough) => {
      onSelect = passthrough.onSelect
    })

    const navigator = template.navigator({ show, dismiss: jest.fn() })
    let tree = shallow(<Compose {...defaultProps} navigator={navigator} />)

    tree.find('[testID="compose.course-select"]').simulate('Press')
    onSelect(course)
    expect(navigator.pop).toHaveBeenCalled()
    expect(tree).toMatchSnapshot()
  })

  it('sets all the data and then send the message', () => {
    let course = template.course()
    const recipient = template.addressBookResult()
    let component = shallow(<Compose {...defaultProps} />)
    const instance = component.instance()
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
    let component = shallow(<Compose {...defaultProps} navigator={navigator} />)

    component.instance().selectCourse()
    onSelect(template.course())
    component.instance()._openAddressBook()
    onSelect([recipient])
    expect(navigator.dismiss).toHaveBeenCalled()
    expect(component.instance().state.recipients).toEqual([recipient])
    onCancel()
    expect(navigator.dismiss).toHaveBeenCalled()
  })

  it('dismisses the modal when cancel is pressed', () => {
    let tree = shallow(<Compose {...defaultProps} />)
    tree.find('Screen').prop('leftBarButtons')[0].action()
    expect(defaultProps.navigator.dismiss).toHaveBeenCalled()
  })

  it('toggles the send to all', () => {
    let tree = shallow(<Compose {...defaultProps} />)
    tree.find('[identifier="compose-message.send-all-toggle"]').simulate('ValueChange', true)
    expect(tree.state('sendToAll')).toBeTruthy()
  })

  it('hides send to all for replies', () => {
    let tree = shallow(<Compose {...defaultProps} conversationID='2' />)
    expect(tree.find('[identifier="compose-message.send-all-toggle"]').exists()).toBe(false)
  })

  it('deletes a recipient from state', () => {
    let tree = shallow(<Compose {...defaultProps} />)
    tree.setState({
      recipients: [
        {
          id: '1',
          name: 'Donald Trump',
        },
      ],
    })
    tree.instance()._deleteRecipient('1')
    expect(tree.state('recipients').length).toBe(0)
  })

  it('creates conversation on send', () => {
    const u1 = template.addressBookResult({ id: '1' })
    const props = {
      ...defaultProps,
      contextCode: 'course_1',
      recipients: [u1],
      subject: 'new conversation subject',
      onlySendIndividualMessages: false,
    }

    let response = apiResponse(template.conversation())
    api.createConversation.mockReturnValueOnce(response())

    const tree = shallow(<Compose {...props} />)
    tree.find('[testID="compose-message.body-text-input"]').simulate('ChangeText', 'new conversation')
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(api.createConversation).toHaveBeenCalledWith({
      recipients: ['1'],
      body: 'new conversation',
      subject: 'new conversation subject',
      group_conversation: true,
      attachment_ids: [],
      context_code: 'course_1',
    })
  })

  it('adds message on send', () => {
    const u1 = template.addressBookResult({ id: '1' })
    const props = {
      ...defaultProps,
      recipients: [u1],
      subject: 'new conversation subject',
      onlySendIndividualMessages: true,
      conversationID: '1',
      includedMessages: [template.conversationMessage({ id: '1' }), template.conversationMessage({ id: '2' })],
      contextCode: 'course_1',
    }

    let response = apiResponse(template.conversation(props.includedMessages[0]))
    api.addMessage.mockReturnValueOnce(response())

    const tree = shallow(<Compose {...props} />)
    tree.find('[testID="compose-message.body-text-input"]').simulate('ChangeText', 'new conversation')
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(api.addMessage).toHaveBeenCalledWith('1', {
      recipients: ['1'],
      body: 'new conversation',
      subject: 'new conversation subject',
      group_conversation: true,
      bulk_message: 1,
      included_messages: ['1', '2'],
      attachment_ids: [],
      context_code: 'course_1',
    })
  })

  it('adds message with attachments on send', () => {
    const u1 = template.addressBookResult({ id: '1' })
    const props = {
      ...defaultProps,
      recipients: [u1],
      subject: 'new conversation subject',
      onlySendIndividualMessages: false,
      contextCode: 'course_1',
      navigator: template.navigator({
        show: jest.fn((route, options, props) => {
          props.onComplete([template.attachment({ id: '234' })])
        }),
      }),
    }

    let response = apiResponse(template.conversation())
    api.createConversation.mockReturnValueOnce(response())

    const tree = shallow(<Compose {...props} />)
    tree.find('Screen').prop('rightBarButtons')[1].action()
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(api.createConversation).toHaveBeenCalledWith({
      recipients: ['1'],
      body: '',
      subject: 'new conversation subject',
      group_conversation: true,
      attachment_ids: ['234'],
      context_code: 'course_1',
    })
  })

  it('refreshes conversation on unmount if adding reply', () => {
    const props = {
      ...defaultProps,
      refreshConversationDetails: jest.fn(),
      conversationID: '1',
    }
    const tree = shallow(<Compose {...props} />)
    tree.unmount()
    expect(props.refreshConversationDetails).toHaveBeenCalledWith('1')
  })

  it('does not refresh conversation on unmount', () => {
    const props = {
      ...defaultProps,
      refreshConversationDetails: jest.fn(),
    }
    const tree = shallow(<Compose {...props} />)
    tree.unmount()
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
    expect(shallow(<Compose {...props} />)).toMatchSnapshot()
  })

  it('renders the forwarded message body', () => {
    let includedMessages = [template.conversationMessage({ body: 'yo' })]
    let tree = shallow(<Compose {...defaultProps} includedMessages={includedMessages} />)
    let forwardedMessage = tree.find('[testID="compose.forwarded-message"]')
    expect(forwardedMessage.exists()).toBe(true)
    expect(forwardedMessage.find('Text').last().children().text()).toEqual(includedMessages[0].body)
  })

  it('mapStateToProps', () => {
    const result = mapStateToProps({})
    expect(result).toEqual({})
  })
})
