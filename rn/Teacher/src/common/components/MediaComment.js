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
  AlertIOS,
  ActivityIndicator,
  StyleSheet,
  View,
} from 'react-native'
import { connect } from 'react-redux'
import AudioRecorder from './AudioRecorder'
import VideoRecorder from './VideoRecorder'
import { uploadMedia } from '../../canvas-api'
import i18n from 'format-message'

export type Media = {
  fileName: string,
  filePath: string,
  mediaID: string,
  mediaType: string,
}

export type Props = {
  onFinishedUploading: (media: Media) => void,
  onCancel: () => void,
  mediaType: 'audio' | 'video',
  uploadMedia: typeof uploadMedia,
}

export class MediaComment extends Component<Props, any> {
  audioRecorder: ?AudioRecorder
  videoRecorder: ?VideoRecorder

  constructor (props: Props) {
    super(props)

    this.state = {
      uploading: false,
    }
  }

  upload = async (recording: Recording) => {
    this.setState({ uploading: true })
    const { fileName, filePath } = recording
    const { mediaType } = this.props
    try {
      const mediaID = await this.props.uploadMedia(filePath, mediaType)
      this.setState({ uploading: false })
      this.props.onFinishedUploading({ fileName, filePath, mediaID, mediaType })
    } catch (e) {
      this.setState({ uploading: false })
      AlertIOS.alert(i18n('Failed to upload media comment'))
    }
  }

  captureAudioRecorder = (ref: ?AudioRecorder) => {
    this.audioRecorder = ref
  }

  captureVideoRecorder = (ref: ?VideoRecorder) => {
    this.videoRecorder = ref
  }

  render () {
    return (
      <View style={{ flex: 1 }}>
        { this.props.mediaType === 'audio' && this.renderAudio() }
        { this.props.mediaType === 'video' && this.renderVideo() }
        { this.state.uploading &&
          <View style={style.activityIndicator}>
            <ActivityIndicator animating={true} />
          </View>
        }
      </View>
    )
  }

  renderAudio () {
    return (
      <AudioRecorder
        onFinishedRecording={this.upload}
        onCancel={this.props.onCancel}
        ref={this.captureAudioRecorder}
        doneButtonText={i18n('Send')}
      />
    )
  }

  renderVideo () {
    return (
      <VideoRecorder
        onFinishedRecording={recording => { this.upload(recording) }}
        onCancel={this.props.onCancel}
        ref={this.captureVideoRecorder}
        doneButtonText={i18n('Send')}
      />
    )
  }
}

const style = StyleSheet.create({
  activityIndicator: {
    position: 'absolute',
    justifyContent: 'center',
    alignItems: 'center',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'rgba(0,0,0,0.7)',
  },
})

const mergeProps = (stateProps, dispatchProps, ownProps) => ({
  ...stateProps,
  ...dispatchProps,
  ...ownProps,
  uploadMedia,
})

const Connected = connect(
  null,
  null,
  mergeProps,
)(MediaComment)

export default (Connected: any)
