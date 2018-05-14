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
  Image,
  StyleSheet,
  Text,
  ActionSheetIOS,
  ActivityIndicator,
  TouchableHighlight,
  SafeAreaView,
  Clipboard,
} from 'react-native'
import {
  downloadFile,
  CachesDirectoryPath,
  stopDownload,
  exists,
} from 'react-native-fs'
import i18n from 'format-message'

import api from '../../canvas-api'
import Screen from '../../routing/Screen'
import Colors from '../../common/colors'
import Images from '../../images'
import Navigator from '../../routing/Navigator'
import Video from '../../common/components/Video'
import { isTeacher } from '../app'
import CanvasWebView from '../../common/components/CanvasWebView'
import { alertError } from '../../redux/middleware/error-handler'
import ModalOverlay from '../../common/components/ModalOverlay'

type Props = {
  context?: CanvasContext,
  contextID?: string,
  fileID: string,
  file: ?File,
  navigator: Navigator,
  onChange?: (File) => any,
  getCourse: typeof api.getCourse,
  getFile: typeof api.getFile,
}

type State = {
  width: number,
  height: number,
  jobID: ?number,
  localPath: ?string,
  file: ?File,
  loadingDone: boolean,
  course: ?Course,
  error: ?string,
  forcedRefresh: boolean, // If there is a failure we'll do a single retry
  showCopied: boolean,
}

export default class ViewFile extends Component<Props, State> {
  modalTimeout: ?TimeoutID

  static defaultProps = {
    getCourse: api.getCourse,
    getFile: api.getFile,
  }

  state = {
    course: null,
    width: 0,
    height: 0,
    jobID: null,
    localPath: null,
    file: this.props.file,
    loadingDone: false,
    error: null,
    forcedRefresh: false,
    showCopied: false,
  }

  componentWillMount () {
    this.fetchCourse()
    if (this.state.file) {
      this.fetchFile(this.state.file)
    } else {
      this.getFileDetails()
    }
  }

  getFileDetails = async () => {
    try {
      let { data } = await this.props.getFile(this.props.fileID)
      this.setState({ file: data })
      this.fetchFile(data)
    } catch (err) {
      this.setState({ loadingDone: true, error: i18n('There was an error loading the file.') })
    }
  }

  fetchFile = async (file: File, forceRefresh?: boolean) => {
    if ([ 'zip', 'flash' ].includes(file.mime_class)) {
      this.setState({ loadingDone: true })
      return
    }

    const toFile = `${CachesDirectoryPath}/file-${file.id}.${file.filename.split('.').pop()}`

    let fileExists = await exists(toFile)
    if (fileExists && !forceRefresh) {
      this.setState({ loadingDone: true, jobID: null, localPath: `file://${toFile}`, error: null })
      return
    }

    let { jobId: jobID, promise } = downloadFile({ fromUrl: file.url, toFile })
    this.setState({ jobID })
    let statusCode
    try {
      statusCode = (await promise).statusCode
    } catch (e) {}
    if (statusCode === 200) {
      this.setState({ loadingDone: true, jobID: null, localPath: `file://${toFile}`, error: null })
    } else {
      this.setState({ loadingDone: true, jobID: null, localPath: null, error: i18n('There was an error loading the file.') })
    }
  }

  fetchCourse = async () => {
    const { context, contextID } = this.props
    if (!context || !contextID) return
    if (context !== 'courses') return
    try {
      const course = (await this.props.getCourse(contextID)).data
      this.setState({ course })
    } catch (e) {
      // just don't show the course title
    }
  }

  handleLayout = (event: any) => {
    const { width, height } = event.nativeEvent.layout
    if (height !== 0 && width !== this.state.width && height !== this.state.height) {
      this.setState({ width, height })
    }
  }

  handleError = () => {
    const file = this.state.file
    if (this.state.forcedRefresh || !file) {
      this.setState({
        jobID: null,
        error: i18n('There was an error loading the file.'),
        loadingDone: true,
      })
      return
    }

    if (file) {
      this.setState({ forcedRefresh: true, loadingDone: false })
      this.fetchFile(file, true)
    }
  }

  componentWillUnmount () {
    if (this.state.jobID) stopDownload(this.state.jobID)
    if (this.modalTimeout) {
      clearTimeout(this.modalTimeout)
    }
  }

  handleDone = async () => {
    await this.props.navigator.dismiss()
    if (this.props.onChange && this.state.file && this.state.file !== this.props.file) {
      this.props.onChange(this.state.file)
    }
  }

  canEdit = (): boolean => {
    if (this.props.context === 'users') return true
    return isTeacher()
  }

  handleEdit = () => {
    const { context, contextID } = this.props
    if (!context || !contextID) return
    this.props.navigator.show(`/${context}/${contextID}/files/${this.props.fileID}/edit`, { modal: true }, {
      courseID: contextID,
      file: this.state.file,
      onChange: this.handleChange,
      onDelete: this.handleDelete,
    })
  }

