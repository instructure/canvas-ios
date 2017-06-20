/**
 * @flow
 */

import React, { Component } from 'react'
import {
  View,
  WebView,
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

type Props = {
  attachment: Attachment,
  style?: any,
  navigator: Navigator,
}

export default class AttachmentView extends Component<any, Props, any> {
  state = {
    size: { width: 0, height: 0 },
    filePath: null,
  }

  componentDidMount () {
    const path = `${CachesDirectoryPath}/${this.props.attachment.display_name}`
    let { jobId, promise } = downloadFile({
      fromUrl: this.props.attachment.url,
      toFile: path,
    })
    this.setState({ jobID: jobId, downloadPromise: promise })
    promise.then((r) => {
      console.log('Done downloading file', path, r.statusCode)
      this.setState({ jobID: null, filePath: r.statusCode === 200 ? `file://${path}` : null })
    })
  }

  handleLayout = (event: any) => {
    console.log('onLayout', event)
    const { width, height } = event.nativeEvent.layout
    if (height !== 0 && width !== this.state.size.width && height !== this.state.size.height) {
      this.setState({ size: { width, height } })
    }
  }

  componentWillUnmount () {
    if (this.state.jobID) {
      stopDownload(this.state.jobID)
    }
  }

  done = () => {
    this.props.navigator.dismiss()
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
    console.log(this.state.size)
    let body = <View></View>
    switch (this.props.attachment.mime_class) {
      case 'image':
        body = <View style={styles.imageContainer}>
          <Image source={{ uri: this.state.filePath }} resizeMode='contain' style={styles.image} />
        </View>
        break
      case 'video':
        body = <View style={styles.centeredContainer} onLayout={this.handleLayout}>
          <Video
            source={{ uri: this.state.filePath }}
            style={{ width: this.state.size.width, height: Math.ceil(this.state.size.width * 9.0 / 16.0) }}
          />
        </View>
        break
      case 'zip':
      case 'flash':
        body = <View style={styles.centeredContainer}>
          <Text style={{ textAlign: 'center', color: Colors.darkText, fontSize: 14 }}>{i18n('Previewing this file type is not supported')}</Text>
        </View>
        break
      default:
        body = <WebView source={{ uri: this.state.filePath }} style={styles.document} />
        break
    }
    return body
  }

  render () {
    return (
      <Screen
        title={i18n('Attachment')}
        navBarStyle='light'
        navBarTitleColors={Colors.darkText}
        navBarButtonColor={Colors.link}
        drawUnderNavBar={true}
        leftBarButtons={[{
          testID: 'attachment-view.done-btn',
          title: i18n('Done'),
          style: 'done',
          action: this.done,
        }]}
        rightBarButtons={[{
          testID: 'attachment-view.share-btn',
          image: Images.share,
          action: this.share,
        }]}
      >
        <View style={styles.container}>
          { this.state.filePath === null &&
            <View style={styles.centeredContainer}>
              <ActivityIndicator />
            </View>
          }
          { this.state.filePath !== null &&
            this.renderBody()
          }
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
})
