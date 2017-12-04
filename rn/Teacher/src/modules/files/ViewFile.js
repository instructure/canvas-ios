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
  WebView,
  Image,
  StyleSheet,
  Text,
  ActionSheetIOS,
  ActivityIndicator,
  TouchableHighlight,
  SafeAreaView,
} from 'react-native'
import {
  downloadFile,
  CachesDirectoryPath,
  stopDownload,
} from 'react-native-fs'
import i18n from 'format-message'

import api from '../../canvas-api'
import Screen from '../../routing/Screen'
import Colors from '../../common/colors'
import Images from '../../images'
import Navigator from '../../routing/Navigator'
import Video from '../../common/components/Video'

type Props = {
  courseID?: string,
  fileID: string,
  file: File,
  navigator: Navigator,
  onChange?: (File) => any,
  getCourse: typeof api.getCourse,
}

type State = {
  width: number,
  height: number,
  jobID: ?string,
  localPath: ?string,
  updated: File,
  course: ?Course,
}

export default class ViewFile extends Component<Props, State> {
  static defaultProps = {
    getCourse: api.getCourse,
  }

  state = {
    course: null,
    width: 0,
    height: 0,
    jobID: null,
    localPath: null,
    updated: this.props.file,
  }

  componentWillMount () {
    this.fetchCourse()
    this.fetchFile()
  }

  fetchFile = async () => {
    const { file } = this.props
    if ([ 'zip', 'flash' ].includes(file.mime_class)) return
    const toFile = `${CachesDirectoryPath}/file-${file.id}.${file.filename.split('.').pop()}`
    let { jobId: jobID, promise } = downloadFile({ fromUrl: file.url, toFile })
    this.setState({ jobID })
    const { statusCode } = await promise
    if (statusCode === 200) {
      this.setState({ jobID: null, localPath: `file://${toFile}`, error: null })
    } else {
      this.setState({ jobID: null, localPath: null, error: i18n('There was an error loading the file.') })
    }
  }

  fetchCourse = async () => {
    if (!this.props.courseID) return
    try {
      const course = (await this.props.getCourse(this.props.courseID)).data
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

  handleError = () => this.setState({
    jobID: null,
    error: i18n('There was an error loading the file.'),
  })

  componentWillUnmount () {
    if (this.state.jobID) stopDownload(this.state.jobID)
  }

  handleDone = async () => {
    await this.props.navigator.dismiss()
    if (this.props.onChange && this.state.updated !== this.props.file) {
      this.props.onChange(this.state.updated)
    }
  }

  handleEdit = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/file/${this.props.fileID}/edit`, { modal: true }, {
      courseID: this.props.courseID,
      file: this.state.updated,
      onChange: this.handleChange,
      onDelete: this.handleDelete,
    })
  }

  handleChange = (updated: File) => {
    this.setState({ updated })
  }

  handleDelete = async () => {
    await this.props.navigator.dismiss()
    if (this.props.onChange) this.props.onChange(this.state.updated)
  }

  handleShare = () => {
    if (this.state.localPath) {
      ActionSheetIOS.showShareActionSheetWithOptions({ url: this.state.localPath }, (error: Error) => {
        console.log('Failed showing share sheet', error)
      }, (success: boolean, method: string) => {
        console.log('Successfully shared file', method)
      })
    }
  }

  renderPreview () {
    const { file } = this.props
    const { error, localPath, width } = this.state
    if (error) {
      return (
        <View style={styles.centeredContainer}>
          <Text style={styles.errorText}>{error}</Text>
        </View>
      )
    }
    switch (file.mime_class) {
      case 'image':
        return (
          <View style={styles.imageContainer}>
            <Image source={{ uri: localPath }} resizeMode='contain' style={styles.image} onError={this.handleError} />
          </View>
        )
      case 'audio':
      case 'video':
        return (
          <View style={styles.centeredContainer} onLayout={this.handleLayout}>
            <Video
              source={{ uri: localPath }}
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
          <WebView source={{ uri: localPath }} style={styles.document} />
        )
    }
  }

  render () {
    const { course, updated, jobID } = this.state
    return (
      <Screen
        title={updated.name || updated.display_name}
        subtitle={course && course.name}
        navBarStyle='light'
        navBarTitleColor={Colors.darkText}
        navBarButtonColor={Colors.link}
        drawUnderNavBar={true}
        disableGlobalSafeArea
        leftBarButtons={[{
          testID: 'view-file.edit-btn',
          title: i18n('Edit'),
          action: this.handleEdit,
        }]}
        rightBarButtons={[{
          testID: 'view-file.done-btn',
          title: i18n('Done'),
          style: 'done',
          action: this.handleDone,
        }]}
      >
        <View style={styles.container}>
          {jobID != null ? (
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
            >
              <Image source={Images.share} style={styles.toolbarIcon} />
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
