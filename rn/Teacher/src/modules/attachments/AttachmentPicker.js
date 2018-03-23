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

import React, { Component } from 'react'
import {
  View,
  ActionSheetIOS,
  AlertIOS,
  StyleSheet,
  Modal,
  NativeModules,
} from 'react-native'
import { DocumentPicker, DocumentPickerUtil } from 'react-native-document-picker'
import ImagePicker from 'react-native-image-picker'
import AudioRecorder from '../../common/components/AudioRecorder'
import i18n from 'format-message'
import Permissions from '../../common/permissions'

export type MediaType = 'camera' | 'audio' | 'photo_library' | 'file'
type Callback = (Attachment, MediaType) => *

type Options = {
  imagePicker: any, // options passed to react-native-image-picker
}
type Props = {
  mediaTypes: Array<MediaType>,
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

export default class AttachmentPicker extends Component<Props, any> {
  static defaultProps = {
    mediaTypes: ['camera', 'audio', 'photo_library', 'file'],
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

  show (options: ?Options, callback: Callback) {
    const labels: { [MediaType]: string } = {
      camera: i18n('Use Camera'),
      audio: i18n('Record Audio'),
      photo_library: i18n('Choose From Library'),
      file: i18n('Upload File'),
    }
    ActionSheetIOS.showActionSheetWithOptions({
      options: [...this.props.mediaTypes.map(t => labels[t]), i18n('Cancel')],
      cancelButtonIndex: this.props.mediaTypes.length,
    }, this._chooseUploadOption(options, callback))
  }

  cancel () {
    // no-op, dismisses action sheet
  }

  useCamera (options: ?Options, callback: Callback) {
    const opts = options && options.imagePicker || DEFAULT_OPTIONS.imagePicker
    ImagePicker.launchCamera(opts, this._handleImagePickerResponse(callback, 'camera'))
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
    ImagePicker.launchImageLibrary(opts, this._handleImagePickerResponse(callback, 'photo_library'))
  }

  pickDocument (options: ?Options, callback: Callback) {
    DocumentPicker.show({
      filetype: [DocumentPickerUtil.allFiles()],
      top: 12,
      left: this.state.width - 30,
    }, this._handleDocumentPickerResponse(callback))
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
        >
          <View style={style.audioRecorderContainer}>
            <View style={{ height: 250 }}>
              <AudioRecorder
                onFinishedRecording={this._handleAudioRecorderResponse}
                onCancel={this._onAudioRecorderCancel}
              />
            </View>
          </View>
        </Modal>
      </View>
    )
  }

  _chooseUploadOption (options: ?Options, callback: Callback) {
    return (index: number) => {
      if (index >= this.props.mediaTypes.length) {
        return this.cancel()
      }
      switch (this.props.mediaTypes[index]) {
        case 'camera': return this.useCamera(options, callback)
        case 'audio': return this.recordAudio(options, callback)
        case 'photo_library': return this.useLibrary(options, callback)
        case 'file': return this.pickDocument(options, callback)
      }
    }
  }

  _handleImagePickerResponse (callback: Callback, type: MediaType) {
    return async (response: any) => {
      if (response.error) {
        if (IMAGE_PICKER_PERMISSION_ERRORS[response.error]) {
          Permissions.alert(IMAGE_PICKER_PERMISSION_ERRORS[response.error])
        } else {
          AlertIOS.alert(
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
          AlertIOS.alert(
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
      callback(attachment, type)
    }
  }

  _handleAudioRecorderResponse = (response: any) => {
    this.setState({ audioRecorderVisible: false })
    const attachment = {
      uri: response.filePath,
      display_name: response.fileName,
      mime_class: 'audio',
    }
    this.state.recordAudioCallback(attachment, 'audio')
  }

  _onAudioRecorderCancel = () => {
    this.setState({ audioRecorderVisible: false })
  }

  _handleDocumentPickerResponse = (callback: Callback) => {
    return (error, result) => {
      if (error) {
        AlertIOS.alert(i18n('Upload error'))
        return
      }
      const { uri, fileName, fileSize } = result
      const attachment = {
        uri,
        display_name: fileName,
        size: fileSize,
        mime_class: 'file',
      }
      callback(attachment, 'file')
    }
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
