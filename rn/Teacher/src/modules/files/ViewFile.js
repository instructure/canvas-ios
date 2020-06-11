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
  Text,
  ActionSheetIOS,
  ActivityIndicator,
  TouchableHighlight,
  SafeAreaView,
  Clipboard,
  NativeModules,
  AccessibilityInfo,
} from 'react-native'
import {
  downloadFile,
  TemporaryDirectoryPath,
  mkdir,
  stopDownload,
  exists,
} from 'react-native-fs'
import i18n from 'format-message'

import api from '../../canvas-api'
import Screen from '../../routing/Screen'
import { colors, createStyleSheet } from '../../common/stylesheet'
import Images from '../../images'
import icon from '../../images/inst-icons'
import Navigator from '../../routing/Navigator'
import Video from '../../common/components/Video'
import { isTeacher } from '../app'
import CanvasWebView from '../../common/components/CanvasWebView'
import { alertError } from '../../redux/middleware/error-handler'
import ModalOverlay from '../../common/components/ModalOverlay'
import { getSession } from '../../canvas-api/session'
import { Button } from '../../common/buttons'

const { QLPreviewManager } = NativeModules

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

    const directoryPath = `${TemporaryDirectoryPath}/file-${file.id}`
    await mkdir(directoryPath)
    const filename = decodeURIComponent(file.filename)
      .replace(/\?/g, '_').replace(/#/g, '_')
    const toFile = `${directoryPath}/${filename}`
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
      AccessibilityInfo.announceForAccessibility(i18n('Copied'))
      this.setState({ showCopied: true })
      this.modalTimeout = setTimeout(() => {
        this.setState({ showCopied: false })
      }, 1000)
    }
  }

  openInAR = () => {
    QLPreviewManager.previewFile(this.state.localPath)
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

    if (file && file.filename.split('.').pop() === 'usdz') {
      return (
        <View style={styles.centeredContainer}>
          <Button
            style={styles.augmentRealityButton}
            onPress={this.openInAR}
          >
            {i18n('Augment Reality')}
          </Button>
        </View>
      )
    }

    let mimeClass = file && file.mime_class
    if (file && file['content-type'].includes('audio')) {
      mimeClass = 'audio'
    } else if (file && file['content-type'] === 'image/heic') {
      mimeClass = 'image'
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
            <Text style={{ textAlign: 'center', color: colors.textDarkest, fontSize: 14 }}>
              {i18n('Previewing this file type is not supported')}
            </Text>
          </View>
        )
      case 'html':
        // some people use files as a web server to serve html content and
        // when they do they might include relative links to other files in the course
        // which won't work with the download url. We must build a preview url that will
        // redirect the webview to the server that serves file content in order for the
        // relative urls to function properly
        let { baseURL } = getSession()
        let url = baseURL
        if (this.props.context && this.props.contextID) {
          url += `/${this.props.context}/${this.props.contextID}`
        }
        url += `/files/${this.props.fileID}/preview`
        return (
          <CanvasWebView
            source={{ uri: url }}
            style={styles.document}
            onError={this.handleError}
            navigator={this.props.navigator}
          />
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
        navBarStyle={this.props.navigator.isModal ? 'modal' : 'context'}
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
              testID='FileDetails.shareButton'
              accessibilityLabel={i18n('Share')}
            >
              <Image source={Images.share} style={styles.toolbarIcon} />
            </TouchableHighlight>
            <TouchableHighlight
              onPress={this.copyURL}
              style={styles.toolbarButton}
              underlayColor='transparent'
              accessibilityTraits='button'
              testID='FileDetails.copyButton'
              accessibilityLabel={i18n('Copy Link')}
            >
              <Image source={icon('link')} style={styles.toolbarIcon} />
            </TouchableHighlight>
          </SafeAreaView>
        </View>
      </Screen>
    )
  }
}

const styles = createStyleSheet((colors, vars) => ({
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
    backgroundColor: colors.backgroundLightest,
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
    padding: vars.padding,
  },
  bottomToolbar: {
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
    backgroundColor: colors.backgroundLight,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  toolbarButton: {
    paddingLeft: vars.padding,
    paddingRight: vars.padding,
    paddingTop: 10,
    paddingBottom: 10,
  },
  toolbarIcon: {
    tintColor: colors.linkColor,
    width: 24,
    height: 24,
    resizeMode: 'contain',
  },
  augmentRealityButton: {
    paddingVertical: 8,
    paddingHorizontal: 24,
  },
}))
