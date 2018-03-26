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
import { ActionSheetIOS } from 'react-native'
import AttachmentView from '../AttachmentView'
import md5 from 'md5'
import { shallow } from 'enzyme'

import * as templates from '../../../__templates__'

jest.mock('ActionSheetIOS', () => ({
  showShareActionSheetWithOptions: jest.fn(),
}))

jest.mock('react-native-fs', () => ({
  CachesDirectoryPath: 'caches',
  downloadFile: jest.fn(() => ({
    jobId: '1',
    promise: Promise.resolve({ statusCode: 200 }),
  })),
}))

jest.mock('WebView', () => 'WebView')

let defaultProps = {
  navigator: templates.navigator(),
  attachment: {
    id: '1',
    display_name: 'Something.pdf',
    url: 'http://www.fillmurray.com/100/100',
    mime_class: 'pdf',
  },
}

describe('AttachmentView', () => {
  it('renders a pdf', async () => {
    let tree = shallow(
      <AttachmentView {...defaultProps} />
    )
    await tree.instance().fetchFile()
    tree.update()
    expect(tree.find('CanvasWebView').length).toEqual(1)
  })

  it('renders an image', async () => {
    let props = {
      navigator: templates.navigator(),
      attachment: {
        id: '1',
        display_name: 'Something.png',
        url: 'http://www.fillmurray.com/100/100',
        mime_class: 'image',
      },
    }

    let tree = shallow(
      <AttachmentView {...props} />
    )
    await tree.instance().fetchFile()
    tree.update()
    expect(tree.find('Image').length).toEqual(1)
  })

  it('renders unsupported stuffs', async () => {
    let props = {
      navigator: templates.navigator(),
      attachment: {
        id: '1',
        display_name: 'Something.zip',
        url: '',
        mime_class: 'zip',
      },
    }

    let tree = shallow(
      <AttachmentView {...props} />
    )
    await tree.instance().fetchFile()
    tree.update()
    expect(tree.find('Text').props().children.includes('not supported')).toEqual(true)
  })

  it('renders a video', async () => {
    let props = {
      navigator: templates.navigator(),
      attachment: {
        id: '1',
        display_name: 'Something.mp4',
        url: '',
        mime_class: 'video',
      },
    }

    let tree = shallow(
      <AttachmentView {...props} />
    )
    await tree.instance().fetchFile()
    tree.update()
    expect(tree.find('Video').length).toEqual(1)
  })

  it('renders audio', async () => {
    let props = {
      navigator: templates.navigator(),
      attachment: {
        id: '1',
        display_name: 'Something.mp3',
        url: '',
        mime_class: 'audio',
      },
    }

    let tree = shallow(
      <AttachmentView {...props} />
    )
    await tree.instance().fetchFile()
    tree.update()
    expect(tree.find('Video').length).toEqual(1)
  })

  it('renders audio with unknown mime class', async () => {
    let props = {
      navigator: templates.navigator(),
      attachment: {
        id: '1',
        display_name: 'Something.mp3',
        url: '',
        mime_class: 'apple-audio',
        'content-type': 'audio/mp3',
      },
    }

    let tree = shallow(
      <AttachmentView {...props} />
    )
    await tree.instance().fetchFile()
    tree.update()
    expect(tree.find('Video').length).toEqual(1)
  })

  it('renders the Video tag with the current width and 16:9 height', async () => {
    let props = {
      navigator: templates.navigator(),
      attachment: {
        id: '1',
        display_name: 'Something.mp4',
        url: '',
        mime_class: 'video',
      },
    }

    let tree = shallow(
      <AttachmentView {...props} />
    )
    await tree.instance().fetchFile()
    tree.setState({ size: { width: 16 } })
    tree.update()

    expect(tree.find('Video').props().style).toEqual({
      width: 16,
      height: 9,
    })
  })

  it('opens share sheet', async () => {
    const props = {
      ...defaultProps,
      navigator: templates.navigator({
        dismiss: jest.fn(),
      }),
    }
    let tree = shallow(
      <AttachmentView {...props} />
    )
    await tree.instance().fetchFile()
    tree.update()

    let screen = tree.find('Screen')
    screen.props().rightBarButtons[0].action()

    expect(ActionSheetIOS.showShareActionSheetWithOptions).toHaveBeenCalledWith(
      {
        url: `file://caches/${md5(props.attachment.url)}.pdf`,
      },
      expect.any(Function),
      expect.any(Function)
    )
  })
})
