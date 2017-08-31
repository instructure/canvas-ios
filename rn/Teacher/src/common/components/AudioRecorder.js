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
  Modal,
  StyleSheet,
  Text,
  TouchableHighlight,
  View,
  Image,
  AlertIOS,
} from 'react-native'
import i18n from 'format-message'
import moment from 'moment'
import { AudioRecorder as RNAudioRecorder, AudioUtils } from 'react-native-audio'
import images from '../../images'
import colors from '../colors'

type Props = {
  visible: boolean,
  onFinishedRecording: ({ fileName: string, filePath: string }) => void,
  onCancel: () => void,
}

export default class AudioRecorder extends Component<any, Props, any> {
  constructor (props: Props) {
    super(props)

    this.state = {
      recording: false,
      stoppedRecording: false,
      cancelled: false,
      filePath: null,
      fileName: null,
      currentTime: '',
    }
  }

  componentDidMount () {
    this._prepareRecording()

    RNAudioRecorder.onFinished = (data) => {
      if (!this.state.cancelled) {
        this._finishRecording(data.status === 'OK', data.audioFileURL)
      }
    }

    RNAudioRecorder.onProgress = ({ currentTime }) => {
      this.state.recording && this.setState({ currentTime })
    }
  }

  render () {
    const minutes = Math.floor(this.state.currentTime / 60)
    const seconds = Math.floor(this.state.currentTime) - minutes * 60
    const pad = (n) => n < 10 ? `0${n}` : n
    const currentTime = `${pad(minutes)}:${pad(seconds)}`

    return (
      <Modal
        visible={this.props.visible}
        transparent={true}
        style={style.modal}
        animationType='fade'
      >
        <View style={style.container}>
          <View style={style.recorder}>
            <View style={style.header}>
              <View style={style.headerButton}>
                { this.state.stoppedRecording &&
                  <TouchableHighlight
                    hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
                    onPress={this._remove}
                    testID='audio-recorder.reset-btn'
                  >
                    <Image source={images.trash} style={style.headerButtonImage} />
                  </TouchableHighlight>
                }
              </View>
              <Text style={style.title}>
                {this.state.recording || this.state.filePath ? currentTime : i18n('Tap to record')}
              </Text>
              <View style={[style.headerButton, style.cancel]}>
                <TouchableHighlight
                  onPress={this._cancel}
                  hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
                  testID='audio-recorder.cancel-btn'
                >
                  <Image source={images.x} style={style.headerButtonImage} />
                </TouchableHighlight>
              </View>
            </View>
            <View style={style.buttonContainer}>
              { !this.state.recording && !this.state.stoppedRecording && this._renderRecordButton() }
              { this.state.recording && this._renderStopButton() }
              { Boolean(this.state.filePath) && this._renderSendButton() }
            </View>
          </View>
        </View>
      </Modal>
    )
  }

  startRecording = async () => {
    this.setState({ recording: true })

    try {
      await RNAudioRecorder.startRecording()
    } catch (error) {
      this.setState({ recording: false })
      AlertIOS.alert(i18n('Could not start recording'))
    }
  }

  stopRecording = async () => {
    this.setState({
      recording: false,
    })
    try {
      await RNAudioRecorder.stopRecording()
    } catch (error) {
      this._prepareRecording()
      AlertIOS.alert(i18n('Recording failed'))
    }
  }

  _prepareRecording () {
    this.setState({
      filePath: null,
      cancelled: false,
      stoppedRecording: false,
      currentTime: 0,
    })

    const timestamp = moment().format('MMM d YYYY h.mm.ss')
    const fileName = `${timestamp}.m4a`
    const audioPath = `${AudioUtils.CachesDirectoryPath}/${fileName}`

    RNAudioRecorder.prepareRecordingAtPath(audioPath, {
      SampleRate: 22050,
      Channels: 2,
      AudioQuality: 'Low',
      AudioEncoding: 'aac',
    })

    this.setState({ fileName })
  }

  _finishRecording (success, filePath) {
    if (success) {
      this.setState({ stoppedRecording: true, filePath })
    } else {
      this._prepareRecording()
      AlertIOS.alert(i18n('Recording failed'))
    }
  }

  _sendRecording = () => {
    const result = {
      fileName: this.state.fileName,
      filePath: this.state.filePath,
    }
    this.props.onFinishedRecording(result)
  }

  _cancel = async () => {
    this.setState({ cancelled: true })
    await this.stopRecording()
    this.props.onCancel()
  }

  _remove = () => {
    this._prepareRecording()
  }

  _renderRecordButton () {
    return (
      <View style={style.buttonOuter}>
        <TouchableHighlight
          style={style.recordButton}
          onPress={this.startRecording}
          testID='audio-recorder.record-btn'
        >
          <View></View>
        </TouchableHighlight>
      </View>
    )
  }

  _renderStopButton () {
    return (
      <View style={style.buttonOuter}>
        <TouchableHighlight
          style={style.stopButton}
          onPress={this.stopRecording}
          testID='audio-recorder.stop-btn'
        >
          <View></View>
        </TouchableHighlight>
      </View>
    )
  }

  _renderSendButton () {
    return (
      <TouchableHighlight
        style={style.sendButton}
        onPress={this._sendRecording}
        testID='audio-recorder.done-btn'
      >
        <View>
          <Text style={style.sendButtonText}>{i18n('Done')}</Text>
        </View>
      </TouchableHighlight>
    )
  }
}

const BUTTON_SIZE = 70

const style = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(0,0,0,0.8)',
  },
  recorder: {
    height: 250,
    alignItems: 'center',
    justifyContent: 'space-around',
    backgroundColor: '#F5F5F5',
  },
  header: {
    marginTop: 10,
    marginHorizontal: 8,
    alignItems: 'center',
    flexDirection: 'row',
  },
  title: {
    flex: 1,
    textAlign: 'center',
  },
  headerButton: {
    width: 20,
  },
  headerButtonImage: {
    tintColor: '#9FA9AF',
  },
  cancel: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  buttonContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonOuter: {
    height: BUTTON_SIZE,
    width: BUTTON_SIZE,
    backgroundColor: '#EBEDEE',
    borderRadius: BUTTON_SIZE * 0.5,
    justifyContent: 'center',
    alignItems: 'center',
  },
  recordButton: {
    height: BUTTON_SIZE - 6,
    width: BUTTON_SIZE - 6,
    borderRadius: (BUTTON_SIZE - 6) * 0.5,
    backgroundColor: 'red',
  },
  stopButton: {
    height: BUTTON_SIZE * 0.5,
    width: BUTTON_SIZE * 0.5,
    backgroundColor: 'red',
  },
  sendButton: {
    flexDirection: 'row',
    justifyContent: 'center',
    paddingVertical: 8,
    paddingHorizontal: 14,
    backgroundColor: colors.primaryButtonColor,
    borderRadius: 6,
  },
  sendButtonText: {
    color: colors.primaryButtonTextColor,
    fontSize: 16,
  },
})
