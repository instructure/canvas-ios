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
  FlatList,
  StyleSheet,
  ActionSheetIOS,
  AlertIOS,
  LayoutAnimation,
} from 'react-native'

import { connect } from 'react-redux'
import Actions from './actions'
import i18n from 'format-message'
import Screen from '../../routing/Screen'
import { alertError } from '../../redux/middleware/error-handler'
import canvas from '../../canvas-api'
import Row from '../../common/components/rows/Row'
import RowSeparator from '../../common/components/rows/RowSeparator'
import find from 'lodash/find'
import localeSort from '../../utils/locale-sort'
import AccessIcon from '../../common/components/AccessIcon'
import ListEmptyComponent from '../../common/components/ListEmptyComponent'
import images from '../../images'
import bytes from 'bytes'
import DropView from '../../common/components/DropView'
import SavingBanner from '../../common/components/SavingBanner'
import AttachmentPicker from '../attachments/AttachmentPicker'
import uuid from 'uuid/v1'
import { wait } from '../../utils/async-wait'

type CourseFilesListProps = {
  data: [any], // The folders and files that are currently being shown
  folder: Folder, // The folder that is currently being displayed
  courseColor: ?string, // Color of the course in this files list
}

type CourseFileListNavProps = {
  courseID: string,
  subFolder?: ?string,
}

type Props = CourseFilesListProps & CourseFileListNavProps & NavigationProps

type State = {
  pending: boolean,
  uploadPending: boolean,
  uploadMessage: ?string,
}

export class CourseFilesList extends Component<Props, State> {

  attachmentPicker: AttachmentPicker

  state = {
    pending: false,
    uploadPending: false,
    uploadMessage: null,
  }

  componentWillMount () {
    this.update()
  }

  dismiss = () => {
    this.props.navigator.dismiss()
  }

  update = async () => {
    this.setState({ pending: true })
    try {
      const courseID = this.props.courseID
      let folder = this.props.folder
      if (!folder) {
        folder = (await this.props.getCourseFolder(courseID, 'root')).data
        this.props.foldersUpdated([folder], 'root', courseID, 'Course')
      }
      const foldersPromise = this.props.getFolderFolders(folder.id)
      const filesPromise = this.props.getFolderFiles(folder.id)
      const folderPromise = this.props.getFolder(folder.id)
      this.props.foldersUpdated((await foldersPromise).data, folder.full_name, courseID, 'Course')
      this.props.filesUpdated((await filesPromise).data, folder.full_name, courseID, 'Course')
      this.props.folderUpdated((await folderPromise).data, courseID, 'Course')
    } catch (error) {
      alertError(error)
    }
    this.setState({ pending: false })
  }

  onSelectRow = (index: number) => {
    const item = this.props.data[index]

    if (item.type === 'file') {
      this.props.navigator.show(`/courses/${this.props.courseID}/file/${item.id}`, { modal: true }, {
        file: item,
        onChange: this.update,
      })
    } else {
      let route
      if (this.props.subFolder) {
        route = `/courses/${this.props.courseID}/files/folder/${this.props.subFolder}/${item.name}`
      } else {
        route = `/courses/${this.props.courseID}/files/folder/${item.name}`
      }
      this.props.navigator.show(route)
    }
  }

  handleEditFolder = () => {
    const { folder } = this.props
    this.props.navigator.show(`/folders/${folder.id}/edit`, { modal: true }, {
      folder,
      onChange: this.handleChangeFolder,
      onDelete: this.handleDeleteFolder,
    })
  }

  handleChangeFolder = async (updated: Folder) => {
    const { folder, courseID, subFolder } = this.props
    if (folder.name !== updated.name) {
      let prefix = (subFolder || '').split('/').slice(0, -1).join('/')
      if (prefix) prefix += '/'
      await this.update() // make sure the new folder name is loaded before routing to it
      this.props.navigator.replace(
        `/courses/${courseID}/files/folder/${prefix}${updated.name}`
      )
    } else {
      this.update()
    }
  }

  handleDeleteFolder = () => {
    this.props.navigator.pop()
  }

