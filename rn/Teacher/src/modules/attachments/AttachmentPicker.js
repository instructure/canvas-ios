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

import React, { Component } from 'react'
import {
  View,
  ActionSheetIOS,
  Alert,
  StyleSheet,
  Modal,
  NativeModules,
} from 'react-native'
import DocumentPicker from 'react-native-document-picker'
import ImagePicker from 'react-native-image-picker'
import AudioRecorder from '../../common/components/AudioRecorder'
import i18n from 'format-message'
import Permissions from '../../common/permissions'

export type FileType = 'all' | 'image' | 'video' | 'audio'

export type Source = 'camera' | 'audio' | 'photoLibrary' | 'files'

type Callback = (Attachment, Source) => *

type Options = {
  imagePicker: any, // options passed to react-native-image-picker
}

type Props = NavigationProps & {
  fileTypes: Array<FileType>,
}

const IMAGE_PICKER_PERMISSION_ERRORS = {
  'Camera permissions not granted': 'camera',
  'Photo library permissions not granted': 'photos',
}

export const DEFAULT_OPTIONS: Options = {
  imagePicker: {
    mediaType: 'mixed',
  },
}

function documentPickerFileTypes (types: Array<FileType>) {
  const { allFiles, images, video, audio } = DocumentPicker.types
  if (types.includes('all')) {
    return [allFiles]
  }

  let pickerTypes = []
  if (types.includes('image')) {
    pickerTypes.push(images)
  }

  if (types.includes('video')) {
    pickerTypes.push(video)
  }

  if (types.includes('audio')) {
    pickerTypes.push(audio)
  }

  return pickerTypes
}

function possibleSources (fileType: FileType) {
  let sources = []
  switch (fileType) {
    case 'all':
      sources = ['camera', 'photoLibrary', 'audio', 'files']
      break
    case 'video':
    case 'image':
      sources = ['camera', 'photoLibrary', 'files']
      break
    case 'audio':
      sources = ['audio', 'files']
      break
  }
  return sources
}

export default class AttachmentPicker extends Component<Props, any> {
  static defaultProps = {
    fileTypes: ['all'],
  }

  constructor (props: Props) {
    super(props)
    this.state = {
      audioRecorderVisible: false,
      recordAudioCallback: null,
      width: 0,
      height: 0,
    }
  }

  sources = () => {
    let sources = new Set()
    this.props.fileTypes.forEach((fileType) => {
      possibleSources(fileType).forEach(t => sources.add(t))
    })
    return Array.from(sources).sort()
  }

  show (options: ?Options, callback: Callback) {
    const labels: { [Source]: string } = {
      camera: i18n('Use Camera'),
      audio: i18n('Record Audio'),
      photoLibrary: i18n('Choose From Library'),
      files: i18n('Upload File'),
    }
    const sources = this.sources()
    ActionSheetIOS.showActionSheetWithOptions({
      options: [...sources.map(t => labels[t]), i18n('Cancel')],
      cancelButtonIndex: sources.length,
    }, this.chooseUploadOption(options, callback))
  }

  cancel () {
    // no-op, dismisses action sheet
  }

  useCamera (options: ?Options, callback: Callback) {
    const opts = options && options.imagePicker || DEFAULT_OPTIONS.imagePicker
    ImagePicker.launchCamera(opts, this.handleImagePickerResponse(callback, 'camera'))
  }

  async recordAudio (options: ?Options, callback: Callback) {
    const permitted = await Permissions.checkMicrophone()
    if (permitted) {
      this.setState({
        audioRecorderVisible: true,
        recordAudioCallback: callback,
      })
    } else {
      Permissions.alert('microphone')
    }
  }

  useLibrary (options: ?Options, callback: Callback) {
    const opts = options && options.imagePicker || DEFAULT_OPTIONS.imagePicker
    ImagePicker.launchImageLibrary(opts, this.handleImagePickerResponse(callback, 'photoLibrary'))
  }

  async pickDocument (options: ?Options, callback: Callback) {
    try {
      const result = await DocumentPicker.pick({
        type: documentPickerFileTypes(this.props.fileTypes),
      })
      const { uri, name, size } = result
      const attachment = {
        uri,
        display_name: name,
        size: size,
        mime_class: 'file',
      }
      callback(attachment, 'files')
    } catch (err) {
      if (DocumentPicker.isCancel(err)) {
        return
      }
      Alert.alert(i18n('Upload error'))
    }
  }

  onLayout = ({ nativeEvent }: { nativeEvent: any }) => {
    const { width, height } = nativeEvent.layout
    this.setState({ width, height })
  }

  render () {
    return (
      <View
        onLayout={this.onLayout}
        style={{ flex: 1, backgroundColor: 'transparent' }}
        testID='attachment-picker.container'
      >
        <Modal
          visible={this.state.audioRecorderVisible}
          transparent={true}
          animationType='fade'
          onLayout={this.onLayout}
          supportedOrientations={['portrait', 'landscape', 'landscape-left', 'landscape-right']}
        >
          <View style={style.audioRecorderContainer}>
            <View style={{ height: 250 }}>
              <AudioRecorder
                onFinishedRecording={this.handleAudioRecorderResponse}
                onCancel={this.onAudioRecorderCancel}
              />
            </View>
          </View>
        </Modal>
      </View>
    )
  }

  chooseUploadOption (options: ?Options, callback: Callback) {
    return (index: number) => {
      const sources = this.sources()
      if (index >= sources.length) {
        return this.cancel()
      }
      switch (sources[index]) {
        case 'camera': return this.useCamera(options, callback)
        case 'audio': return this.recordAudio(options, callback)
        case 'photoLibrary': return this.useLibrary(options, callback)
        case 'files': return this.pickDocument(options, callback)
      }
    }
  }

  handleImagePickerResponse (callback: Callback, source: Source) {
    return async (response: any) => {
      if (response.error) {
        if (IMAGE_PICKER_PERMISSION_ERRORS[response.error]) {
          Permissions.alert(IMAGE_PICKER_PERMISSION_ERRORS[response.error])
        } else {
          Alert.alert(
            i18n('Error'),
            response.error,
            [{ text: i18n('OK'), onPress: null, style: 'cancel' }],
          )
        }
      }
      if (response.didCancel || !response.uri) {
        return
      }
      let { uri, fileSize, fileName } = response
      const extension = uri.substring(uri.lastIndexOf('.')).toLowerCase()
      const timestamp = (new Date()).toISOString()
      let name = fileName || `${timestamp}${extension}`
      const isVideo = extension === '.mov'
      if (!isVideo) {
        try {
          uri = await NativeModules.NativeFileSystem.convertToJPEG(uri)
          name = `${timestamp}.jpg`
        } catch (e) {
          Alert.alert(
            i18n('Error'),
            i18n('Unrecognized file format'),
            [{ text: i18n('OK'), onPress: null, style: 'cancel' }],
          )
          return
        }
      }
      const attachment = {
        uri,
        size: fileSize,
        display_name: name,
        mime_class: isVideo ? 'video' : 'image',
      }
      callback(attachment, source)
    }
  }

  handleAudioRecorderResponse = (response: any) => {
    this.setState({ audioRecorderVisible: false })
    const attachment = {
      uri: response.filePath,
      display_name: response.fileName,
      mime_class: 'audio',
    }
    this.state.recordAudioCallback(attachment, 'audio')
  }

  onAudioRecorderCancel = () => {
    this.setState({ audioRecorderVisible: false })
  }
}

const style = StyleSheet.create({
  audioRecorderContainer: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(0,0,0,0.8)',
  },
})
