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
import React from 'react'
import { shallow } from 'enzyme'
import { ActionSheetIOS, Clipboard, NativeModules, AccessibilityInfo } from 'react-native'
import {
  exists,
  downloadFile,
  stopDownload,
} from 'react-native-fs'

import ViewFile from '../ViewFile'

import * as templates from '../../../__templates__/index'

jest
  .mock('react-native/Libraries/ActionSheetIOS/ActionSheetIOS', () => ({
    showShareActionSheetWithOptions: jest.fn(),
  }))
  .mock('react-native/Libraries/Components/Clipboard/Clipboard', () => ({
    setString: jest.fn(),
  }))

jest.mock('react-native-fs', () => ({
  TemporaryDirectoryPath: 'tmp',
  downloadFile: jest.fn(() => ({
    jobId: '1',
    promise: Promise.resolve({ statusCode: 200 }),
  })),
  stopDownload: jest.fn(),
  exists: jest.fn(() => Promise.resolve(false)),
  mkdir: jest.fn(() => Promise.resolve()),
}))

const selectors = {
  share: '[testID="FileDetails.shareButton"]',
  copy: '[testID="FileDetails.copyButton"]',
}

const updatedState = (tree: ShallowWrapper) => new Promise(resolve => tree.setState({}, resolve))

