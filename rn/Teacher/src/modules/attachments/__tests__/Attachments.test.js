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

import { shallow } from 'enzyme'
import React from 'react'
import {
  AlertIOS,
  FlatList,
} from 'react-native'
import Attachments from '../Attachments'
import * as template from '../../../__templates__'

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
    expect(shallow(<Attachments {...props} />)).toMatchSnapshot()
  })

  it('renders attachments', () => {
    props.attachments = [
      template.attachment({ id: '1' }),
      template.attachment({ id: '2' }),
    ]
    expect(shallow(<Attachments {...props} />)).toMatchSnapshot()
  })

  it('shows + button if more attachments allowed', () => {
    props.maxAllowed = 1
    props.attachments = []
    const tree = shallow(<Attachments {...props} />)
    const button = tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'attachments.add-btn')
    expect(button).toBeDefined()
  })

  it('hides + button if no more attachments allowed', () => {
    props.maxAllowed = 1
    props.attachments = [template.attachment()]
    const tree = shallow(<Attachments {...props} />)
    const button = tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'attachments.add-btn')
    expect(button).not.toBeDefined()
  })

  it('adds attachments from picker', async () => {
    props.attachments = []
    const tree = shallow(<Attachments {...props} />)
    tree.instance().captureAttachmentPicker({
      show: jest.fn((options, callback) => callback(template.attachment())),
    })
    expect(tree.find(FlatList).prop('data')).toHaveLength(0)
    const button = tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'attachments.add-btn')
    button.action()
    await new Promise(resolve => tree.setState({}, resolve))
    expect(tree.find(FlatList).prop('data')).toHaveLength(1)
  })

  it('removes attachments', async () => {
    AlertIOS.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
    props.attachments = [template.attachment()]
    const tree = shallow(<Attachments {...props} />)
    expect(tree.find(FlatList).prop('data')).toHaveLength(1)
    tree.find(FlatList).dive()
      .find('[testID="attachments.attachment-row.0"]')
      .simulate('RemovePressed')
    await new Promise(resolve => tree.setState({}, resolve))
    expect(tree.find(FlatList).prop('data')).toHaveLength(0)
  })

  it('shows attachment', () => {
    props.navigator.show = jest.fn()
    const attachment = template.attachment()
    props.attachments = [attachment]
    const tree = shallow(<Attachments {...props} />)
    tree.find(FlatList).dive()
      .find('[testID="attachments.attachment-row.0"]')
      .simulate('Press')
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/attachment',
      { modal: true },
      { attachment },
    )
  })

  it('dismisses on done', () => {
    props.navigator.dismiss = jest.fn()
    const tree = shallow(<Attachments {...props} />)
    const button = tree.find('Screen').prop('leftBarButtons')
      .find(({ testID }) => testID === 'attachments.dismiss-btn')
    button.action()
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('passes attachments back on dismiss', () => {
    props.onComplete = jest.fn()
    props.attachments = [template.attachment()]
    const tree = shallow(<Attachments {...props} />)
    const button = tree.find('Screen').prop('leftBarButtons')
      .find(({ testID }) => testID === 'attachments.dismiss-btn')
    button.action()
    expect(props.onComplete).toHaveBeenCalledWith(props.attachments)
  })

  it('does not pass attachments with errors back on dismiss', async () => {
    const spy = jest.fn()
    props.onComplete = spy
    props.attachments = []
    const tree = shallow(<Attachments {...props} />)
    await new Promise(resolve => tree.setState({
      attachments: {
        died: { error: new Error() },
      },
    }, resolve))
    tree.find('Screen').prop('leftBarButtons')
      .find(({ testID }) => testID === 'attachments.dismiss-btn')
      .action()
    await new Promise(resolve => tree.setState({}, resolve))
    expect(spy).toHaveBeenCalledWith([])
  })

  it('renders uploading state', async () => {
    let resolvePromise = jest.fn()
    props.uploadAttachment = jest.fn((attachment, options) => {
      options.onProgress({ loaded: 400, total: 1024 })
      return new Promise((resolve, reject) => { resolvePromise = resolve })
    })
    props.storageOptions = {
      uploadPath: '/my files/conversation attachments',
    }
    props.attachments = []
    const tree = shallow(<Attachments {...props} />)
    tree.instance().captureAttachmentPicker({
      show: jest.fn((options, callback) => callback(template.attachment())),
    })
    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'attachments.add-btn')
      .action()
    await new Promise(resolve => tree.setState({}, resolve))
    const row = tree.find(FlatList).dive().find('[testID="attachments.attachment-row.0"]')
    expect(row.prop('progress')).toEqual({ loaded: 400, total: 1024 })
    resolvePromise(template.file())
  })

  it('renders media uploading state', async () => {
    let resolvePromise = jest.fn()
    props.uploadMedia = jest.fn((attachment, mimeClass, options) => {
      options.onProgress({ loaded: 400, total: 1024 })
      return new Promise((resolve, reject) => { resolvePromise = resolve })
    })
    props.storageOptions = {
      uploadPath: '/my files/conversation attachments',
      mediaServer: true,
    }
    props.attachments = []
    const tree = shallow(<Attachments {...props} />)
    tree.instance().captureAttachmentPicker({
      show: jest.fn((options, callback) => callback(template.attachment({ mime_class: 'video' }))),
    })
    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'attachments.add-btn')
      .action()
    await new Promise(resolve => tree.setState({}, resolve))
    const row = tree.find(FlatList).dive().find('[testID="attachments.attachment-row.0"]')
    expect(row.prop('progress')).toEqual({ loaded: 400, total: 1024 })
    resolvePromise(template.file())
  })

  it('renders error state', async () => {
    const rejection = Promise.reject(new Error('Whoa, file big'))
    props.uploadAttachment = jest.fn(() => rejection)
    props.storageOptions = {
      uploadPath: '/my files/conversation attachments',
    }
    props.attachments = []
    const tree = shallow(<Attachments {...props} />)
    tree.instance().captureAttachmentPicker({
      show: jest.fn((options, callback) => callback(template.attachment())),
    })
    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'attachments.add-btn')
      .action()
    await rejection.catch(() => {})
    await new Promise(resolve => tree.setState({}, resolve))
    await tree.update()
    const row = tree.find(FlatList).dive().find('[testID="attachments.attachment-row.0"]')
    expect(row.prop('error')).not.toBeNull()
  })

  it('cancels uploads on cancel', async () => {
    props.navigator = template.navigator({ dismiss: jest.fn() })
    props.uploadAttachment = jest.fn((attachment, options) => {
      return new Promise((resolve, reject) => {
        options.cancelUpload(() => {
          reject(new TypeError('Network request aborted'))
        })
      })
    })
    props.storageOptions = {
      uploadPath: '/my files/conversation attachments',
    }
    props.attachments = []
    const tree = shallow(<Attachments {...props} />)
    tree.instance().captureAttachmentPicker({
      show: jest.fn((options, callback) => callback(template.attachment())),
    })
    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'attachments.add-btn')
      .action()
    await new Promise(resolve => tree.setState({}, resolve))
    tree.find('Screen').prop('leftBarButtons')
      .find(({ testID }) => testID === 'attachments.dismiss-btn')
      .action()
    await new Promise(resolve => tree.setState({}, resolve))
    const row = tree.find(FlatList).dive().find('[testID="attachments.attachment-row.0"]')
    expect(row.prop('error')).toBeNull()
  })
})
