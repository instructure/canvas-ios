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

/* @flow */
import 'react-native'
import React from 'react'
import Masquerade from '../Masquerade.js'
import { setSession } from '../../../canvas-api'
import explore from '../../../../test/helpers/explore'

const template = {
  ...require('../../../__templates__/session'),
  ...require('../../../__templates__/helm'),
}

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../routing/Screen')

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

describe('Masquerade Tests', () => {
  let props = {}
  beforeEach(() => {
    jest.resetAllMocks()

    props = {
      // conversation: template.conversation({ id: '1' }),
      // conversationID: '1',
      // messages: [],
      // refreshConversationDetails: jest.fn(),
      // refreshEnrollments: jest.fn(),
      // starConversation: jest.fn(),
      // unstarConversation: jest.fn(),
      // deleteConversation: jest.fn(),
      // deleteConversationMessage: jest.fn(),
      // markAsRead: jest.fn(),
      navigator: template.navigator({
        dismiss: jest.fn(() => {
          return Promise.resolve()
        }),
      }),
      // enrollments: [template.enrollment()],
    }
  })

  beforeAll(() => {
    setSession(template.session())
  })

  it('renders correctly', () => {
    const tree = renderer.create(
      <Masquerade />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders correctly with session', () => {
    const tree = renderer.create(
      <Masquerade />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('will dismiss', async () => {
    const spy = jest.fn()
    props.navigator.dismiss = spy
    const dismissButton: any = explore(renderer.create(
      <Masquerade {...props} />
    ).toJSON()).selectLeftBarButton('masquerage-dismiss-btn')
    dismissButton.action()
    expect(spy).toHaveBeenCalled()
  })
})
