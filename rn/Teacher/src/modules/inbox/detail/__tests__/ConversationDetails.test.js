/* @flow */
import {
  ActionSheetIOS,
} from 'react-native'
import React from 'react'
import { ConversationDetails, mapStateToProps, handleRefresh, shouldRefresh, type ConversationDetailsProps } from '../ConversationDetails.js'
import { setSession } from '../../../../api/session'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'

const template = {
  ...require('../../../../api/canvas-api/__templates__/conversations'),
  ...require('../../../../api/canvas-api/__templates__/users'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../redux/__templates__/app-state'),
  ...require('../../../../api/canvas-api/__templates__/session'),
}

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../../routing/Screen')

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

const Screen = (props: ConversationDetailsProps) => {
  const screen = renderer.create(<ConversationDetails {...props} />)
  const tree = () => screen.toJSON()
  return {
    component: screen,
    get optionsButton (): any {
      return explore(tree()).selectRightBarButton('inbox.detail.options.button')
    },

    tapOptionsButton () {
      this.optionsButton.action()
      return this
    },

    testRender () {
      expect(tree()).toMatchSnapshot()
    },
  }
}

describe('ConversationDetails', () => {
  let props
  beforeEach(() => {
    props = {
      conversation: template.conversation({ id: '1' }),
      conversationID: '1',
      messages: [],
      refreshConversationDetails: jest.fn(),
      starConversation: jest.fn(),
      unstarConversation: jest.fn(),
      deleteConversation: jest.fn(),
      navigator: template.navigator(),
    }
  })

  beforeAll(() => {
    setSession(template.session())
  })

  it('renders correctly', () => {
    Screen(props).testRender()
  })

  it('renders correctly with some messages', () => {
    // $FlowFixMe
    props.messages = [template.conversationMessage()]
    Screen(props).testRender()
  })

  it('shows options action sheet', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn()
    Screen(props).tapOptionsButton()
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalledWith(
      {
        options: ['Delete', 'Cancel'],
        destructiveButtonIndex: 0,
        cancelButtonIndex: 1,
      },
      expect.any(Function),
    )
  })

  it('calls deleteConversation from options', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(config.options.length - 2))
    props.deleteConversation = jest.fn()
    props.conversationID = '1'
    Screen(props).tapOptionsButton()
    expect(props.deleteConversation).toHaveBeenCalledWith('1')
  })

  it('calls pop after delete finishes', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(config.options.length - 2))
    props.navigator.pop = jest.fn()
    const screen = Screen(props)
    props.deleteConversation = jest.fn(() => {
      setProps(screen.component, { pending: 1 })
      setProps(screen.component, { pending: 0, conversation: null })
    })
    screen.component.update(<ConversationDetails {...props} />)
    screen.tapOptionsButton()
    expect(props.navigator.pop).toHaveBeenCalled()
  })
})

it('mapStateToProps', () => {
  const c1 = template.conversation({
    id: '1',
  })
  const appState = template.appState({
    inbox: {
      conversations: {
        '1': { data: c1 },
      },
      selectedScope: 'all',
      all: { refs: [c1.id] },
      unread: { refs: [] },
      starred: { refs: [] },
    },
  })

  const results = mapStateToProps(appState, { conversationID: c1.id })
  expect(results).toMatchObject({
    conversation: c1,
  })
})

it('handleRefresh', () => {
  const props = {
    refreshConversationDetails: jest.fn(),
    starConversation: jest.fn(),
    unstarConversation: jest.fn(),
    conversationID: '1',
    conversation: null,
    messages: [],
    navigator: template.navigator(),
  }

  handleRefresh(props)
  expect(props.refreshConversationDetails).toHaveBeenCalledWith('1')
})

it('should refresh', () => {
  const conversation = template.conversation({ messages: null })
  const props = {
    conversation,
    conversationID: conversation.id,
    messages: [],
  }

  expect(shouldRefresh(props)).toEqual(true)
})
