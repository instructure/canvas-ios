// @flow

import React, { Component } from 'react'
import {
  ActionSheetIOS,
  AlertIOS,
} from 'react-native'
import { DocumentPicker, DocumentPickerUtil } from 'react-native-document-picker'
import ImagePicker from 'react-native-image-picker'
import AudioRecorder from '../../common/components/AudioRecorder'
import i18n from 'format-message'

type Callback = (Attachment) => void
type Options = {
  imagePicker: any, // options passed to react-native-image-picker
}
type Props = {}

export const DEFAULT_OPTIONS: Options = {
  imagePicker: {
    mediaType: 'mixed',
  },
}

export default class AttachmentPicker extends Component<any, Props, any> {
  constructor (props: Props) {
    super(props)
    this.state = {
      audioRecorderVisible: false,
      recordAudioCallback: null,
    }
  }

  show (options: ?Options, callback: Callback) {
    ActionSheetIOS.showActionSheetWithOptions({
      options: [
        i18n('Use Camera'),
        i18n('Record Audio'),
        i18n('Choose From Library'),
        i18n('Upload File'),
        i18n('Cancel'),
      ],
      cancelButtonIndex: 4,
    }, this._chooseUploadOption(options, callback))
  }

  cancel () {
    // no-op, dismisses action sheet
  }

  useCamera (options: ?Options, callback: Callback) {
    const opts = options && options.imagePicker || DEFAULT_OPTIONS.imagePicker
    ImagePicker.launchCamera(opts, this._handleImagePickerResponse(callback))
  }

  recordAudio (options: ?Options, callback: Callback) {
    this.setState({
      audioRecorderVisible: true,
      recordAudioCallback: callback,
    })
  }

  useLibrary (options: ?Options, callback: Callback) {
    const opts = options && options.imagePicker || DEFAULT_OPTIONS.imagePicker
    ImagePicker.launchImageLibrary(opts, this._handleImagePickerResponse(callback))
  }

  pickDocument (options: ?Options, callback: Callback) {
    DocumentPicker.show({
      filetype: [DocumentPickerUtil.allFiles()],
    }, this._handleDocumentPickerResponse(callback))
  }

  render () {
    return (
      <AudioRecorder
        visible={this.state.audioRecorderVisible}
        onFinishedRecording={this._handleAudioRecorderResponse}
        onCancel={this._onAudioRecorderCancel}
      />
    )
  }

  _chooseUploadOption (options: ?Options, callback: Callback) {
    return (index: number) => {
      const all = [
        this.useCamera,
        this.recordAudio,
        this.useLibrary,
        this.pickDocument,
        this.cancel,
      ]
      all[index].bind(this)(options, callback)
    }
  }

  _handleImagePickerResponse (callback: Callback) {
    return (response: any) => {
      if (response.didCancel || !response.uri) {
        return
      }
      const { uri, fileSize, fileName } = response
      const extension = uri.substring(uri.lastIndexOf('.'))
      let name = fileName || `${i18n('Media Attachment')}${extension}`
      const attachment = {
        uri,
        size: fileSize,
        display_name: name,
        mime_class: extension.toLowerCase() === '.mov' ? 'video' : 'image',
      }
      callback(attachment)
    }
  }

  _handleAudioRecorderResponse = (response: any) => {
    this.setState({ audioRecorderVisible: false })
    const attachment = {
      uri: response.filePath,
      display_name: response.fileName,
      mime_class: 'audio',
    }
    this.state.recordAudioCallback(attachment)
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
      callback(attachment)
    }
  }
}
