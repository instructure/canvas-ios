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

// @flow

import React from 'react'
import { ActionSheetIOS } from 'react-native'
import AttachmentView from '../AttachmentView'
import md5 from 'md5'
import { shallow } from 'enzyme'

import * as templates from '../../../__templates__'

jest.mock('react-native/Libraries/ActionSheetIOS/ActionSheetIOS', () => ({
  showShareActionSheetWithOptions: jest.fn(),
}))

jest.mock('react-native-fs', () => ({
  TemporaryDirectoryPath: 'tmp',
  downloadFile: jest.fn(() => ({
    jobId: '1',
    promise: Promise.resolve({ statusCode: 200 }),
  })),
}))

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
        url: `file://tmp/${md5(props.attachment.url)}.pdf`,
      },
      expect.any(Function),
      expect.any(Function)
    )
  })

  it('shows an error if attachment is locked', () => {
    let props = {
      ...defaultProps,
      attachment: {
        ...defaultProps.attachment,
        locked_for_user: true,
        lock_explanation: 'locked yo',
      },
    }
    let tree = shallow(<AttachmentView {...props} />)
    expect(tree.find('[children="locked yo"]').exists()).toBe(true)
  })
})
