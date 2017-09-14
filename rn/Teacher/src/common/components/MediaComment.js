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
import { uploadMedia } from 'instructure-canvas-api'
import i18n from 'format-message'

export type Media = {
  fileName: string,
  filePath: string,
  mediaID: string,
  mediaType: string,
}

type OwnProps = {
  onFinishedUploading: (media: Media) => void,
  onCancel: () => void,
  mediaType: 'audio' | 'video',
}

export type Props = OwnProps & {
  uploadMedia: (string) => Promise<string>,
}

export class MediaComment extends Component<any, Props, any> {
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
        onFinishedRecording={this.upload}
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