describe('ViewFile', () => {
  let props
  beforeEach(() => {
    props = {
      contextID: '1',
      context: 'courses',
      fileID: '24',
      file: templates.file({
        id: '24',
        filename: 'picture%3C%3E%28%29%5B%5D%7B%7D.%3F%25%E6%97%A5%E6%9C%AC%23.jpg',
      }),
      navigator: {
        show: jest.fn(),
        pop: jest.fn(),
        dismiss: jest.fn(),
      },
      getCourse: jest.fn(() => Promise.resolve({
        data: templates.course({ name: 'New Course' }),
      })),
    }
  })

  it('renders loading while fetching the file', () => {
    const tree = shallow(<ViewFile {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders course name as subtitle once loaded', async () => {
    const tree = shallow(<ViewFile {...props} />)
    expect(props.getCourse).toHaveBeenCalledWith('1')
    await Promise.resolve() // wait for course download.
    await updatedState(tree)
    expect(tree.find('Screen').prop('subtitle')).toBe('New Course')
  })

  it('ignores loading course if no courseID', async () => {
    props.contextID = null
    const tree = shallow(<ViewFile {...props} />)
    expect(props.getCourse).not.toHaveBeenCalled()
    expect(tree.find('Screen').prop('subtitle')).toBeUndefined()
  })

  it('ignores subtitle if course loading fails', async () => {
    props.getCourse = jest.fn(() => Promise.reject())
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for course failure.
    expect(tree.find('Screen').prop('subtitle')).toBeUndefined()
  })

  it('ignores fetching the file for zip', async () => {
    props.file.mime_class = 'zip'
    const tree = shallow(<ViewFile {...props} />)
    await updatedState(tree)
    expect(tree.find('Text').children().text()).toBe('Previewing this file type is not supported')
  })

  it('renders audio and video', async () => {
    props.file.mime_class = 'audio'
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for mkdir.
    await Promise.resolve() // wait for file download.
    await updatedState(tree)
    tree.update()
    expect(tree.find('Video').exists()).toBe(true)
    tree.find('[onLayout]').simulate('Layout', { nativeEvent: { layout: { width: 480, height: 320 } } })
    tree.find('[onLayout]').simulate('Layout', { nativeEvent: { layout: { width: 480, height: 320 } } }) // duplicate doesn't throw
    await updatedState(tree)
    expect(tree.find('Video').prop('style')).toEqual({
      width: 480,
      height: 270,
    })
  })

  it('renders image', async () => {
    props.file.mime_class = 'image'
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for mkdir.
    await Promise.resolve() // wait for file download.
    await updatedState(tree)
    tree.update()
    expect(tree.find('[testID="view-file.image"]').length).toBe(1)
  })

  it('renders heic', async () => {
    props.file.mime_class = 'file'
    props.file['content-type'] = 'image/heic'
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for mkdir.
    await Promise.resolve() // wait for file download.
    await updatedState(tree)
    tree.update()
    expect(tree.find('[testID="view-file.image"]').length).toBe(1)
  })

  it('tries to fetch image again after failing', async () => {
    props.file.mime_class = 'image'
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for mkdir
    await Promise.resolve() // wait for file download first try
    await updatedState(tree)
    tree.update()
    tree.find('Image').at(0).simulate('Error')
    await updatedState(tree)
    tree.update()
    expect(tree.find('ActivityIndicator').length).toBe(1)
  })

  it('renders html', async () => {
    props.file.mime_class = 'html'
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve()
    await Promise.resolve()
    await updatedState(tree)
    tree.update()
    expect(tree.find('CanvasWebView').props().source.uri).toEqual('http://mobiledev.instructure.com//courses/1/files/24/preview')
  })

  it('renders the button for AR preview', async () => {
    props.file.filename = 'test.usdz'
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve()
    await Promise.resolve()
    await updatedState(tree)
    tree.update()
    expect(tree.find('Button').props().children).toEqual('Augment Reality')
  })

  it('calls QLPreviewManager.previewFile when the AR button is tapped', async () => {
    props.file.filename = 'test.usdz'
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve()
    await Promise.resolve()
    await updatedState(tree)
    tree.update()
    let button = tree.find('Button')
    button.simulate('press')
    expect(NativeModules.QLPreviewManager.previewFile).toHaveBeenCalled()
  })

  it('renders an error message if loading fails', async () => {
    let promise = Promise.resolve({ statusCode: 500 })
    downloadFile.mockImplementationOnce(() => ({
      jobId: '2',
      promise: promise,
    }))
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve()
    await promise // wait for downloadFile to complete.
    await updatedState(tree)
    tree.update()
    expect(tree.find('Text').children().text()).toBe('There was an error loading the file.')
  })

  it('handles sharing the file', async () => {
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for mkdir
    await Promise.resolve() // wait for downloadFile to complete.
    await updatedState(tree)
    tree.find(selectors.share).simulate('Press')
    expect(ActionSheetIOS.showShareActionSheetWithOptions).toHaveBeenCalledWith(
      { url: 'file://tmp/file-24/picture<>()[]{}._%日本_.jpg' },
      expect.any(Function),
      expect.any(Function)
    )
  })

  it('ignores share if not loaded yet', () => {
    const tree = shallow(<ViewFile {...props} />)
    ActionSheetIOS.showShareActionSheetWithOptions.mockReset()
    tree.find(selectors.share).simulate('Press')
    expect(ActionSheetIOS.showShareActionSheetWithOptions).not.toHaveBeenCalled()
  })

  it('does not throw when sharing errors or completes', async () => {
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for mkdir to complete.
    await Promise.resolve() // wait for downloadFile to complete.
    await updatedState(tree)
    tree.find(selectors.share).simulate('Press')
    expect(() => {
      ActionSheetIOS.showShareActionSheetWithOptions.mock.calls[0][1]()
      ActionSheetIOS.showShareActionSheetWithOptions.mock.calls[0][2]()
    }).not.toThrow()
  })

  it('can copy the file url without any query params to the clipboard', async () => {
    let originalURL = props.file.url
    props.file.url = originalURL + '?verifier=somegobblygook'
    const tree = shallow(<ViewFile {...props} />)
    await tree.instance().fetchFile(props.file)
    tree.update()
    tree.find(selectors.copy).simulate('press')
    expect(Clipboard.setString).toHaveBeenCalledWith(originalURL)
    expect(AccessibilityInfo.announceForAccessibility).toHaveBeenCalled()
  })

  it('shows the copied modal when the copy url button is pressed', async () => {
    const tree = shallow(<ViewFile {...props} />)
    await tree.instance().fetchFile(props.file)
    tree.update()
    tree.find(selectors.copy).simulate('press')
    tree.update()
    expect(tree.find('ModalOverlay').props().visible).toEqual
  })

  it('updates the title if the edit screen changes it', async () => {
    const tree = shallow(<ViewFile {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.navigator.show).toHaveBeenLastCalledWith(
      '/courses/1/files/24/edit',
      { modal: true },
      {
        courseID: '1',
        file: props.file,
        onChange: expect.any(Function),
        onDelete: expect.any(Function),
      },
    )
    props.navigator.show.mock.calls[0][2].onChange({
      ...props.file,
      name: 'changed name',
    })
    await updatedState(tree)
    expect(tree.find('Screen').prop('title')).toBe('changed name')
  })

  it('closes and calls onChange when deleted when pushed on a navigation stack', async () => {
    const onChange = jest.fn()
    const tree = shallow(<ViewFile {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    await props.navigator.show.mock.calls[0][2].onDelete(props.file)
    expect(onChange).not.toHaveBeenCalled()
    tree.setProps({ onChange })
    await props.navigator.show.mock.calls[0][2].onDelete(props.file)
    expect(props.navigator.pop).toHaveBeenCalled()
    expect(onChange).toHaveBeenCalled()
  })

  it('closes and calls onChange when deleted when in a modal', async () => {
    const onChange = jest.fn()
    const tree = shallow(<ViewFile {...props} isModal />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    await props.navigator.show.mock.calls[0][2].onDelete(props.file)
    expect(onChange).not.toHaveBeenCalled()
    tree.setProps({ onChange })
    await props.navigator.show.mock.calls[0][2].onDelete(props.file)
    expect(props.navigator.dismiss).toHaveBeenCalled()
    expect(onChange).toHaveBeenCalled()
  })

  it('calls onChange when file has been modified on close', async () => {
    props.onChange = jest.fn()
    props.navigator = {
      ...props.navigator,
      isModal: true,
    }
    const tree = shallow(<ViewFile {...props} />)
    await tree.find('Screen').prop('leftBarButtons')[0].action()
    expect(props.onChange).not.toHaveBeenCalled()
    expect(props.navigator.dismiss).toHaveBeenCalled()
    tree.instance().handleChange({ ...props.file })
    await tree.find('Screen').prop('leftBarButtons')[0].action()
    expect(props.onChange).toHaveBeenCalled()
  })

  it('does not try to stop a download if complete on unmount', async () => {
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for mkdir to complete.
    await Promise.resolve() // wait for downloadFile to complete.
    await updatedState(tree)
    stopDownload.mockReset()
    tree.unmount()
    expect(stopDownload).not.toHaveBeenCalled()
  })

  it('stops downloading the file on unmount', async () => {
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve()
    await Promise.resolve()
    tree.unmount()
    expect(stopDownload).toHaveBeenCalledWith('1')
  })

  it('gets the file information when it doesnt have it', async () => {
    let getFile = jest.fn()
    shallow(<ViewFile {...props} file={null} getFile={getFile} />)
    expect(getFile).toHaveBeenCalledWith('24')
  })

  it('checks if the file already exists locally and if it does, uses it', async () => {
    let existsPromise = Promise.resolve(true)
    exists.mockReturnValueOnce(existsPromise)

    let tree = shallow(<ViewFile {...props} />)
    await existsPromise
    await Promise.resolve() // wait for mkdir
    expect(tree.state()).toMatchObject({
      jobID: null,
      localPath: 'file://tmp/file-24/picture<>()[]{}._%日本_.jpg',
      loadingDone: true,
      error: null,
    })
  })

  it('uses the correct navbar style when shown in a modal', async () => {
    props.file.mime_class = 'image'
    props.navigator.isModal = true
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for file download.
    await updatedState(tree)
    tree.update()
    expect(tree.find('Screen').props().navBarStyle).toBe('modal')
  })
})
