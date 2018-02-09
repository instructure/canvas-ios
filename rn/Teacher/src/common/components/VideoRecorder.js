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
  Text,
  StyleSheet,
  TouchableHighlight,
  Image,
  LayoutAnimation,
  ActivityIndicator,
} from 'react-native'
import i18n from 'format-message'
import images from '../../images'
import Camera, { constants as CameraConstants } from 'react-native-camera'
import Video from './Video'

export type Props = {
  onFinishedRecording: (Recording) => void,
  onCancel: () => void,
}

const StartStopButtonAnimation = {
  duration: 150,
  create: {
    type: LayoutAnimation.Types.linear,
    property: LayoutAnimation.Properties.opacity,
    springDamping: 0.2,
  },
  update: {
    type: LayoutAnimation.Types.linear,
    springDamping: 0.4,
  },
}

export default class VideoRecorder extends Component<Props, any> {
  camera: Camera
  currentTimeInterval: ?IntervalID

  constructor (props: Props) {
    super(props)

    this.state = {
      recording: false,
      loading: false,
      filePath: null,
      fileName: null,
      currentTime: 0,
      currentTimeInterval: null,
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

    const { recording, loading, filePath } = this.state
    const ready = filePath == null
    const finished = filePath !== null
    const showingCamera = !loading && (ready || recording)

    return (
      <View style={style.container}>
        <View style={style.header} pointerEvents='none'>
          <Text style={style.title} accessibilityLabel={currentTimeA11yLabel}>{currentTime}</Text>
        </View>
        { !recording &&
          <TouchableHighlight
            onPress={finished ? this.reset : this.cancel}
            underlayColor='transparent'
            hitSlop={{ top: 4, bottom: 4, left: 4, right: 4 }}
            testID={finished ? 'video-recorder.reset.btn' : 'video-recorder.cancel.btn'}
            style={[style.actionButton, finished ? style.resetButton : style.cancelButton]}
            accessibilityLabel={finished ? i18n('Clear recording') : i18n('Cancel')}
            accessibilityTraits='button'
          >
            <Image source={images.mediaComments[finished ? 'trash' : 'x']} style={style.actionButtonImage} />
          </TouchableHighlight>
        }
        { finished &&
          <TouchableHighlight
            onPress={this.send}
            underlayColor='transparent'
            hitSlop={{ top: 4, bottom: 4, left: 4, right: 4 }}
            testID='video-recorder.send.btn'
            accessibilityLabel={i18n('Send recording')}
            accessibilityTraits='button'
            style={[style.actionButton, style.sendButton]}
          >
            <Image source={images.mediaComments.send} style={style.actionButtonImage} />
          </TouchableHighlight>
        }
        { showingCamera &&
          <View style={style.controls}>
            <TouchableHighlight
              onPress={this._toggleRecording}
              testID='video-recorder.start-recording.btn'
              style={[style.startStopButtonContainer, {
                borderColor: recording ? 'rgba(255,255,255,0.2)' : 'rgba(255,255,255,1)',
              }]}
              underlayColor='transparent'
              accessibilityLabel={recording ? i18n('Stop recording') : i18n('Start recording')}
              accessibilityTraits='button'
            >
              <View style={recording ? style.stopButton : style.startButton}>
              </View>
            </TouchableHighlight>
          </View>
        }
        { loading &&
          <View style={style.loading}>
            <ActivityIndicator animating={true} />
          </View>
        }
        { showingCamera &&
          <Camera
            captureTarget={CameraConstants.CaptureTarget.disk}
            captureMode={CameraConstants.CaptureMode.video}
            captureAudio={true}
            captureQuality={CameraConstants.CaptureQuality.medium}
            type={CameraConstants.Type.front}
            style={style.camera}
            aspect={CameraConstants.Aspect.fit}
            ref={this.captureCamera}
          />
        }
        { finished &&
          <Video
            style={style.video}
            source={{ uri: `file://${this.state.filePath}` }}
          />
        }
      </View>
    )
  }

  captureCamera = (ref: Camera) => {
    this.camera = ref
  }

  _toggleRecording = () => {
    this.state.recording ? this.stopRecording() : this.startRecording()
  }

  startRecording () {
    LayoutAnimation.configureNext(StartStopButtonAnimation)
    this.setState({ recording: true })
    this.camera.capture().then(({ path }) => {
      this.setState({ filePath: path, loading: false })
    })
    this.currentTimeInterval = setInterval(() => {
      this.setState(prevState => ({
        currentTime: prevState.currentTime + 1,
      }))
    }, 1000)
  }

  stopRecording () {
    this.setState({ recording: false, loading: true })
    this.camera && this.camera.stopCapture()
    LayoutAnimation.configureNext(StartStopButtonAnimation)
    this.currentTimeInterval && clearInterval(this.currentTimeInterval)
  }

  send = () => {
    this.props.onFinishedRecording({
      fileName: i18n('Video Recording'),
      filePath: this.state.filePath,
    })
  }

  reset = () => {
    this.currentTimeInterval && clearInterval(this.currentTimeInterval)
    this.setState({
      recording: false,
      filePath: null,
      currentTime: 0,
    })
  }

  cancel = () => {
    this.currentTimeInterval && clearInterval(this.currentTimeInterval)
    this.camera && this.camera.stopCapture()
    this.props.onCancel()
  }
}

const ACTION_BUTTON_MARGIN = 7
const ACTION_BUTTON_BOTTOM = 50

const style = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    backgroundColor: 'rgba(0,0,0,0.2)',
    paddingHorizontal: 16,
    paddingVertical: 12,
    alignItems: 'center',
    zIndex: 2,
  },
  title: {
    flex: 1,
    fontSize: 20,
    color: 'white',
    textAlign: 'center',
  },
  cancelButton: {
    position: 'absolute',
    top: 8,
    left: ACTION_BUTTON_MARGIN,
    zIndex: 2,
  },
  resetButton: {
    position: 'absolute',
    bottom: ACTION_BUTTON_BOTTOM,
    left: ACTION_BUTTON_MARGIN,
    zIndex: 2,
  },
  sendButton: {
    position: 'absolute',
    bottom: ACTION_BUTTON_BOTTOM,
    right: ACTION_BUTTON_MARGIN,
    zIndex: 2,
  },
  actionButton: {
    backgroundColor: 'rgba(255,255,255,0.14)',
    borderRadius: 8,
    width: 45,
    height: 31,
    alignItems: 'center',
    justifyContent: 'center',
  },
  actionButtonImage: {
    tintColor: 'white',
  },
  camera: {
    flex: 1,
    zIndex: 0,
  },
  video: {
    position: 'absolute',
    zIndex: 0.5,
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
  },
  controls: {
    position: 'absolute',
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'transparent',
    zIndex: 1,
  },
  startStopButtonContainer: {
    width: 80,
    height: 80,
    borderColor: 'white',
    borderWidth: 4,
    borderRadius: 80 * 0.5,
    justifyContent: 'center',
    alignItems: 'center',
  },
  startButton: {
    backgroundColor: 'rgba(235,15,33,1)',
    height: 64,
    width: 64,
    borderRadius: 64 * 0.5,
  },
  stopButton: {
    backgroundColor: 'rgba(235,15,33,0.2)',
    width: 32,
    height: 32,
  },
  loading: {
    position: 'absolute',
    zIndex: 1,
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    backgroundColor: 'rgba(0,0,0,0.6)',
    alignItems: 'center',
    justifyContent: 'center',
  },
})
