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
  StyleSheet,
  Text,
  TouchableHighlight,
  View,
  Image,
  AlertIOS,
} from 'react-native'
import i18n from 'format-message'
import { AudioRecorder as RNAudioRecorder, AudioUtils } from 'react-native-audio'
import images from '../../images'
import colors from '../colors'

type Props = {
  onFinishedRecording: (Recording) => any,
  onCancel: () => void,
  doneButtonText?: string,
}

export default class AudioRecorder extends Component<Props, any> {
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
    this.prepareRecording()

    RNAudioRecorder.onFinished = (data) => {
      if (this.state.cancelled) {
        this.prepareRecording()
        return
      }
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
    const a11yMinutes = i18n(`{
      minutes, plural,
        one {# minute}
        other {# minutes}
    }`, { minutes })
    const a11ySeconds = i18n(`{
      seconds, plural,
        one {# second}
        other {# seconds}
    }`, { seconds })
    const currentTimeA11yLabel = i18n('Time elapsed: {minutes}, {seconds}.', {
      minutes: a11yMinutes,
      seconds: a11ySeconds,
    })

    return (
      <View style={style.recorder}>
        <View style={style.header}>
          <View style={{ width: 24 }}>
            { this.state.stoppedRecording &&
              <TouchableHighlight
                hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
                onPress={this._remove}
                testID='audio-recorder.reset-btn'
                underlayColor='transparent'
                accessibilityLabel={i18n('Clear recording')}
                accessibilityTraits='button'
              >
                <Image source={images.mediaComments.trash} style={style.headerButtonImage} />
              </TouchableHighlight>
            }
          </View>
          <View accessibilityLabel={currentTimeA11yLabel} accessible={true} style={{ flex: 1 }}>
            <Text style={style.title} accessibilityLabel={currentTimeA11yLabel}>
              {currentTime}
            </Text>
          </View>
          <View style={[style.headerButton, style.cancel]}>
            { !this.state.recording &&
              <TouchableHighlight
                onPress={this._cancel}
                hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
                testID='audio-recorder.cancel-btn'
                underlayColor='transparent'
                accessibilityLabel={i18n('Cancel')}
                accessibilityTraits='button'
              >
                <Image source={images.mediaComments.x} style={style.headerButtonImage} />
              </TouchableHighlight>
            }
          </View>
        </View>
        <View style={style.buttonContainer}>
          { !this.state.recording && !this.state.stoppedRecording && this._renderRecordButton() }
          { this.state.recording && this._renderStopButton() }
          { Boolean(this.state.filePath) && this._renderSendButton() }
        </View>
      </View>
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
      this.prepareRecording()
      AlertIOS.alert(i18n('Recording failed'))
    }
  }

  prepareRecording () {
    this.setState({
      filePath: null,
      cancelled: false,
      stoppedRecording: false,
      currentTime: 0,
    })

    const timestamp = (new Date()).toISOString()
    const fileName = `${timestamp}.m4a`
    const audioPath = `${AudioUtils.CachesDirectoryPath}/${fileName}`

    RNAudioRecorder.prepareRecordingAtPath(audioPath, {
      SampleRate: 22050,
      Channels: 2,
      AudioQuality: 'Medium',
      AudioEncoding: 'aac',
    })

    this.setState({ fileName })
  }

  _finishRecording (success, filePath) {
    if (success) {
      this.setState({ stoppedRecording: true, filePath })
    } else {
      this.prepareRecording()
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
    if (this.state.stoppedRecording) {
      this.prepareRecording()
    } else {
      // We are still recording so we have to stop without sending result.
      this.setState({ cancelled: true })
      await this.stopRecording()
    }
    this.props.onCancel()
  }

  _remove = () => {
    this.prepareRecording()
  }

  _renderRecordButton () {
    return (
      <View style={style.buttonOuter}>
        <TouchableHighlight
          style={style.recordButton}
          onPress={this.startRecording}
          testID='audio-recorder.record-btn'
          accessibilityLabel={i18n('Start recording')}
          accessibilityTraits='button'
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
          accessibilityLabel={i18n('Stop recording')}
          accessibilityTraits='button'
        >
          <View></View>
        </TouchableHighlight>
      </View>
    )
  }

  _renderSendButton () {
    const text = this.props.doneButtonText || i18n('Upload')
    return (
      <TouchableHighlight
        style={[style.sendButton, { backgroundColor: colors.primaryButtonColor }]}
        onPress={this._sendRecording}
        testID='audio-recorder.done-btn'
        accessibilityLabel={text}
      >
        <View>
          <Text style={[style.sendButtonText, { color: colors.primaryButtonTextColor }]}>
            {text}
          </Text>
        </View>
      </TouchableHighlight>
    )
  }
}

const style = StyleSheet.create({
  recorder: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'space-around',
    backgroundColor: '#F5F5F5',
  },
  header: {
    marginTop: 10,
    marginHorizontal: 8,
    alignItems: 'center',
    flexDirection: 'row',
    minHeight: 24,
  },
  title: {
    flex: 1,
    textAlign: 'center',
    fontSize: 20,
    marginHorizontal: 4,
  },
  headerButton: {
    width: 24,
  },
  headerButtonImage: {
    tintColor: '#9FA9AF',
    width: 24,
    height: 24,
  },
  cancel: {
    justifyContent: 'flex-end',
  },
  buttonContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonOuter: {
    height: 80,
    width: 80,
    borderColor: '#d9ddde',
    borderWidth: 4,
    borderRadius: 80 * 0.5,
    justifyContent: 'center',
    alignItems: 'center',
  },
  recordButton: {
    height: 64,
    width: 64,
    borderRadius: 64 * 0.5,
    backgroundColor: 'rgba(235,15,33,1)',
  },
  stopButton: {
    height: 32,
    width: 32,
    backgroundColor: 'red',
  },
  sendButton: {
    flexDirection: 'row',
    justifyContent: 'center',
    paddingVertical: 12,
    paddingHorizontal: 38,
    borderRadius: 6,
  },
  sendButtonText: {
    fontSize: 16,
    fontWeight: '700',
  },
})
