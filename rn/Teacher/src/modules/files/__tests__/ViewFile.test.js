//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow
import React from 'react'
import { shallow } from 'enzyme'
import { ActionSheetIOS } from 'react-native'
import {
  downloadFile,
  stopDownload,
} from 'react-native-fs'

import ViewFile from '../ViewFile'

const template = {
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/file'),
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
  stopDownload: jest.fn(),
}))

const selectors = {
  share: '[testID="view-file.share-btn"]',
}

const updatedState = (tree: ShallowWrapper) => new Promise(resolve => tree.setState({}, resolve))

describe('ViewFile', () => {
  let props
  beforeEach(() => {
    props = {
      courseID: '1',
      fileID: '24',
      file: template.file({
        id: '24',
        filename: 'picture.jpg',
      }),
      navigator: {
        show: jest.fn(),
        dismiss: jest.fn(),
      },
      getCourse: jest.fn(() => Promise.resolve({
        data: template.course({ name: 'New Course' }),
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
    props.courseID = null
    const tree = shallow(<ViewFile {...props} />)
    expect(props.getCourse).not.toHaveBeenCalled()
    expect(tree.find('Screen').prop('subtitle')).toBeNull()
  })

  it('ignores subtitle if course loading fails', async () => {
    props.getCourse = jest.fn(() => Promise.reject())
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for course failure.
    expect(tree.find('Screen').prop('subtitle')).toBeNull()
  })

  it('ignores fetching the file for zip', async () => {
    props.file.mime_class = 'zip'
    const tree = shallow(<ViewFile {...props} />)
    expect(tree.find('Text').children().text()).toBe('Previewing this file type is not supported')
  })

  it('renders audio and video', async () => {
    props.file.mime_class = 'audio'
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for file download.
    await updatedState(tree)
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
    await Promise.resolve() // wait for file download.
    await updatedState(tree)
    expect(tree.find('Image').length).toBe(2)
  })

  it('renders image loading error', async () => {
    props.file.mime_class = 'image'
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for file download.
    await updatedState(tree)
    tree.find('Image').at(0).simulate('Error')
    await updatedState(tree)
    expect(tree.find('Text').children().text()).toBe('There was an error loading the file.')
  })

  it('renders an error message if loading fails', async () => {
    downloadFile.mockImplementationOnce(() => ({
      jobId: '2',
      promise: Promise.resolve({ statusCode: 500 }),
    }))
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for downloadFile to complete.
    await updatedState(tree)
    expect(tree.find('Text').children().text()).toBe('There was an error loading the file.')
  })

  it('handles sharing the file', async () => {
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for downloadFile to complete.
    tree.find(selectors.share).simulate('Press')
    expect(ActionSheetIOS.showShareActionSheetWithOptions).toHaveBeenCalledWith(
      { url: 'file://caches/file-24.jpg' },
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
    await Promise.resolve() // wait for downloadFile to complete.
    tree.find(selectors.share).simulate('Press')
    expect(() => {
      ActionSheetIOS.showShareActionSheetWithOptions.mock.calls[0][1]()
      ActionSheetIOS.showShareActionSheetWithOptions.mock.calls[0][2]()
    }).not.toThrow()
  })

  it('updates the title if the edit screen changes it', async () => {
    const tree = shallow(<ViewFile {...props} />)
    tree.find('Screen').prop('leftBarButtons')[0].action()
    expect(props.navigator.show).toHaveBeenLastCalledWith(
      '/courses/1/file/24/edit',
      { modal: true },
      { file: props.file, onChange: expect.any(Function), onDelete: expect.any(Function) },
    )
    props.navigator.show.mock.calls[0][2].onChange({
      ...props.file,
      name: 'changed name',
    })
    await updatedState(tree)
    expect(tree.find('Screen').prop('title')).toBe('changed name')
  })

  it('closes and calls onChange when deleted', async () => {
    const onChange = jest.fn()
    const tree = shallow(<ViewFile {...props} />)
    tree.find('Screen').prop('leftBarButtons')[0].action()
    await props.navigator.show.mock.calls[0][2].onDelete(props.file)
    expect(onChange).not.toHaveBeenCalled()
    tree.setProps({ onChange })
    await props.navigator.show.mock.calls[0][2].onDelete(props.file)
    expect(onChange).toHaveBeenCalled()
  })

  it('calls onChange when file has been modified on close', async () => {
    props.onChange = jest.fn()
    const tree = shallow(<ViewFile {...props} />)
    await tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.onChange).not.toHaveBeenCalled()
    expect(props.navigator.dismiss).toHaveBeenCalled()
    tree.instance().handleChange({ ...props.file })
    await tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.onChange).toHaveBeenCalled()
  })

  it('does not try to stop a download if complete on unmount', async () => {
    const tree = shallow(<ViewFile {...props} />)
    await Promise.resolve() // wait for downloadFile to complete.
    stopDownload.mockReset()
    tree.unmount()
    expect(stopDownload).not.toHaveBeenCalled()
  })

  it('stops downloading the file on unmount', () => {
    const tree = shallow(<ViewFile {...props} />)
    tree.unmount()
    expect(stopDownload).toHaveBeenCalledWith('1')
  })
})
