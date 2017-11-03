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
import canvas from 'instructure-canvas-api'
import { alertError } from '../../redux/middleware/error-handler'
import Row from '../../common/components/rows/Row'
import RowSeparator from '../../common/components/rows/RowSeparator'
import find from 'lodash/find'
import localeSort from '../../utils/locale-sort'
import PublishedIcon from '../../common/components/PublishedIcon'
import ListEmptyComponent from '../../common/components/ListEmptyComponent'
import images from '../../images'
import bytes from 'bytes'
import DropView from '../../common/components/DropView'
import SavingBanner from '../../common/components/SavingBanner'

type CourseFilesListProps = {
  data: [any], // The folders and files that are currently being shown
  folder: Folder, // The folder that is currently being displayed
}

type CourseFileListNavProps = {
  courseID: string,
  subFolder?: ?string,
}

type Props = CourseFilesListProps & CourseFileListNavProps

export class CourseFilesList extends Component<any, Props, any> {

  constructor (props: any) {
    super(props)
    this.state = {
      pending: false,
    }
  }

  componentWillMount () {
    this.update()
  }

  update = async () => {
    this.setState({ pending: true })
    try {
      const courseID = this.props.courseID
      const updateFolder = async (folderID: string, path: string) => {
        const folders = await this.props.getFolderFolders(folderID)
        this.props.foldersUpdated(folders.data, path, courseID, 'Course')
        const files = await this.props.getFolderFiles(folderID)
        this.props.filesUpdated(files.data, path, courseID, 'Course')
      }

      if (this.props.folder) {
        await updateFolder(this.props.folder.id, this.props.folder.full_name)
      } else {
        const response = await this.props.getCourseFolder(courseID, 'root')
        const root = response.data
        this.props.foldersUpdated([root], 'root', courseID, 'Course')
        await updateFolder(root.id, root.full_name)
      }
    } catch (error) {
      alertError(error)
    }
    this.setState({ pending: false })
  }

  onSelectRow = (index: number) => {
    const item = this.props.data[index]

    if (item.type === 'file') {
      this.props.navigator.show('/attachment', { modal: true }, { attachment: item })
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

  addItem = () => {
    const options = [
      i18n('Create Folder'),
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
    this.setState({ folderPending: true })
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
    this.setState({ folderPending: false })
  }

  renderRow = ({ item, index }: any) => {
    let name
    let icon
    let subtitle
    let published = !item.locked
    if (item.type === 'file') {
      name = item.display_name
      icon = images.document
      subtitle = bytes(item.size)
    } else {
      name = item.name
      icon = images.course.files
      subtitle = i18n(`{ 
        file_count, plural, 
          one {# file} 
          other {# files}
      }`, { file_count: item.files_count })
    }

    const renderImage = () => {
      return <View style={styles.icon}>
               <PublishedIcon published={published} image={icon} style={styles.icon} />
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
              { published ? <View style={styles.publishedIndicatorLine} /> : <View /> }
            </View>)
  }

  render () {
    const title = this.props.subFolder ? this.props.subFolder.split('/').pop() : i18n('Files')
    const empty = <ListEmptyComponent title={i18n('This folder is empty.')} />

    const rightBarButtons = [{
      image: images.add,
      testID: 'course-files.add.button',
      action: this.addItem,
      accessibilityLabel: i18n('Add Item'),
    }]
    return (
      <Screen
        title={title}
        navBarTitleColor={'#fff'}
        rightBarButtons={rightBarButtons}
      >
        <DropView style={{ flex: 1 }}>
          { this.state.folderPending && <SavingBanner /> }
          <FlatList
            data={this.props.data}
            renderItem={this.renderRow}
            onRefresh={this.update}
            refreshing={Boolean(this.state.pending) && !this.state.folderPending}
            ItemSeparatorComponent={RowSeparator}
            ListHeaderComponent={this.props.data.length > 0 ? RowSeparator : null}
            ListFooterComponent={this.props.data.length > 0 ? RowSeparator : null}
            ListEmptyComponent={this.state.pending ? null : empty} />
        </DropView>
      </Screen>
    )
  }
}

CourseFilesList.defaultProps = {
  getCourseFolder: canvas.getCourseFolder,
  getFolderFolders: canvas.getFolderFolders,
  getFolderFiles: canvas.getFolderFiles,
  createFolder: canvas.createFolder,
}

export function mapStateToProps (state: AppState, props: CourseFileListNavProps): CourseFilesListProps {
  let parentFolder
  const key = `Course-${props.courseID}`
  const courseFolders = state.folders[key] || {}
  const courseFiles = state.files[key] || {}
  if (!courseFolders['root'] || !courseFolders['root'][0]) {
    return { data: [] }
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
    return { data: [] }
  }

  const mapper = (type: string) => (item) => {
    return { ...item, type, key: `${type}-${item.id}` }
  }

  const folders = (courseFolders[parentFolder.full_name] || []).map(mapper('folder'))
  const files = (courseFiles[parentFolder.full_name] || []).map(mapper('file'))
  const data = [...folders, ...files].sort((a, b) => localeSort(a.name || a.display_name, b.name || b.display_name))

  return { data, folder: parentFolder }
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
})

let Connected = connect(mapStateToProps, Actions)(CourseFilesList)
export default (Connected: Component<any, any, any>)