  addItem = () => {
    const options = [
      i18n('Create Folder'),
      i18n('Add File'),
      i18n('Cancel'),
    ]
    ActionSheetIOS.showActionSheetWithOptions(
      {
        options,
        cancelButtonIndex: options.length - 1,
      },
      this.handleAddItem
    )
  }

  handleAddItem = (index: number) => {
    switch (index) {
      case 0:
        this.promptForNewFolder()
        break
      case 1:
        this.addFile()
        break
    }
  }

  promptForNewFolder = () => {
    AlertIOS.prompt(
      i18n('Create Folder'),
      null,
      this.createNewFolder,
    )
  }

  createNewFolder = async (name: string) => {
    LayoutAnimation.easeInEaseOut()
    this.setState({ uploadPending: true })
    try {
      const folder: NewFolder = {
        name,
        parent_folder_id: this.props.folder.id,
        locked: true,
      }
      await this.props.createFolder(this.props.courseID, folder)
      await this.update()
    } catch (error) {
      alertError(error)
    }
    LayoutAnimation.easeInEaseOut()
    this.setState({ uploadPending: false, uploadMessage: null })
  }

  addFile = () => {
    this.attachmentPicker.show(null, this.finishAddFile)
  }

  finishAddFile = async (attachment: Attachment, type: MediaType) => {
    if (type === 'audio') {
      // RN Modal component is bugged. :(
      // If state is updated before it goes away, it comes back like it's all mad or something.
      // If we wait a bit, and then update state, it's all good

      // This can be removed if we stop using the <Modal> component
      await wait(500)
    }
    LayoutAnimation.easeInEaseOut()
    this.setState({ uploadPending: true, uploadMessage: i18n('Uploading') })
    attachment.id = uuid()
    const path = `folders/${this.props.folder.id}/files`
    try {
      const file = await this.props.uploadFile(attachment, {
        path,
        onProgress: this.updateUploadProgress,
      })
      await this.props.updateFile(file.id, { locked: true })
      await this.update()
    } catch (error) {
      alertError(error)
    }
    LayoutAnimation.easeInEaseOut()
    this.setState({ uploadPending: false, uploadMessage: null })
  }

  updateUploadProgress = (progress: Progress) => {
    let amountUploaded = bytes(progress.loaded, { decimalPlaces: 0, unitSeparator: ';' })
    if (amountUploaded) {
      amountUploaded = amountUploaded.split(';')[0]
    }
    const amountTotal = bytes(progress.total, { decimalPlaces: 0 })
    if (amountUploaded && amountTotal) {
      const uploadMessage = i18n('Uploading {amountUploaded}/{amountTotal}', { amountUploaded, amountTotal })
      this.setState({ uploadMessage })
    }
  }

  captureAttachmentPicker = (ref: AttachmentPicker) => {
    this.attachmentPicker = ref
  }

  renderRow = ({ item, index }: any) => {
    let name
    let icon
    let subtitle
    let tintColor
    let statusOffset = {}
    if (item.type === 'file') {
      name = item.display_name
      icon = images.document
      subtitle = bytes(item.size)
      statusOffset = {
        top: 15,
        left: 25,
      }
    } else {
      name = item.name
      icon = images.files.folder
      subtitle = i18n(`{ 
        file_count, plural, 
          one {# file} 
          other {# files}
      }`, { file_count: item.files_count })
      tintColor = this.props.courseColor
      statusOffset.left = 26
    }
    const renderImage = () => {
      return <View style={styles.icon}>
               <AccessIcon entry={item} image={icon} tintColor={tintColor} statusOffset={statusOffset} />
             </View>
    }

    return (<View>
              <View style={styles.row}>
                <Row
                  renderImage={renderImage}
                  title={name}
                  subtitle={subtitle}
                  identifier={index}
                  onPress={this.onSelectRow}
                  disclosureIndicator
                  testID={`course-file-list.course-file-list-row.cell-${item.key}`} />
              </View>
              {(item.hidden || item.lock_at || item.unlock_at) ? (
                <View style={styles.restrictedIndicatorLine} />
              ) : (
                !item.locked && <View style={styles.publishedIndicatorLine} />
              )}
            </View>)
  }

