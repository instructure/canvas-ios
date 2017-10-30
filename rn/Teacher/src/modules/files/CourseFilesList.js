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
  Alert,
  StyleSheet,
} from 'react-native'

import { connect } from 'react-redux'
import Actions from './actions'
import i18n from 'format-message'
import Screen from '../../routing/Screen'
import canvas from 'instructure-canvas-api'
import { ERROR_TITLE, parseErrorMessage } from '../../redux/middleware/error-handler'
import Row from '../../common/components/rows/Row'
import RowSeparator from '../../common/components/rows/RowSeparator'
import find from 'lodash/find'
import localeSort from '../../utils/locale-sort'
import PublishedIcon from '../../common/components/PublishedIcon'
import ListEmptyComponent from '../../common/components/ListEmptyComponent'
import images from '../../images'
import bytes from 'bytes'
import DropView from '../../common/components/DropView'

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
      const updateFolder = async (folderID: string) => {
        const folders = await this.props.getFolderFolders(folderID)
        this.props.foldersUpdated(folders.data)
        const files = await this.props.getFolderFiles(folderID)
        this.props.filesUpdated(files.data)
      }

      if (this.props.folder) {
        await updateFolder(this.props.folder.id)
      } else {
        const response = await this.props.getCourseFolder(this.props.courseID, 'root')
        const root = response.data
        this.props.foldersUpdated([root])
        await updateFolder(root.id)
      }
    } catch (error) {
      Alert.alert(ERROR_TITLE, parseErrorMessage(error))
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
    return (
      <Screen
        title={title}
        navBarTitleColor={'#fff'}
      >
        <DropView style={{ flex: 1 }}>
          <FlatList
            data={this.props.data}
            renderItem={this.renderRow}
            onRefresh={this.update}
            refreshing={this.state.pending}
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
}

export function rootFolderForCourseID (courseID: string, folders: [Folder]): ?Folder {
  return find(folders, { parent_folder_id: null, context_type: 'Course', context_id: courseID })
}

export function mapStateToProps ({ entities }: any, props: CourseFileListNavProps): CourseFilesListProps {
  let parentFolder
  const allFolders = Object.values(entities.folders)
  const rootFolder = rootFolderForCourseID(props.courseID, allFolders)
  if (!rootFolder) {
    return { data: [] }
  }
  const courseFolders = allFolders.filter((folder) => folder.context_id === props.courseID && folder.context_type === 'Course')
  if (props.subFolder) {
    const fullName = `${rootFolder.name}/${props.subFolder}`
    parentFolder = find(allFolders, { full_name: fullName })
  } else {
    parentFolder = rootFolder
  }

  if (!parentFolder) {
    return { data: [] }
  }

  const folders = courseFolders.filter((folder) => {
    return folder.parent_folder_id === parentFolder.id
  }).map((folder) => {
    return {
      ...folder,
      type: 'folder',
      key: `folder-${folder.id}`,
    }
  })

  const files = Object.values(entities.files).filter((file) => {
    return file.folder_id === parentFolder.id
  }).map((file) => {
    return {
      ...file,
      type: 'file',
      key: `file-${file.id}`,
    }
  })

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