  handleChange = (file: File) => {
    this.setState({ file })
  }

  handleDelete = async () => {
    if (this.props.isModal) {
      await this.props.navigator.dismiss()
    } else {
      await this.props.navigator.pop()
    }
    if (this.props.onChange && this.state.file) this.props.onChange(this.state.file)
  }

  handleShare = () => {
    if (this.state.localPath) {
      ActionSheetIOS.showShareActionSheetWithOptions({ url: this.state.localPath }, (error: Error) => {
        alertError(error)
      }, (success: boolean, method: string) => {
      })
    }
  }

  copyURL = () => {
    if (this.props.file) {
      Clipboard.setString(this.props.file.url.split('?')[0])
      this.setState({ showCopied: true })
      this.modalTimeout = setTimeout(() => {
        this.setState({ showCopied: false })
      }, 1000)
    }
  }

  renderPreview () {
    const { file } = this.state
    const { error, localPath, width } = this.state

    if (error) {
      return (
        <View style={styles.centeredContainer}>
          <Text style={styles.errorText}>{error}</Text>
        </View>
      )
    }
    let mimeClass = file && file.mime_class
    if (file && file['content-type'].includes('audio')) {
      mimeClass = 'audio'
    }
    switch (mimeClass) {
      case 'image':
        return (
          <View style={styles.imageContainer}>
            <Image
              source={{ uri: localPath }}
              resizeMode='contain'
              style={styles.image}
              onError={this.handleError}
              testID='view-file.image'
            />
          </View>
        )
      case 'audio':
      case 'video':
        return (
          <View style={styles.centeredContainer}>
            <Video
              source={{ uri: localPath || '' }}
              style={{ width, height: Math.ceil(width * 9.0 / 16.0) }}
            />
          </View>
        )
      case 'zip':
      case 'flash':
        return (
          <View style={styles.centeredContainer}>
            <Text style={{ textAlign: 'center', color: Colors.darkText, fontSize: 14 }}>
              {i18n('Previewing this file type is not supported')}
            </Text>
          </View>
        )
      default:
        return (
          <CanvasWebView
            source={{ uri: localPath }}
            style={styles.document}
            onError={this.handleError}
            navigator={this.props.navigator}
          />
        )
    }
  }

  render () {
    const { course, file, loadingDone } = this.state
    // $FlowFixMe
    const name: string = file ? file.name || file.display_name : ''
    const rightBarButtons = []
    if (this.canEdit()) {
      rightBarButtons.push({
        testID: 'view-file.edit-btn',
        title: i18n('Edit'),
        action: this.handleEdit,
      })
    }
    return (
      <Screen
        title={name}
        navBarStyle={this.props.navigator.isModal ? 'light' : 'dark'}
        subtitle={course && course.name || undefined}
        drawUnderNavBar
        disableGlobalSafeArea
        rightBarButtons={rightBarButtons}
        leftBarButtons={this.props.navigator.isModal && [{
          testID: 'view-file.done-btn',
          title: i18n('Done'),
          style: 'done',
          action: this.handleDone,
        }]}
        showDismissButton={false}
      >
        <View style={styles.container} onLayout={this.handleLayout}>
          <ModalOverlay
            text={i18n('Copied!')}
            visible={this.state.showCopied}
            showActivityIndicator={false}
          />
          {!loadingDone ? (
            <View style={styles.centeredContainer}>
              <ActivityIndicator />
            </View>
          ) : (
            this.renderPreview()
          )}
          <SafeAreaView style={styles.bottomToolbar}>
            <TouchableHighlight
              onPress={this.handleShare}
              style={styles.toolbarButton}
              underlayColor='transparent'
              accessibilityTraits='button'
              testID='view-file.share-btn'
              accessibilityLabel={i18n('Share')}
            >
              <Image source={Images.share} style={styles.toolbarIcon} />
            </TouchableHighlight>
            <TouchableHighlight
              onPress={this.copyURL}
              style={styles.toolbarButton}
              underlayColor='transparent'
              accessibilityTraits='button'
              testID='view-file.copy-btn'
              accessibilityLabel={i18n('Copy Link')}
            >
              <Image source={Images.rce.link} style={styles.toolbarIcon} />
            </TouchableHighlight>
          </SafeAreaView>
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
    backgroundColor: '#fff',
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
  bottomToolbar: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: Colors.grey3,
    backgroundColor: Colors.grey1,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  toolbarButton: {
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
    paddingTop: 10,
    paddingBottom: 10,
  },
  toolbarIcon: {
    tintColor: Colors.link,
    width: 24,
    height: 24,
    resizeMode: 'contain',
  },
})
