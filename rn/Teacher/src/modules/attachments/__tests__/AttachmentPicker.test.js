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
import AttachmentPicker from '../AttachmentPicker'
import ImagePicker from 'react-native-image-picker'
import { DocumentPicker, DocumentPickerUtil } from 'react-native-document-picker'
import explore from '../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../common/components/AudioRecorder', () => 'AudioRecorder')
  .mock('react-native-document-picker', () => ({
    DocumentPicker: {
      show: jest.fn((options, callback) => callback({
        uri: 'file://path/to/somewhere/on/disk.pdf',
        fileName: 'disk.pdf',
        fileSize: 100,
      })),
    },
    DocumentPickerUtil: {},
  }))

describe('AttachmentPicker', () => {
  it('renders', () => {
    expect(
      renderer.create(<AttachmentPicker />).toJSON()
    ).toMatchSnapshot()
  })

  let picker
  beforeEach(() => {
    picker = new AttachmentPicker({})
  })

  it('shows an action sheet with attachment options', () => {
    const mock = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = mock
    picker.show(null, jest.fn())
    expect(mock).toHaveBeenCalledWith({
      options: [
        'Use Camera',
        'Record Audio',
        'Choose From Library',
        'Upload File',
        'Cancel',
      ],
      cancelButtonIndex: 4,
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

  it('returns attachment from ImagePicker image', () => {
    const spy = jest.fn()
    const response = {
      uri: 'file://somewhere/on/disk.jpg',
    }
    ImagePicker.launchCamera = jest.fn((options, callback) => callback(response))
    picker.useCamera(null, spy)
    expect(spy).toHaveBeenCalledWith({
      uri: response.uri,
      display_name: 'Media Attachment.jpg',
      size: undefined,
      mime_class: 'image',
    })
  })

  it('returns attachment from ImagePicker video', () => {
    const spy = jest.fn()
    const response = {
      uri: 'file://somewhere/on/disk.MOV',
    }
    ImagePicker.launchImageLibrary = jest.fn((options, callback) => callback(response))
    picker.useLibrary(null, spy)
    expect(spy).toHaveBeenCalledWith({
      uri: response.uri,
      display_name: 'Media Attachment.MOV',
      size: undefined,
      mime_class: 'video',
    })
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

  it('launches document picker', () => {
    DocumentPicker.show = jest.fn()
    DocumentPickerUtil.allFiles = jest.fn()
    picker.pickDocument(null, jest.fn())
    expect(DocumentPicker.show).toHaveBeenCalledWith({
      filetype: expect.any(Array),
    }, expect.any(Function))
    expect(DocumentPickerUtil.allFiles).toHaveBeenCalled()
  })

  it('alerts document picker errors', () => {
    const spy = jest.fn()
    // $FlowFixMe
    AlertIOS.alert = spy
    DocumentPicker.show = jest.fn((options, callback) => callback('ERROR', null))
    picker.pickDocument(null, jest.fn())
    expect(spy).toHaveBeenCalledWith('Upload error')
  })

  it('returns attachment from document picker', () => {
    const doc = {
      uri: 'file://path/to/somewhere/on/disk.pdf',
      fileName: 'disk.pdf',
      fileSize: 100,
    }
    DocumentPicker.show = jest.fn((options, callback) => callback(null, doc))
    const spy = jest.fn()
    picker.pickDocument(null, spy)
    expect(spy).toHaveBeenCalledWith({
      uri: doc.uri,
      display_name: doc.fileName,
      size: doc.fileSize,
      mime_class: 'file',
    })
  })

  it('shows audio recorder', () => {
    const view = renderer.create(<AttachmentPicker />)
    const audioRecorder = () => explore(view.toJSON()).selectByType('Modal')
    expect(audioRecorder().props.visible).toBeFalsy()
    view.getInstance().recordAudio(null, jest.fn())
    expect(audioRecorder().props.visible).toBeTruthy()
  })

  it('hides audio recorder when it cancels', () => {
    const view = renderer.create(<AttachmentPicker />)
    const modal = () => explore(view.toJSON()).selectByType('Modal')
    const audioRecorder = explore(view.toJSON()).selectByType('AudioRecorder')
    view.getInstance().recordAudio(null, jest.fn())
    expect(modal().props.visible).toBeTruthy()
    audioRecorder.props.onCancel()
    expect(modal().props.visible).toBeFalsy()
  })

  it('returns attachment from audio recorder', () => {
    const recording = {
      filePath: 'file://somewhere/on/disk.m4a',
      fileName: 'disk.m4a',
    }
    const view = renderer.create(<AttachmentPicker />)
    const spy = jest.fn()
    view.getInstance().recordAudio(null, spy)
    const audioRecorder: any = explore(view.toJSON()).selectByType('AudioRecorder')
    audioRecorder.props.onFinishedRecording(recording)
    expect(spy).toHaveBeenCalledWith({
      uri: recording.filePath,
      display_name: recording.fileName,
      mime_class: 'audio',
    })
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
    AlertIOS.alert = spy
    const response = {
      error: 'Camera permissions not granted',
    }
    ImagePicker.launchImageLibrary = jest.fn((options, callback) => callback(response))
    picker.useLibrary(null, jest.fn())
    expect(spy).toHaveBeenCalledWith('Permission Needed', response.error, expect.any(Array))
  })

  it('alerts image picker errors', () => {
    const spy = jest.fn()
    AlertIOS.alert = spy
    const response = {
      error: 'FAIL',
    }
    ImagePicker.launchImageLibrary = jest.fn((options, callback) => callback(response))
    picker.useLibrary(null, jest.fn())
    expect(spy).toHaveBeenCalledWith('Error', 'FAIL', expect.any(Array))
  })
})
