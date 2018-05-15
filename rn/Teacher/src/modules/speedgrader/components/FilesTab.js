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
import { connect } from 'react-redux'
import {
  View,
  ScrollView,
  StyleSheet,
  FlatList,
  Image,
  TouchableHighlight,
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import Images from '../../../images'
import SpeedGraderActions from '../actions'
import DrawerState from '../utils/drawer-state'
import ListEmptyComponent from '../../../common/components/ListEmptyComponent'

export class FilesTab extends Component<FileTabProps> {
  listOfFiles () {
    const submission = this.props.submissionProps.submission
    const selectedIndex = this.props.selectedIndex
    if (!submission || !submission.attachments || submission.submission_type !== 'online_upload') return []
    let files = submission.attachments
    if (selectedIndex != null) {
      if (!submission.submission_history[selectedIndex].attachments) return []
      files = submission.submission_history[selectedIndex].attachments
    }
    return files
  }

  selectFile = (index: number) => {
    if (this.props.submissionID) {
      this.props.selectFile(this.props.submissionID, index)
      this.props.drawerState.snapTo(0, true)
    }
  }

  renderIcon = (item: Object) => {
    if (item.thumbnail_url) {
      return <Image source={{ uri: item.thumbnail_url }} style={styles.thumbnails} />
    }
    let src = Images.speedGrader.page
    switch (item.mime_class) {
      case 'audio':
        src = Images.speedGrader.audio
        break
      case 'video':
        src = Images.speedGrader.video
        break
      case 'pdf':
        src = Images.speedGrader.pdf
        break
      case 'doc':
      default:
        src = Images.speedGrader.page
        break
    }
    return <Image source={src} style={styles.icons} />
  }

  keyExtractor = (item: Object, index: number) => `${index}`

  renderRow = ({ item, index }: { item: Object, index: number }) => {
    let selected = this.props.selectedAttachmentIndex === index
    const traits = selected ? 'selected' : 'none'
    return <View>
      <TouchableHighlight
        underlayColor="#eee"
        onPress={() => this.selectFile(index)}
        accessible={true}
        accessibilityTraits={traits}
        testID={`speedgrader.files.row${index}`}
      >
        <View style={styles.row}>
          <View style={styles.iconContainer}>
            {this.renderIcon(item)}
          </View>
          <View style={styles.filenameContainer}>
            <Text style={styles.filename}>{item.display_name}</Text>
          </View>
          <View style={styles.checkmarkContainer}>
            {selected && <Image source={Images.check} style={styles.checkmark} />}
          </View>
        </View>
      </TouchableHighlight>
    </View>
  }

  render () {
    return (
      <ScrollView>
        <FlatList
          data={this.listOfFiles()}
          keyExtractor={this.keyExtractor}
          testID='speedgrader.files.list'
          renderItem={this.renderRow}
          extraData={{ selected: this.props.selectedAttachmentIndex }}
          ListEmptyComponent={<ListEmptyComponent title={i18n('There are no files to display.')} />}
        />
      </ScrollView>
    )
  }
}

const styles = StyleSheet.create({
  row: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
    paddingHorizontal: 16,
    paddingVertical: 16,
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  iconContainer: {
    marginRight: 16,
  },
  icons: {
    resizeMode: 'contain',
    width: 24,
    tintColor: '#00BCD5',
  },
  thumbnails: {
    height: 24,
    width: 24,
  },
  filenameContainer: {
    flex: -1,
    flexGrow: 1,
    alignSelf: 'flex-end',
  },
  filename: {
    textAlign: 'left',
    overflow: 'hidden',
    fontWeight: '500',
  },
  checkmark: {
    resizeMode: 'contain',
    tintColor: '#008EE2',
    height: 10,
    width: 13,
  },
  checkmarkContainer: {
    alignSelf: 'center',
  },
})

export function mapStateToProps (state: AppState, ownProps: RouterProps): FileTabDataProps {
  if (!ownProps.submissionID) {
    return {
      selectedAttachmentIndex: null,
    }
  }

  return {
    selectedAttachmentIndex: state.entities.submissions[ownProps.submissionID].selectedAttachmentIndex,
  }
}

let Connected = connect(mapStateToProps, SpeedGraderActions)(FilesTab)
export default (Connected: any)

type RouterProps = {
  closeModal: Function,
  showModal: Function,
  courseID: string,
  assignmentID: string,
  userID: string,
  submissionID: ?string,
  submissionProps: Object,
  selectedIndex: ?number,
  drawerState: DrawerState,
}

type FileTabDataProps = {
  selectedAttachmentIndex: ?number,
}

type FileTabActionsProps = {
  selectFile: Function,
}

type FileTabProps = RouterProps & FileTabDataProps & FileTabActionsProps
