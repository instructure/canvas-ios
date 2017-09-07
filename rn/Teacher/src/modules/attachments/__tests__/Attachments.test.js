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
import {
  ActionSheetIOS,
  AlertIOS,
} from 'react-native'
import renderer from 'react-test-renderer'
import { Attachments } from '../Attachments'
import explore from '../../../../test/helpers/explore'
import { Cancel } from 'axios'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../routing/Screen')
  .mock('../AttachmentPicker', () => 'AttachmentPicker')

const template = {
  ...require('../../../__templates__/attachment'),
  ...require('../../../__templates__/file'),
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
      storageOptions: {},
      uploadAttachment: jest.fn(),
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
    expect(explore(view.toJSON()).selectByID('attachments.attachment-row.0')).toBeNull()
    const add: any = explore(view.toJSON()).selectRightBarButton('attachments.add-btn')
    add.action()
    expect(explore(view.toJSON()).selectByID('attachments.attachment-row.0')).not.toBeNull()
  })

  it('removes attachments', () => {
    // $FlowFixMe
    AlertIOS.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
    props.attachments = [template.attachment()]
    const view = render(props)
    expect(explore(view.toJSON()).selectByID('attachments.attachment-row.0')).not.toBeNull()
    const remove: any = explore(view.toJSON()).selectByID('attachments.attachment-row.0.remove.btn')
    remove.props.onPress()
    expect(explore(view.toJSON()).selectByID('attachments.attachment-row.0')).toBeNull()
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

  it('renders uploading state', () => {
    const createNodeMock = ({ type }) => {
      if (type === 'AttachmentPicker') {
        return {
          show: jest.fn((options, callback) => callback(template.attachment())),
        }
      }
    }
    let resolvePromise = jest.fn()
    props.uploadAttachment = jest.fn((attachment, options) => {
      options.onProgress({ loaded: 90, total: 1024 })
      return new Promise((resolve, reject) => { resolvePromise = resolve })
    })
    props.storageOptions = {
      uploadPath: '/my files/conversation attachments',
    }
    props.attachments = []
    const view = render(props, { createNodeMock })
    const add: any = explore(view.toJSON()).selectRightBarButton('attachments.add-btn')
    add.action()
    const icon: any = explore(view.toJSON()).selectByID('attachments.attachment-row.0.icon.progress')
    const subtitle: any = explore(view.toJSON()).selectByID('attachments.attachment-row.0-subtitle-lbl')
    expect(icon).not.toBeNull()
    expect(subtitle.children[0]).toEqual('Uploading 90 B of 1 KB')
    resolvePromise(template.file())
  })

  it('renders error state', async () => {
    const createNodeMock = ({ type }) => {
      if (type === 'AttachmentPicker') {
        return {
          show: jest.fn((options, callback) => callback(template.attachment())),
        }
      }
    }
    props.uploadAttachment = jest.fn((attachment, options) => {
      return Promise.reject('Whoa, file big')
    })
    props.storageOptions = {
      uploadPath: '/my files/conversation attachments',
    }
    props.attachments = []
    const view = render(props, { createNodeMock })
    const add: any = explore(view.toJSON()).selectRightBarButton('attachments.add-btn')
    await add.action()
    const icon: any = explore(view.toJSON()).selectByID('attachments.attachment-row.0.icon.error')
    expect(icon).not.toBeNull()
  })

  it('cancels uploads on cancel', () => {
    props.navigator = template.navigator({ dismiss: jest.fn() })
    const createNodeMock = ({ type }) => {
      if (type === 'AttachmentPicker') {
        return {
          show: jest.fn((options, callback) => callback(template.attachment())),
        }
      }
    }
    props.uploadAttachment = jest.fn((attachment, options) => {
      return new Promise((resolve, reject) => {
        options.cancelUpload(() => {
          reject(new Cancel())
        })
      })
    })
    props.storageOptions = {
      uploadPath: '/my files/conversation attachments',
    }
    props.attachments = []
    const view = render(props, { createNodeMock })
    const add: any = explore(view.toJSON()).selectRightBarButton('attachments.add-btn')
    add.action()
    const cancel: any = explore(view.toJSON()).selectLeftBarButton('attachments.dismiss-btn')
    cancel.action()
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        const icon: any = explore(view.toJSON()).selectByID('attachments.attachment-row.0.icon.error')
        icon && resolve()
      }, 10)
    })
  })

  it('retries attachment', async () => {
    let retry = false
    let actions = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => { actions = callback })
    const createNodeMock = ({ type }) => {
      if (type === 'AttachmentPicker') {
        return {
          show: jest.fn((options, callback) => callback(template.attachment())),
        }
      }
    }
    props.uploadAttachment = jest.fn((attachment, options) => {
      if (!retry) return Promise.reject('Whoa, file big')
      options.onProgress({ loaded: 1024, total: 1024 })
      return Promise.resolve(template.file())
    })
    props.storageOptions = {
      uploadPath: '/my files/conversation attachments',
    }
    props.attachments = []
    const view = render(props, { createNodeMock })
    const add: any = explore(view.toJSON()).selectRightBarButton('attachments.add-btn')
    await add.action()
    retry = true
    const errorIcon: any = explore(view.toJSON()).selectByID('attachments.attachment-row.0.icon.error')
    errorIcon.props.onPress()
    await actions(0)
    const successIcon: any = explore(view.toJSON()).selectByID('attachments.attachment-row.0.icon.complete')
    expect(successIcon).not.toBeNull()
  })

  function render (props, options = {}) {
    return renderer.create(<Attachments {...props} />, options)
  }
})
