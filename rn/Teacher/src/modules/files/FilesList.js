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
import AccessLine from '../../common/components/AccessLine'
import ListEmptyComponent from '../../common/components/ListEmptyComponent'
import images from '../../images'
import bytes, { unitFor } from '../../utils/locale-bytes'
import DropView from '../../common/components/DropView'
import SavingBanner from '../../common/components/SavingBanner'
import AttachmentPicker from '../attachments/AttachmentPicker'
import uuid from 'uuid/v1'
import { wait } from '../../utils/async-wait'
import { isTeacher } from '../app'
import color from '../../common/colors'
import { isRegularDisplayMode } from '../../routing/utils'
import type { TraitCollection } from '../../routing/Navigator'

type FilesListProps = {
  data: any[], // The folders and files that are currently being shown
  folder: Folder, // The folder that is currently being displayed
  courseColor: ?string, // Color of the course in this files list
  customPageViewPath?: ?string,
}

type FileListNavProps = {
  contextID: string,
  context: 'courses' | 'groups' | 'users',
  subFolder?: ?string,
  canEdit: boolean,
  canAdd: boolean,
  canSelectFile: Function,
  onSelectFile: Function,
}

type Props =
  FilesListProps &
  FileListNavProps &
  NavigationProps & {
    updateFile: Function,
    uploadFile: Function,
    createFolder: Function,
    folderUpdated: Function,
    foldersUpdated: Function,
    filesUpdated: Function,
    getContextFolder: Function,
    getFolderFolders: Function,
    getFolderFiles: Function,
    getFolder: Function,
  }

type State = {
  pending: boolean,
  uploadPending: boolean,
  uploadMessage: ?string,
  selectedRowID: ?string,
  isRegularScreenDisplayMode: ?boolean,
}

export class FilesList extends Component<Props, State> {
  static defaultProps = {
    getContextFolder: canvas.getContextFolder,
    getFolderFolders: canvas.getFolderFolders,
    getFolderFiles: canvas.getFolderFiles,
    getFolder: canvas.getFolder,
    createFolder: canvas.createFolder,
    uploadFile: canvas.uploadAttachment,
    updateFile: canvas.updateFile,
    canEdit: true,
    canAdd: true,
    canSelectFile: () => true,
  }

  attachmentPicker: AttachmentPicker

  state = {
    pending: false,
    uploadPending: false,
    uploadMessage: null,
    selectedRowID: null,
    isRegularScreenDisplayMode: false,
  }

  componentWillMount () {
    this.onTraitCollectionChange()
    this.update()
  }

  update = async () => {
    this.setState({ pending: true })
    try {
      let { contextID, context, folder } = this.props
      if (!folder) {
        folder = (await this.props.getContextFolder(context, contextID, 'root')).data
        this.props.foldersUpdated([folder], 'root', contextID, context)
      }
      const foldersPromise = this.props.getFolderFolders(folder.id)
      const filesPromise = this.props.getFolderFiles(folder.id)
      const folderPromise = this.props.getFolder(folder.id)
      this.props.foldersUpdated((await foldersPromise).data, folder.full_name, contextID, context)
      this.props.filesUpdated((await filesPromise).data, folder.full_name, contextID, context)
      this.props.folderUpdated((await folderPromise).data, contextID, context)
    } catch (error) {
      alertError(error)
    }
    this.setState({ pending: false })
  }

  onTraitCollectionChange () {
    this.props.navigator.traitCollection((traits) => { this.traitCollectionDidChange(traits) })
  }

  traitCollectionDidChange (traits: TraitCollection) {
    this.setState({ isRegularScreenDisplayMode: isRegularDisplayMode(traits) })
  }

  canEdit = (): boolean => {
    if (!this.props.canEdit) return false
    // Root folders cannot be edited
    if (!this.props.subFolder) return false
    // If we were unable to find the folder, it can't be edited
    if (!this.props.folder) return false
    // Users are always allow to edit their files
    if (this.props.context === 'users') return true
    return isTeacher()
  }

  canAdd = (): boolean => {
    if (!this.props.canAdd) return false
    if (this.state.uploadPending) return false
    if (this.props.context === 'users') return true
    return isTeacher()
  }

