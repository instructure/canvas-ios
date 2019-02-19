//
// Copyright (C) 2017-present Instructure, Inc.
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
  StyleSheet,
  ActionSheetIOS,
  AlertIOS,
  LayoutAnimation,
  FlatList,
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
import bytes, { unitFor } from '../../utils/locale-bytes'
import DropView from '../../common/components/DropView'
import SavingBanner from '../../common/components/SavingBanner'
import TypeAheadSearch from '../../common/TypeAheadSearch'
import AttachmentPicker from '../attachments/AttachmentPicker'
import uuid from 'uuid/v1'
import { wait } from '../../utils/async-wait'
import { isTeacher } from '../app'
import color from '../../common/colors'
import { Text } from '../../common/text'
import { isRegularDisplayMode } from '../../routing/utils'
import type { TraitCollection } from '../../routing/Navigator'
import { logEvent } from '@common/CanvasAnalytics'

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
    getContextFolderHierarchy: Function,
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
  searchResults: Array<File>,
  searchQuery: string,
  searchPending: boolean,
}

const MinimumQueryLength = 3

export class FilesList extends Component<Props, State> {
  static defaultProps = {
    getContextFolderHierarchy: canvas.getContextFolderHierarchy,
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
  search: ?TypeAheadSearch

  state = {
    pending: false,
    uploadPending: false,
    uploadMessage: null,
    selectedRowID: null,
    isRegularScreenDisplayMode: false,
    searchResults: [],
    searchQuery: '',
    searchPending: false,
  }

  componentWillMount () {
    this.onTraitCollectionChange()
    this.update()
  }

  update = async (showSpinner: boolean = false) => {
    if (showSpinner) {
      this.setState({ pending: true })
    }
    try {
      let { contextID, context, folder, subFolder } = this.props
      if (!folder) {
        const folders = (await this.props.getContextFolderHierarchy(context, contextID, subFolder || '')).data
        for (const level of folders) {
          this.props.folderUpdated(level, contextID, context)
        }
        this.props.foldersUpdated([folders[0]], 'root', contextID, context)
        folder = folders[folders.length - 1]
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
    if (this.props.folder && this.props.folder.can_upload) return true
    return isTeacher()
  }

  onSelectRow = (index: number) => {
    const item = this.listData()[index]
    const {
      contextID,
      context,
      onSelectFile,
      canSelectFile,
      canEdit,
      canAdd,
    } = this.props

    if (item.type === 'file') {
      logEvent('file_viewed')
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
      if (item.mime_class === 'image' && item.thumbnail_url) {
        icon = { uri: item.thumbnail_url }
      } else if (item.mime_class === 'video') {
        icon = images.files.media
      } else {
        icon = images.document
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
    </View>)
  }

  shouldShowMinimumQueryLengthMessage = () => {
    return this.isSearching() &&
      this.state.searchQuery &&
      this.state.searchQuery.length < MinimumQueryLength
  }

  renderSearchBar = () => {
    const endpoint = `/${this.props.context}/${this.props.contextID}/files`
    return (
      <View>
        <TypeAheadSearch
          ref={r => { this.search = r }}
          endpoint={endpoint}
          parameters={this.searchParameters}
          onRequestFinished={this.searchFinished}
          onNextRequestFinished={this.nextSearchFinished}
          onChangeText={this.searchQueryChanged}
          defaultQuery=''
          minimumQueryLength={MinimumQueryLength}
          placeholder={i18n('Search files')}
        />
        { this.shouldShowMinimumQueryLengthMessage() &&
          <Text testID='search-message' style={styles.queryLength}>
            {i18n('Enter a search term with three or more characters.')}
          </Text>
        }
      </View>
    )
  }

  searchParameters = (query: string) => ({
    search_term: query,
  })

  searchFinished = (results: ?Array<File>, error: ?string) => {
    if (error) {
      alertError(error)
    }

    this.setSearchResults(results || [])
  }

  searchQueryChanged = (searchQuery: string) => {
    this.setState({
      searchResults: [],
      searchQuery,
      searchPending: searchQuery.length > 0,
    })
  }

  nextSearchFinished = (results: ?Array<File>, error: ?string) => {
    if (error) {
      alertError(error)
    }

    this.setSearchResults(this.state.searchResults.concat(results || []))
  }

  onEndReached = () => {
    if (this.state.searchQuery && this.state.searchQuery.length && this.search) {
      this.search.next()
    }
  }

  setSearchResults = (results: Array<File>) => {
    const files = results.map(result => ({ ...result, type: 'file', key: `file-${result.id}` }))
    this.setState({
      searchPending: false,
      searchResults: files,
    })
  }

  isSearching = () => Boolean(this.state.searchQuery && this.state.searchQuery.length > 0)

  shouldShowEmpty = () => {
    if (this.isSearching()) {
      return this.state.searchQuery && this.state.searchQuery.length >= MinimumQueryLength
    }
    return !this.state.pending
  }

  emptyMessage () {
    if (this.isSearching()) {
      if (this.state.searchPending) {
        return i18n('Searching...')
      }
      return i18n('No Results Found')
    }
    return i18n('This folder is empty')
  }

  listData = (): any[] => {
    return this.isSearching() ? this.state.searchResults : this.props.data
  }

  render () {
    const title = this.props.subFolder && this.props.folder
      ? this.props.folder.name
      : i18n('Files')
    const empty = this.shouldShowEmpty() ? <ListEmptyComponent title={this.emptyMessage()} /> : null

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

    const data = this.listData()
    const isCourse = !!this.props.courseColor

    return (
      <Screen
        customPageViewPath={this.props.customPageViewPath ? this.props.customPageViewPath : null}
        title={title}
        navBarColor={isCourse ? this.props.courseColor : color.navBarColor}
        navBarStyle={isCourse ? 'dark' : color.statusBarStyle}
        navBarButtonColor={isCourse ? 'white' : color.navBarTextColor}
        navBarTitleColor={isCourse ? 'white' : color.navBarTextColor}
        statusBarStyle={isCourse ? 'light' : color.statusBarStyle}
        rightBarButtons={rightBarButtons}
        onTraitCollectionChange={this.onTraitCollectionChange.bind(this)}
      >
        <DropView style={{ flex: 1 }}>
          { this.state.uploadPending && <SavingBanner title={this.state.uploadMessage || ''} /> }
          <FlatList
            data={data}
            renderItem={this.renderRow}
            onRefresh={() => this.update(true)}
            onEndReached={this.onEndReached}
            refreshing={Boolean(this.state.pending) && !this.state.uploadPending}
            keyboardDismissMode='on-drag'
            ItemSeparatorComponent={RowSeparator}
            ListHeaderComponent={this.renderSearchBar()}
            ListFooterComponent={data.length > 0 ? RowSeparator : null}
            ListEmptyComponent={empty} />
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
    const fullPath = `${rootFolder.name}/${decodeURIComponent(props.subFolder)}`
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
  attachmentPicker: {
    position: 'absolute',
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
  },
  queryLength: {
    marginHorizontal: global.style.defaultPadding,
    marginTop: -5,
    fontSize: 13,
    color: color.grey5,
  },
})

let Connected = connect(mapStateToProps, Actions)(FilesList)
export default (Connected: Component<any, any>)
