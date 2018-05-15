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

/**
 * @flow
 */

import React, { Component } from 'react'
import {
  View,
  Image,
  StyleSheet,
  Text,
  ActionSheetIOS,
  ActivityIndicator,
} from 'react-native'
import {
  downloadFile,
  CachesDirectoryPath,
  stopDownload,
} from 'react-native-fs'
import i18n from 'format-message'

import Screen from '../../routing/Screen'
import Colors from '../colors'
import Images from '../../images'
import Navigator from '../../routing/Navigator'
import Video from './Video'
import md5 from 'md5'
import CanvasWebView from './CanvasWebView'

type Props = {
  attachment: Attachment,
  style?: any,
  navigator: Navigator,
}

type State = {
  size: { width: number, height: number },
  filePath: ?string,
  jobID?: ?number,
  error?: ?string,
  downloadPromise?: Promise<*>,
}

export default class AttachmentView extends Component<Props, State> {
  state: State = {
    size: { width: 0, height: 0 },
    filePath: null,
  }

  componentDidMount () {
    if (this.props.attachment.uri) {
      this.setState({ filePath: this.props.attachment.uri })
      return
    }
    this.fetchFile()
  }

  fetchFile = async () => {
    const fromUrl = this.props.attachment.url
    const filename = (this.props.attachment.filename || this.props.attachment.display_name)
    // filenames from canvas come back encoded, and RN doesn't like that. So i'm creating a new filename based of the url hash and extension. gross.
    const toFile = `${CachesDirectoryPath}/${md5(fromUrl)}.${filename.split('.').pop()}`
    let { jobId, promise } = downloadFile({ fromUrl, toFile })
    this.setState({ jobID: jobId, downloadPromise: promise })
    return promise.then((r) => {
      if (r.statusCode === 200) {
        this.setState({ jobID: null, filePath: `file://${toFile}`, error: null })
      } else {
        this.setState({ jobID: null, filePath: null, error: i18n('There was an error loading this attachment.') })
      }
    })
  }

  handleLayout = (event: any) => {
    const { width, height } = event.nativeEvent.layout
    if (height !== 0 && width !== this.state.size.width && height !== this.state.size.height) {
      this.setState({ size: { width, height } })
    }
  }

  onError = () => {
    this.setState({
      jobID: null,
      error: i18n('There was an error loading the attachment.'),
    })
  }

  componentWillUnmount () {
    if (this.state.jobID) {
      stopDownload(this.state.jobID)
    }
  }

  share = () => {
    if (this.state.filePath) {
      ActionSheetIOS.showShareActionSheetWithOptions({ url: this.state.filePath }, (error: Error) => {
        console.log('Failed showing share sheet', error)
      }, (success: boolean, method: string) => {
        console.log('Successfully shared file', method)
      })
    }
  }

  renderBody () {
    if (this.state.error) {
      return <View style={styles.centeredContainer}>
        <Text style={styles.errorText}>{this.state.error}</Text>
      </View>
    }
    let body = <View></View>
    switch (this.props.attachment.mime_class) {
      case 'image':
        body = <View style={styles.imageContainer}>
          <Image source={{ uri: this.state.filePath }} resizeMode='contain' style={styles.image} onError={this.onError} />
        </View>
        break
      case 'audio':
      case 'video':
        body = this.renderAudioVisual()
        break
      case 'zip':
      case 'flash':
        body = <View style={styles.centeredContainer}>
          <Text style={{ textAlign: 'center', color: Colors.darkText, fontSize: 14 }}>{i18n('Previewing this file type is not supported')}</Text>
        </View>
        break
      default:
        if (this.props.attachment['content-type'] && this.props.attachment['content-type'].indexOf('audio') !== -1) {
          body = this.renderAudioVisual()
        } else {
          body = (
            <CanvasWebView
              navigator={this.props.navigator}
              source={{ uri: this.state.filePath }}
              style={styles.document}
            />
          )
        }
    }
    return body
  }

  renderAudioVisual () {
    return (
      <View style={styles.centeredContainer}>
        <Video
          // $FlowFixMe
          source={{ uri: this.state.filePath }}
          style={{ width: this.state.size.width, height: Math.ceil(this.state.size.width * 9.0 / 16.0) }}
        />
      </View>
    )
  }

  render () {
    return (
      <Screen
        title={i18n('Attachment')}
        navBarTitleColors={Colors.darkText}
        navBarButtonColor={Colors.link}
        drawUnderNavBar
        rightBarButtons={[{
          testID: 'attachment-view.share-btn',
          image: Images.share,
          action: this.share,
        }]}
      >
        <View style={styles.container} onLayout={this.handleLayout}>
          { (this.state.filePath == null) &&
            <View style={styles.centeredContainer}>
              <ActivityIndicator />
            </View>
          }
          { this.state.filePath != null && this.renderBody() }
        </View>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  centeredContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  imageContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
    backgroundColor: Colors.grey1,
  },
  image: {
    top: 0,
    left: 0,
    bottom: 0,
    right: 0,
    position: 'absolute',
  },
  document: {
    flex: 1,
  },
  errorText: {
    padding: global.style.defaultPadding,
  },
})
