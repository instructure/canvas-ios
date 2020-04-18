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
  ActionSheetIOS,
  Alert,
  NativeModules,
} from 'react-native'
import renderer from 'react-test-renderer'
import AttachmentPicker from '../AttachmentPicker'
import ImagePicker from 'react-native-image-picker'
import DocumentPicker from 'react-native-document-picker'
import explore from '../../../../test/helpers/explore'
import Permissions from '../../../common/permissions'
import * as template from '../../../__templates__'

jest
  .mock('react-native/Libraries/Components/Button', () => 'Button')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../common/components/AudioRecorder', () => 'AudioRecorder')
  .mock('react-native-document-picker', () => ({
    __esModule: true,
    default: {
      pick: jest.fn((options) => Promise.resolve({
        uri: 'file://path/to/somewhere/on/disk.pdf',
        name: 'disk.pdf',
        size: 100,
      })),
      types: {
        allFiles: jest.fn(() => 'content'),
        images: jest.fn(() => 'image'),
        video: jest.fn(() => 'video'),
        audio: jest.fn(() => 'audio'),
      },
      isCancel: jest.fn(),
    },
  }))
  .mock('../../../common/permissions')

describe('AttachmentPicker', () => {
  it('renders', () => {
    expect(
      renderer.create(<AttachmentPicker />).toJSON()
    ).toMatchSnapshot()
  })

  let picker
  beforeEach(() => {
    const fileTypes = ['all']
    picker = new AttachmentPicker({ fileTypes })
  })

  it('shows an action sheet with attachment options', () => {
    const mock = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = mock
    const picker = shallow(<AttachmentPicker fileTypes={['all']} />)
    picker.instance().show(null, jest.fn())
    expect(mock).toHaveBeenCalledWith({
      options: [
        'Record Audio',
        'Use Camera',
        'Upload File',
        'Choose From Library',
        'Cancel',
      ],
      cancelButtonIndex: 4,
    }, expect.any(Function))
  })

  it('shows an action sheet with user files option', () => {
    const mock = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = mock
    const picker = shallow(<AttachmentPicker fileTypes={['all']} userFiles={true} />)
    picker.instance().show(null, jest.fn())
    expect(mock).toHaveBeenCalledWith({
      options: [
        'Record Audio',
        'Use Camera',
        'Upload File',
        'Choose From Library',
        'My Files',
        'Cancel',
      ],
      cancelButtonIndex: 5,
    }, expect.any(Function))
  })

  it('shows an action sheet with image attachment options', () => {
    const mock = jest.fn()
    const picker = shallow(<AttachmentPicker fileTypes={['image']} />)
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = mock
    picker.instance().show(null, jest.fn())
    expect(mock).toHaveBeenCalledWith({
      options: [
        'Use Camera',
        'Upload File',
        'Choose From Library',
        'Cancel',
      ],
      cancelButtonIndex: 3,
    }, expect.any(Function))
  })

  it('shows an action sheet with audio attachment options', () => {
    const mock = jest.fn()
    const picker = shallow(<AttachmentPicker fileTypes={['audio']} />)
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = mock
    picker.instance().show(null, jest.fn())
    expect(mock).toHaveBeenCalledWith({
      options: [
        'Record Audio',
        'Upload File',
        'Cancel',
      ],
      cancelButtonIndex: 2,
    }, expect.any(Function))
  })

  it('shows an action sheet with video attachment options', () => {
    const mock = jest.fn()
    const picker = shallow(<AttachmentPicker fileTypes={['video']} />)
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = mock
    picker.instance().show(null, jest.fn())
    expect(mock).toHaveBeenCalledWith({
      options: [
        'Use Camera',
        'Upload File',
        'Choose From Library',
        'Cancel',
      ],
      cancelButtonIndex: 3,
    }, expect.any(Function))
  })

  it('launches camera', () => {
    ImagePicker.launchCamera = jest.fn()
    picker.useCamera(null, jest.fn())
    expect(ImagePicker.launchCamera).toHaveBeenCalled()
  })

  it('launches camera with options', () => {
    ImagePicker.launchCamera = jest.fn()
    const options = {
      imagePicker: {
        mediaType: 'video',
      },
    }
    picker.useCamera(options, jest.fn())
    expect(ImagePicker.launchCamera).toHaveBeenCalledWith(options.imagePicker, expect.any(Function))
  })

  it('returns attachment from ImagePicker image', async () => {
    NativeModules.NativeFileSystem.convertToJPEG = jest.fn(() => Promise.resolve('/tmp/image.jpg'))
    const spy = jest.fn()
    const response = {
      uri: 'file://somewhere/on/disk.jpg',
    }
    ImagePicker.launchCamera = jest.fn((options, callback) => callback(response))
    picker.useCamera(null, spy)
    await new Promise((resolve, reject) => process.nextTick(resolve))
    expect(spy).toHaveBeenCalledWith({
      uri: '/tmp/image.jpg',
      display_name: expect.stringMatching(/.jpg$/),
      size: undefined,
      mime_class: 'image',
    }, 'camera')
  })

  it('returns attachment from ImagePicker video', () => {
    const spy = jest.fn()
    const response = {
      uri: 'file://somewhere/on/disk.mov',
    }
    ImagePicker.launchImageLibrary = jest.fn((options, callback) => callback(response))
    picker.useLibrary(null, spy)
    expect(spy).toHaveBeenCalledWith({
      uri: response.uri,
      display_name: expect.stringMatching(/.mov/),
      size: undefined,
      mime_class: 'video',
    }, 'photoLibrary')
  })

  it('does not return when ImagePicker cancels', () => {
    const spy = jest.fn()
    const response = {
      didCancel: true,
    }
    ImagePicker.launchImageLibrary = jest.fn((options, callback) => callback(response))
    picker.useLibrary(null, spy)
    expect(spy).not.toHaveBeenCalled()
  })

  it('launches photo library', () => {
    ImagePicker.launchImageLibrary = jest.fn()
    picker.useLibrary(null, jest.fn())
    expect(ImagePicker.launchImageLibrary).toHaveBeenCalled()
  })

  it('launches photo library with options', () => {
    ImagePicker.launchImageLibrary = jest.fn()
    const options = {
      imagePicker: {
        mediaType: 'video',
      },
    }
    picker.useLibrary(options, jest.fn())
    expect(ImagePicker.launchImageLibrary).toHaveBeenCalledWith(options.imagePicker, expect.any(Function))
  })

  it('launches document picker', async () => {
    const picker = renderer.create(<AttachmentPicker />).getInstance()
    picker.onLayout({ nativeEvent: { layout: { width: 100, height: 200 } } })
    DocumentPicker.pick = jest.fn()
    await picker.pickDocument(null, jest.fn())
    expect(DocumentPicker.pick).toHaveBeenCalledWith({
      type: [DocumentPicker.types.allFiles],
    })
  })

  it('launches document picker with limited file types', async () => {
    const fileTypes = ['image', 'video', 'audio']
    const picker = renderer.create(<AttachmentPicker fileTypes={fileTypes} />).getInstance()
    picker.onLayout({ nativeEvent: { layout: { width: 100, height: 200 } } })
    DocumentPicker.pick = jest.fn()
    await picker.pickDocument(null, jest.fn())
    expect(DocumentPicker.pick).toHaveBeenCalledWith({
      type: [
        DocumentPicker.types.images,
        DocumentPicker.types.video,
        DocumentPicker.types.audio,
      ],
    })
  })

  it('alerts document picker errors', async () => {
    const spy = jest.fn()
    // $FlowFixMe
    Alert.alert = spy
    DocumentPicker.pick = jest.fn((options) => Promise.reject('ERROR'))
    await picker.pickDocument(null, jest.fn())
    expect(spy).toHaveBeenCalledWith('Upload error')
  })

  it('returns attachment from document picker', async () => {
    const doc = {
      uri: 'file://path/to/somewhere/on/disk.pdf',
      name: 'disk.pdf',
      size: 100,
    }
    DocumentPicker.pick = jest.fn((options) => Promise.resolve(doc))
    const spy = jest.fn()
    await picker.pickDocument(null, spy)
    expect(spy).toHaveBeenCalledWith({
      uri: doc.uri,
      display_name: doc.name,
      size: doc.size,
      mime_class: 'file',
    }, 'files')
  })

  it('cancels document picker', async () => {
    DocumentPicker.pick = jest.fn((options) => Promise.reject('cancel'))
    DocumentPicker.isCancel = jest.fn((e) => true)
    const callback = jest.fn()
    const alert = jest.fn()
    Alert.alert = alert
    await picker.pickDocument(null, callback)
    expect(callback).not.toHaveBeenCalled()
    expect(alert).not.toHaveBeenCalled()
  })

  it('shows audio recorder', async () => {
    const view = renderer.create(<AttachmentPicker />)
    const audioRecorder = () => explore(view.toJSON()).selectByType('Modal')
    expect(audioRecorder().props.visible).toBeFalsy()
    await view.getInstance().recordAudio(null, jest.fn())
    expect(audioRecorder().props.visible).toBeTruthy()
  })

  it('shows user files picker', () => {
    const navigator = template.navigator({ show: jest.fn() })
    const picker = renderer.create(<AttachmentPicker navigator={navigator} />).getInstance()
    picker.userFiles(null, jest.fn())
    expect(navigator.show).toHaveBeenCalledWith('/users/self/files', { modal: true }, {
      onSelectFile: expect.any(Function),
      canSelectFile: expect.any(Function),
      canEdit: false,
      canAdd: false,
    })
  })

  it('calls callback when user file selected', async () => {
    const callback = jest.fn()
    const file = template.file()
    const navigator = template.navigator({
      show: jest.fn((route, options, props) => {
        props.onSelectFile(template.file())
      }),
    })
    const picker = renderer.create(<AttachmentPicker navigator={navigator} />).getInstance()
    picker.userFiles(null, callback)
    await navigator.dismiss()
    expect(callback).toHaveBeenCalledWith(file, 'userFiles')
  })

  it('filters user files by file types', () => {
    let canSelectFile
    const navigator = template.navigator({
      show: jest.fn((route, options, props) => {
        canSelectFile = props.canSelectFile
      }),
    })
    const picker = renderer.create(<AttachmentPicker navigator={navigator} fileTypes={['image', 'video']} />).getInstance()
    picker.userFiles(null, jest.fn())

    const image = template.file({ mime_class: 'image', 'content-type': 'image/jpeg' })
    expect(canSelectFile(image)).toBeTruthy()

    const video = template.file({ mime_class: 'movie', 'content-type': 'video/mpeg' })
    expect(canSelectFile(video)).toBeTruthy()

    const pdf = template.file({ mime_class: 'file', 'content-type': 'file/pdf' })
    expect(canSelectFile(pdf)).toBeFalsy()
  })

  it('can select all files', () => {
    let canSelectFile
    const navigator = template.navigator({
      show: jest.fn((route, options, props) => {
        canSelectFile = props.canSelectFile
      }),
    })
    const picker = renderer.create(<AttachmentPicker navigator={navigator} fileTypes={['all']} />).getInstance()
    picker.userFiles(null, jest.fn())
    const image = template.file({ mime_class: 'image', 'content-type': 'image/jpeg' })
    expect(canSelectFile(image)).toBeTruthy()

    const video = template.file({ mime_class: 'movie', 'content-type': 'video/mpeg' })
    expect(canSelectFile(video)).toBeTruthy()

    const pdf = template.file({ mime_class: 'file', 'content-type': 'file/pdf' })
    expect(canSelectFile(pdf)).toBeTruthy()
  })

  it('hides audio recorder when it cancels', async () => {
    const view = renderer.create(<AttachmentPicker />)
    const modal = () => explore(view.toJSON()).selectByType('Modal')
    const audioRecorder = explore(view.toJSON()).selectByType('AudioRecorder')
    await view.getInstance().recordAudio(null, jest.fn())
    expect(modal().props.visible).toBeTruthy()
    audioRecorder.props.onCancel()
    expect(modal().props.visible).toBeFalsy()
  })

  it('returns attachment from audio recorder', async () => {
    const recording = {
      filePath: 'file://somewhere/on/disk.m4a',
      fileName: 'disk.m4a',
    }
    const view = renderer.create(<AttachmentPicker />)
    const spy = jest.fn()
    await view.getInstance().recordAudio(null, spy)
    const audioRecorder: any = explore(view.toJSON()).selectByType('AudioRecorder')
    audioRecorder.props.onFinishedRecording(recording)
    expect(spy).toHaveBeenCalledWith({
      uri: recording.filePath,
      display_name: recording.fileName,
      mime_class: 'audio',
    }, 'audio')
  })

  it('cancels without error', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(4))
    expect(() => {
      picker.show(null, jest.fn())
    }).not.toThrow()
  })

  it('alerts if image picker lacks permissions', () => {
    const spy = jest.fn()
    Alert.alert = spy
    const response = {
      error: 'Camera permissions not granted',
    }
    ImagePicker.launchImageLibrary = jest.fn((options, callback) => callback(response))
    picker.useLibrary(null, jest.fn())
    expect(spy).toHaveBeenCalledWith('Permission Needed', Permissions.errorMessages().camera, expect.any(Array))
  })

  it('alerts image picker errors', () => {
    const spy = jest.fn()
    Alert.alert = spy
    const response = {
      error: 'FAIL',
    }
    ImagePicker.launchImageLibrary = jest.fn((options, callback) => callback(response))
    picker.useLibrary(null, jest.fn())
    expect(spy).toHaveBeenCalledWith('Error', 'FAIL', expect.any(Array))
  })

  it('converts heic to jpg', async () => {
    NativeModules.NativeFileSystem.convertToJPEG = jest.fn(() => Promise.resolve('/tmp/image.jpg'))
    const spy = jest.fn()
    const response = {
      uri: 'file://somewhere/on/disk.heic',
    }
    ImagePicker.launchCamera = jest.fn((options, callback) => callback(response))
    picker.useCamera(null, spy)
    await new Promise((resolve, reject) => process.nextTick(resolve))
    expect(spy).toHaveBeenCalledWith({
      uri: '/tmp/image.jpg',
      display_name: expect.stringMatching(/.jpg$/),
      size: undefined,
      mime_class: 'image',
    }, 'camera')
  })
})