  onSelectRow = (index: number) => {
    const item = this.props.data[index]
    const {
      contextID,
      context,
      onSelectFile,
      canSelectFile,
      canEdit,
      canAdd,
    } = this.props

    if (item.type === 'file') {
      this.setState({ selectedRowID: item.id })

      if (onSelectFile) {
        return onSelectFile(item)
      }
      this.props.navigator.show(`/${context}/${contextID}/files/${item.id}`, {}, {
        file: item,
        onChange: this.update,
      })
    } else {
      let route
      const name = encodeURIComponent(item.name)
      if (this.props.subFolder) {
        route = `/${context}/${contextID}/files/folder/${this.props.subFolder}/${name}`
      } else {
        route = `/${context}/${contextID}/files/folder/${name}`
      }
      this.props.navigator.show(route, { modal: false }, {
        onSelectFile,
        canSelectFile,
        canEdit,
        canAdd,
      })
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
    const { folder, contextID, context, subFolder } = this.props
    if (folder.name !== updated.name) {
      let prefix = (subFolder || '').split('/').slice(0, -1).join('/')
      if (prefix) prefix += '/'
      await this.update() // make sure the new folder name is loaded before routing to it
      this.props.navigator.replace(
        `/${context}/${contextID}/files/folder/${prefix}${updated.name}`
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
      // $FlowFixMe
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
      await this.props.createFolder(this.props.context, this.props.contextID, folder)
      await this.update()
    } catch (error) {
      alertError(error)
    }
    LayoutAnimation.easeInEaseOut()
    this.setState({ uploadPending: false, uploadMessage: null })
  }

  addFile = () => {
    // $FlowFixMe
    this.attachmentPicker.show(null, this.finishAddFile)
  }

  finishAddFile = async (attachment: Attachment, type: 'audio' | 'video') => {
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
      if (this.props.context !== 'users') {
        await this.props.updateFile(file.id, { locked: true })
      }
      await this.update()
    } catch (error) {
      alertError(error)
    }
    LayoutAnimation.easeInEaseOut()
    this.setState({ uploadPending: false, uploadMessage: null })
  }

  updateUploadProgress = (progress: { loaded: number, total: number }) => {
    let amountUploaded = bytes(progress.loaded, {
      style: 'integer',
      separator: ';',
      unit: unitFor(progress.total),
    })
    if (amountUploaded) {
      amountUploaded = amountUploaded.split(';')[0]
    }
    const amountTotal = bytes(progress.total, { style: 'integer' })
    if (amountUploaded && amountTotal) {
      const uploadMessage = i18n('Uploading {amountUploaded}/{amountTotal}', { amountUploaded, amountTotal })
      this.setState({ uploadMessage })
    }
  }

  captureAttachmentPicker = (ref: any) => {
    this.attachmentPicker = ref
  }

  isRowSelected (item: any): boolean {
    if (this.state && this.state.selectedRowID) {
      return Boolean(this.state.isRegularScreenDisplayMode) && this.state.selectedRowID === item.id
    }

    return false
  }

  renderRow = ({ item, index }: any) => {
    let name
    let icon
    let subtitle
    let tintColor = color.grey5
    let statusOffset = {}
    let selected = false
    if (item.type === 'file') {
      selected = this.isRowSelected(item)
      name = item.display_name
      switch (item.mime_class) {
        case 'image':
          icon = { uri: item.thumbnail_url }
          break
        case 'video':
          icon = images.files.media
          break
        default:
          icon = images.document
          break
      }
      subtitle = bytes(item.size)
    } else {
      name = item.name
      icon = images.files.folder
      subtitle = i18n(`{
        item_count, plural,
          one {# item}
          other {# items}
      }`, { item_count: item.files_count + item.folders_count })
      if (this.props.courseColor) {
        tintColor = this.props.courseColor
      }
    }
    const renderImage = () => {
      return <View style={styles.icon}>
        <AccessIcon entry={item} image={icon} tintColor={tintColor} statusOffset={statusOffset} disableAppSpecificChecks={this.props.context === 'users'} />
      </View>
    }

    return (<View>
      <View>
        <Row
          renderImage={renderImage}
          title={name}
          subtitle={subtitle}
          identifier={index}
          onPress={this.onSelectRow}
          disclosureIndicator
          testID={`file-list.file-list-row.cell-${item.key}`}
          selected={selected} />
      </View>
      {(item.hidden || item.lock_at || item.unlock_at) ? (
        <View style={styles.restrictedIndicatorLine} />
      ) : (
        <AccessLine visible={!item.locked} disableAppSpecificChecks={this.props.context === 'users'} />
      )}
    </View>)
  }

  render () {
    const title = this.props.subFolder && this.props.folder
      ? this.props.folder.name
      : i18n('Files')
    const empty = <ListEmptyComponent title={i18n('This folder is empty.')} />

    const rightBarButtons = []
    if (this.canAdd()) {
      rightBarButtons.push({
        image: images.add,
        testID: 'files.add.button',
        action: this.addItem,
        accessibilityLabel: i18n('Add Item'),
      })
    }
    if (this.canEdit()) {
      rightBarButtons.push({
        testID: 'files.edit-folder.button',
        title: i18n('Edit'),
        action: this.handleEditFolder,
      })
    }

    return (
      <Screen
        customPageViewPath={this.props.customPageViewPath ? this.props.customPageViewPath : null}
        title={title}
        navBarColor={this.props.courseColor}
        navBarStyle={this.props.courseColor ? 'dark' : 'light'}
        rightBarButtons={rightBarButtons}
        onTraitCollectionChange={this.onTraitCollectionChange.bind(this)}
      >
        <DropView style={{ flex: 1 }}>
          { this.state.uploadPending && <SavingBanner title={this.state.uploadMessage || ''} /> }
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
            fileTypes={['all']}
            navigator={this.props.navigator}
          />
        </DropView>
      </Screen>
    )
  }
}

export function mapStateToProps (state: Object, props: FileListNavProps) {
  let parentFolder
  const key = `${props.context}-${props.contextID}`
  const contextFolders = state.folders[key] || {}
  const contextFiles = state.files[key] || {}
  const courseColor = (state.entities.courses[props.contextID] || {}).color
  if (!contextFolders['root'] || !contextFolders['root'][0]) {
    return { data: [], courseColor }
  }
  const rootFolder = contextFolders['root'][0]
  if (props.subFolder) {
    const fullPath = `${rootFolder.name}/${props.subFolder}`
    const parentPath = fullPath.substring(0, fullPath.lastIndexOf('/'))
    const possibleParents = contextFolders[parentPath]
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

  const folders = (contextFolders[parentFolder.full_name] || []).map(mapper('folder'))
  const canSelectFile = props.canSelectFile || (() => true)
  const files = (contextFiles[parentFolder.full_name] || []).map(mapper('file')).filter(canSelectFile)
  const data = [...folders, ...files].sort((a, b) => localeSort(a.name || a.display_name, b.name || b.display_name))

  return { data, folder: parentFolder, courseColor }
}

const styles = StyleSheet.create({
  icon: {
    alignSelf: 'flex-start',
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

let Connected = connect(mapStateToProps, Actions)(FilesList)
export default (Connected: Component<any, any>)
