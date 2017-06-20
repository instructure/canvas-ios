// @flow

import React from 'react'
import { ActionSheetIOS } from 'react-native'
import AttachmentView from '../AttachmentView'
import renderer from 'react-test-renderer'

const templates = {
  ...require('../../../__templates__/helm'),
}

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

let defaultProps = {
  navigator: templates.navigator(),
  attachment: {
    id: '1',
    display_name: 'Something.pdf',
    url: '',
    mime_class: 'pdf',
  },
}

describe('AttachmentView', () => {
  it('renders a pdf', () => {
    let tree = renderer.create(
      <AttachmentView {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders an image', () => {
    let props = {
      navigator: templates.navigator(),
      attachment: {
        id: '1',
        display_name: 'Something.png',
        url: '',
        mime_class: 'image',
      },
    }

    let tree = renderer.create(
      <AttachmentView {...props} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders unsupported stuffs', () => {
    let props = {
      navigator: templates.navigator(),
      attachment: {
        id: '1',
        display_name: 'Something.zip',
        url: '',
        mime_class: 'zip',
      },
    }

    let tree = renderer.create(
      <AttachmentView {...props} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders a video', () => {
    let props = {
      navigator: templates.navigator(),
      attachment: {
        id: '1',
        display_name: 'Something.mp4',
        url: '',
        mime_class: 'video',
      },
    }

    let tree = renderer.create(
      <AttachmentView {...props} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('opens share sheet', () => {
    const props = {
      ...defaultProps,
      navigator: templates.navigator({
        dismiss: jest.fn(),
      }),
    }
    let tree = renderer.create(
      <AttachmentView {...props} />
    )
    let instance = tree.getInstance()

    return instance.state.downloadPromise.then(r => {
      instance.share()
      expect(ActionSheetIOS.showShareActionSheetWithOptions).toHaveBeenCalledWith({
        url: 'file://caches/Something.pdf',
      }, expect.any(Function), expect.any(Function))
    })
  })

  it('closes', () => {
    const props = {
      ...defaultProps,
      navigator: templates.navigator({
        dismiss: jest.fn(),
      }),
    }
    let tree = renderer.create(
      <AttachmentView {...props} />
    )

    tree.getInstance().done()
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })
})
