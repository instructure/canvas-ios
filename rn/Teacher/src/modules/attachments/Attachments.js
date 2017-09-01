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
} from 'react-native'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import images from '../../images'
import AttachmentRow from './AttachmentRow'
import AttachmentPicker from './AttachmentPicker'
import EmptyAttachments from './EmptyAttachments'
import RowSeparator from '../../common/components/rows/RowSeparator'

type StorageOptions = {
  /* Determines if the attachment should be uploaded or not.
   *
   * If true the attachments will be uploaded to s3.
   * If false the attachments will be persisted and
   * contain the uri to the location on disk.
   *
   * Default: true
   */
  upload: boolean,
}

type AttachmentState = {
  progress: number,
  error: null,
  cancelled: boolean,
  data: Attachment,
}

type State = {
  attachments: Array<AttachmentState>,
}

export type Props = NavigationProps & {
  storageOptions: StorageOptions,
  attachments: Array<Attachment>,
  maxAllowed?: number,
  onComplete: (Array<Attachment>) => void,
}

export default class Attachments extends Component<any, Props, any> {
  state: State
  attachmentPicker: AttachmentPicker

  static defaultProps = {
    attachments: [],
    storageOptions: {
      upload: true,
    },
  }

  constructor (props: Props) {
    super(props)

    this.state = {
      attachments: props.attachments.map(a => ({
        progress: 1,
        error: null,
        cancelled: false,
        data: a,
      })),
    }
  }

  captureAttachmentPicker = (ref: AttachmentPicker) => {
    this.attachmentPicker = ref
  }

  render () {
    return (
      <Screen
        title={i18n('Attachments')}
        rightBarButtons={this.props.maxAllowed == null || this.state.attachments.length < this.props.maxAllowed ? [
          {
            image: images.add,
            testID: 'attachments.add-btn',
            action: this.addButtonPressed,
            accessibilityLabel: i18n('Add attachment'),
          },
        ] : []}
        leftBarButtons={[
          {
            title: i18n('Done'),
            testID: 'attachments.dismiss-btn',
            style: 'done',
            action: this.dismiss,
          },
        ]}
      >
        <View style={styles.container}>
          <AttachmentPicker ref={this.captureAttachmentPicker} />
          <FlatList
            ListEmptyComponent={this.renderEmptyComponent}
            data={this.state.attachments}
            renderItem={this.renderRow}
            keyExtractor={(item, index) => item.data.id}
            testID='attachments.list.list'
            ItemSeparatorComponent={RowSeparator}
          />
        </View>
      </Screen>
    )
  }

  renderRow = ({ item, index }: { item: AttachmentState, index: number }) => {
    return (
      <AttachmentRow
        title={item.data.display_name}
        progress={item.progress}
        onRemovePressed={this.removeAttachment(item.data)}
        onPress={this.showAttachment(item.data)}
        testID={`attachments.attachment-row.${index}`}
      />
    )
  }

  renderEmptyComponent = () => {
    return (
      <EmptyAttachments />
    )
  }

  addButtonPressed = () => {
    this.attachmentPicker.show(null, this.addAttachment)
  }

  dismiss = () => {
    this.props.onComplete(this.state.attachments.map(a => a.data))
    this.props.navigator.dismiss()
  }

  addAttachment = (attachment: Attachment) => {
    this.setState({
      attachments: [
        ...this.state.attachments,
        {
          progress: 1,
          error: null,
          data: attachment,
        },
      ],
    })
  }

  removeAttachment = (attachment: Attachment) => () => {
    this.setState({
      attachments: this.state.attachments.filter(a => a.data.id !== attachment.id),
    })
  }

  showAttachment (attachment: Attachment) {
    return () => {
      this.props.navigator.show('/attachment', { modal: true }, {
        attachment,
      })
    }
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginBottom: global.tabBarHeight,
  },
})