  render () {
    const title = this.props.subFolder && this.props.folder
      ? this.props.folder.name
      : i18n('Files')
    const empty = <ListEmptyComponent title={i18n('This folder is empty.')} />

    const leftBarButtons = []
    if (this.props.navigator.isModal) {
      leftBarButtons.push({
        testID: 'course-files.modal.dismiss',
        action: this.dismiss,
        title: i18n('Done'),
      })
    }

    const rightBarButtons = []
    if (!this.state.uploadPending) {
      rightBarButtons.push({
        image: images.add,
        testID: 'course-files.add.button',
        action: this.addItem,
        accessibilityLabel: i18n('Add Item'),
      })
    }
    if (this.props.folder && this.props.subFolder) {
      rightBarButtons.push({
        testID: 'course-files.edit-folder.button',
        title: i18n('Edit'),
        action: this.handleEditFolder,
      })
    }
    return (
      <Screen
        title={title}
        navBarTitleColor={'#fff'}
        rightBarButtons={rightBarButtons}
        leftBarButtons={leftBarButtons}
      >
        <DropView style={{ flex: 1 }}>
          { this.state.uploadPending && <SavingBanner title={this.state.uploadMessage} /> }
          <FlatList
            data={this.props.data}
            renderItem={this.renderRow}
            onRefresh={this.update}
            refreshing={Boolean(this.state.pending) && !this.state.uploadPending}
            ItemSeparatorComponent={RowSeparator}
            ListHeaderComponent={this.props.data.length > 0 ? RowSeparator : null}
            ListFooterComponent={this.props.data.length > 0 ? RowSeparator : null}
            ListEmptyComponent={this.state.pending ? null : empty} />
            <AttachmentPicker
              style={styles.attachmentPicker}
              ref={this.captureAttachmentPicker}
            />
        </DropView>
      </Screen>
    )
  }
}

CourseFilesList.defaultProps = {
  getCourseFolder: canvas.getCourseFolder,
  getFolderFolders: canvas.getFolderFolders,
  getFolderFiles: canvas.getFolderFiles,
  getFolder: canvas.getFolder,
  createFolder: canvas.createFolder,
  uploadFile: canvas.uploadAttachment,
  updateFile: canvas.updateFile,
}

export function mapStateToProps (state: AppState, props: CourseFileListNavProps): CourseFilesListProps {
  let parentFolder
  const key = `Course-${props.courseID}`
  const courseFolders = state.folders[key] || {}
  const courseFiles = state.files[key] || {}
  const courseColor = (state.entities.courses[props.courseID] || {}).color
  if (!courseFolders['root'] || !courseFolders['root'][0]) {
    return { data: [], courseColor }
  }
  const rootFolder = courseFolders['root'][0]
  if (props.subFolder) {
    const fullPath = `${rootFolder.name}/${props.subFolder}`
    const parentPath = fullPath.substring(0, fullPath.lastIndexOf('/'))
    const possibleParents = courseFolders[parentPath]
    parentFolder = find(possibleParents, { full_name: fullPath })
  } else {
    parentFolder = rootFolder
  }

  if (!parentFolder) {
    return { data: [], courseColor }
  }

  const mapper = (type: string) => (item) => {
    return { ...item, type, key: `${type}-${item.id}` }
  }

  const folders = (courseFolders[parentFolder.full_name] || []).map(mapper('folder'))
  const files = (courseFiles[parentFolder.full_name] || []).map(mapper('file'))
  const data = [...folders, ...files].sort((a, b) => localeSort(a.name || a.display_name, b.name || b.display_name))

  return { data, folder: parentFolder, courseColor }
}

const styles = StyleSheet.create({
  row: {
    marginLeft: -10,
  },
  icon: {
    alignSelf: 'flex-start',
  },
  publishedIndicatorLine: {
    backgroundColor: '#00AC18',
    position: 'absolute',
    top: 4,
    bottom: 4,
    left: 0,
    width: 3,
  },
  restrictedIndicatorLine: {
    backgroundColor: '#FF0000',
    position: 'absolute',
    top: 4,
    bottom: 4,
    left: 0,
    width: 3,
  },
  attachmentPicker: {
    position: 'absolute',
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
  },
})

let Connected = connect(mapStateToProps, Actions)(CourseFilesList)
export default (Connected: Component<any, any>)
