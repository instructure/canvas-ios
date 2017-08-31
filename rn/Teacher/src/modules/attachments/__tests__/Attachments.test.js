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

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import Attachments from '../Attachments'
import explore from '../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../routing/Screen')
  .mock('../AttachmentRow', () => 'AttachmentRow')
  .mock('../AttachmentPicker', () => 'AttachmentPicker')

const template = {
  ...require('../../../__templates__/attachment'),
  ...require('../../../__templates__/helm'),
}

describe('Attachments', () => {
  let props
  beforeEach(() => {
    props = {
      attachments: [template.attachment()],
      navigator: template.navigator(),
      onComplete: jest.fn(),
      maxAllowed: undefined,
    }
  })

  it('renders empty state', () => {
    props.attachments = []
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('renders attachments', () => {
    props.attachments = [
      template.attachment({ id: '1' }),
      template.attachment({ id: '2' }),
    ]
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('shows + button if more attachments allowed', () => {
    props.maxAllowed = 1
    props.attachments = []
    expect(explore(render(props).toJSON()).selectRightBarButton('attachments.add-btn')).toBeDefined()
  })

  it('hides + button if no more attachments allowed', () => {
    props.maxAllowed = 1
    props.attachments = [template.attachment()]
    expect(explore(render(props).toJSON()).selectRightBarButton('attachments.add-btn')).not.toBeDefined()
  })

  it('adds attachments from picker', () => {
    const createNodeMock = ({ type }) => {
      if (type === 'AttachmentPicker') {
        return {
          show: jest.fn((options, callback) => callback(template.attachment())),
        }
      }
    }
    props.attachments = []
    const view = render(props, { createNodeMock })
    expect(explore(view.toJSON()).query(({ type }) => type === 'AttachmentRow')).toHaveLength(0)
    const add: any = explore(view.toJSON()).selectRightBarButton('attachments.add-btn')
    add.action()
    expect(explore(view.toJSON()).query(({ type }) => type === 'AttachmentRow')).toHaveLength(1)
  })

  it('removes attachments', () => {
    props.attachments = [template.attachment()]
    const view = render(props)
    expect(explore(view.toJSON()).query(({ type }) => type === 'AttachmentRow')).toHaveLength(1)
    const row: any = explore(view.toJSON()).selectByID('attachments.attachment-row.0')
    row.props.onRemovePressed()
    expect(explore(view.toJSON()).query(({ type }) => type === 'AttachmentRow')).toHaveLength(0)
  })

  it('shows attachment', () => {
    props.navigator.show = jest.fn()
    const attachment = template.attachment()
    props.attachments = [attachment]
    const view = render(props)
    const row: any = explore(view.toJSON()).selectByID('attachments.attachment-row.0')
    row.props.onPress()
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/attachment',
      { modal: true },
      { attachment },
    )
  })

  it('dismisses on done', () => {
    props.navigator.dismiss = jest.fn()
    const done: any = explore(render(props).toJSON()).selectLeftBarButton('attachments.dismiss-btn')
    done.action()
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('passes attachments back on dismiss', () => {
    props.onComplete = jest.fn()
    props.attachments = [template.attachment()]
    const done: any = explore(render(props).toJSON()).selectLeftBarButton('attachments.dismiss-btn')
    done.action()
    expect(props.onComplete).toHaveBeenCalledWith(props.attachments)
  })

  function render (props, options = {}) {
    return renderer.create(<Attachments {...props} />, options)
  }
})
