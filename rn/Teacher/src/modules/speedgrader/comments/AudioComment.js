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
  Image,
  TouchableHighlight,
  Alert,
  ActivityIndicator,
} from 'react-native'
import { connect } from 'react-redux'
import {
  downloadFile,
  TemporaryDirectoryPath,
  stopDownload,
} from 'react-native-fs'
import Images from '../../../images'
import { Text } from '../../../common/text'
import { createStyleSheet } from '../../../common/stylesheet'
import i18n from 'format-message'
import Sound from 'react-native-sound'
import OnLayout from 'react-native-on-layout'

export type Props = {
  from: 'me' | 'them',
  url: ?string,
  downloadAudio: (uri: string, capture: Function) => Promise<string>,
  stopDownload: (id: number) => void,
  loadAudio: (path: string) => Promise<Sound>,
}

export class AudioComment extends Component<Props, any> {
  playbackInterval: IntervalID

  constructor (props: Props) {
    super(props)

    this.state = {
      audio: null,
      downloadJobID: null,
      downloading: false,
      playing: false,
      currentTime: 0,
    }
  }

  componentWillUnmount () {
    this.state.downloadJobID && this.props.stopDownload(this.state.downloadJobID)
  }

  render () {
    const them = this.props.from === 'them'
    const justifyContent = this.state.playing || them ? 'flex-start' : 'flex-end'

    if (this.state.downloading) {
      return (
        <View
          style={[style.container, { justifyContent }]}
        >
          <ActivityIndicator animating={true} />
        </View>
      )
    }

    const duration = this.state.audio ? this.state.audio.getDuration() : 0
    const location = duration > 0 ? this.state.currentTime / duration : 0

    return (
      <View
        style={[style.container, { justifyContent }]}
      >
        { !this.state.playing &&
          <TouchableHighlight
            testID='audio-comment.label'
            onPress={this.props.url ? this.startPlaying : undefined}
            style={style.startPlayingButton}
            accessibilityTraits='button'
            accessibilityLabel={i18n('Audio Comment')}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
              <Image
                source={Images.speedGrader.submissions.audio}
                style={style.icon}
                resizeMode='contain'
              />
              <Text style={style.text}>{i18n('Audio Comment')}</Text>
            </View>
          </TouchableHighlight>
        }
        { this.state.playing &&
          <View style={{ flex: 1, flexDirection: 'row', alignItems: 'center' }}>
            <Image
              source={Images.speedGrader.submissions.audio}
              style={style.icon}
              resizeMode='contain'
            />
            <View style={style.playback} testID='audio-comment.player'>
              <OnLayout style={{ flex: 1 }}>
                {({ width }) => (
                  <View style={style.duration}>
                    <View style={style.scrubLine}>
                    </View>
                    <View style={[style.scrubber, { left: (width * location) - 1 }]}>
                    </View>
                  </View>
                )}
              </OnLayout>
              <TouchableHighlight
                onPress={this.stopPlaying}
                testID='audio-comment.stop-btn'
                accessibilityLabel={i18n('Stop playing audio')}
                accessibilityTraits='button'
              >
                <View style={style.stopContainer}>
                  <View style={style.stop}>
                  </View>
                </View>
              </TouchableHighlight>
            </View>
          </View>
        }
      </View>
    )
  }

  startPlaying = async () => {
    const audio = this.state.audio || await this.downloadAudio()
    audio && this.play(audio)
  }

  stopPlaying = () => {
    this.playbackInterval && clearInterval(this.playbackInterval)
    this.state.audio && this.state.audio.stop()
    this.setState({ playing: false })
  }

  async downloadAudio (): Promise<?Sound> {
    let sound
    this.setState({ downloading: true })
    try {
      const path = this.props.url && await this.props.downloadAudio(this.props.url, this.captureDownloadJob)
      sound = path && await this.props.loadAudio(path)
    } catch (error) {
      Alert.alert(i18n('Failed to load audio'))
    }

    this.setState({
      downloading: false,
      downloadJobID: null,
    })

    return sound
  }

  play (audio: Sound) {
    this.setState({
      audio,
      playing: true,
      currentTime: 0,
    })

    // get currentTime on an interval to move scrubber
    this.playbackInterval = setInterval(() => {
      audio.getCurrentTime((currentTime) => {
        this.setState({ currentTime })
      })
    }, 50)

    audio.play((success) => {
      this.setState({ playing: false })
      if (!success) {
        Alert.alert(i18n('Audio playback failed'))
        this.setState({ audio: null })
        clearInterval(this.playbackInterval)
      }
    })
  }

  captureDownloadJob = (downloadJobID: number) => {
    this.setState({ downloadJobID })
  }
}

/* istanbul ignore next */
async function downloadAudio (url: string, captureJob: (number) => void): Promise<string> {
  const fileName = `${new Date().valueOf()}.mp4`
  const path = `${TemporaryDirectoryPath}/${fileName}`
  let { jobId, promise } = downloadFile({
    fromUrl: url,
    toFile: path,
  })
  captureJob(jobId)
  const response = await promise
  if (response.statusCode !== 200) {
    throw new Error(i18n('Failed to download audio'))
  }
  return path
}

/* istanbul ignore next */
function loadAudio (path: string): Promise<Sound> {
  return new Promise((resolve, reject) => {
    const audio = new Sound(path, '', (error) => {
      if (error) {
        reject(error)
      } else {
        resolve(audio)
      }
    })
  })
}

const style = createStyleSheet(colors => ({
  container: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
  },
  icon: {
    tintColor: colors.textDark,
    width: 18,
    height: 18,
    marginRight: 6,
  },
  text: {
    color: colors.textDark,
    fontSize: 14,
    fontWeight: '400',
  },
  playback: {
    flex: 1,
    flexDirection: 'row',
  },
  duration: {
    flex: 1,
    justifyContent: 'center',
  },
  scrubLine: {
    flex: 1,
    maxHeight: 5,
    backgroundColor: colors.backgroundLight,
  },
  scrubber: {
    position: 'absolute',
    top: 2,
    bottom: 2,
    width: 3,
    backgroundColor: colors.primary,
    borderRadius: 1,
  },
  stopContainer: {
    width: 25,
    height: 25,
    borderRadius: 12.5,
    borderColor: colors.borderMedium,
    borderWidth: 2,
    marginLeft: 8,
  },
  stop: {
    flex: 1,
    margin: 6,
    backgroundColor: colors.textDanger,
  },
  startPlayingButton: {
    paddingHorizontal: 6,
    paddingVertical: 3,
    borderWidth: 1,
    borderColor: colors.borderDark,
    borderRadius: 3,
  },
}))

const mergeProps = (stateProps, dispatchProps, ownProps) => ({
  ...stateProps,
  ...dispatchProps,
  ...ownProps,
  downloadAudio,
  stopDownload,
  loadAudio,
})

const Connected = connect(
  null,
  null,
  mergeProps,
)(AudioComment)

export default (Connected: any)
