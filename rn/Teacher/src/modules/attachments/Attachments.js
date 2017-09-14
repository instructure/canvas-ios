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
import { connect } from 'react-redux'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import images from '../../images'
import AttachmentRow from './AttachmentRow'
import AttachmentPicker from './AttachmentPicker'
import EmptyAttachments from './EmptyAttachments'
import uuid from 'uuid/v1'
import { uploadAttachment, type Progress } from 'instructure-canvas-api'
import axios from 'axios'
import RowSeparator from '../../common/components/rows/RowSeparator'

type StorageOptions = {
  uploadPath?: string, // if not provided the attachments will not be uploaded
  targetFolderPath?: ?string,
}

type AttachmentState = {
  progress: Progress,
  error: null,
  cancel?: ?(() => void),
  data: Attachment,
}

type State = {
  attachments: { [string]: ?AttachmentState },
}

export type Props = NavigationProps & {
  storageOptions: StorageOptions,
  attachments: Array<Attachment>,
  maxAllowed?: number,
  onComplete: (Array<Attachment>) => void,
  uploadAttachment: typeof uploadAttachment,
}

export class Attachments extends Component<any, Props, any> {
  state: State
  attachmentPicker: AttachmentPicker

  static defaultProps = {
    storageOptions: {},
  }

  constructor (props: Props) {
    super(props)

    this.state = {
      attachments: props.attachments.reduce((current, attachment) => ({
        ...current,
        [attachment.id]: {
          progress: { loaded: 0, total: 0 },
          error: null,
          data: attachment,
        },
      }), {}),
    }
  }

  captureAttachmentPicker = (ref: AttachmentPicker) => {
    this.attachmentPicker = ref
  }

  render () {
    const anyInProgress = Object.values(this.state.attachments).reduce((current, attachment) => {
      // $FlowFixMe
      return current || (attachment && !attachment.error && attachment.progress.loaded < attachment.progress.total)
    }, false)
    // $FlowFixMe
    const canAdd = this.props.maxAllowed == null || Object.values(this.state.attachments).filter(a => a).length < this.props.maxAllowed
    return (
      <Screen
        title={i18n('Attachments')}
        rightBarButtons={canAdd ? [
          {
            image: images.add,
            testID: 'attachments.add-btn',
            action: this.addButtonPressed,
            accessibilityLabel: i18n('Add attachment'),
          },
        ] : []}
        leftBarButtons={[
          {
            title: anyInProgress ? i18n('Cancel') : i18n('Done'),
            testID: 'attachments.dismiss-btn',
            style: anyInProgress ? 'cancel' : 'done',
            action: anyInProgress ? this.cancel : this.dismiss,
          },
        ]}
      >
        <View style={styles.container}>
          <FlatList
            ListEmptyComponent={this.renderEmptyComponent}
            data={Object.values(this.state.attachments).filter(a => a)}
            renderItem={this.renderRow}
            keyExtractor={(item, index) => item.data.id}
            testID='attachments.list.list'
            ItemSeparatorComponent={RowSeparator}
          />
          <AttachmentPicker
            style={styles.attachmentPicker}
            ref={this.captureAttachmentPicker}
          />
        </View>
      </Screen>
    )
  }

  renderRow = ({ item, index }: { item: AttachmentState, index: number }) => {
    return (
      <AttachmentRow
        title={item.data.display_name}
        error={item.error}
        progress={item.progress}
        onRemovePressed={this.removeAttachment(item.data)}
        onPress={this.showAttachment(item.data)}
        testID={`attachments.attachment-row.${index}`}
        onCancel={this.cancelAttachment(item.data)}
        onRetry={this.retryAttachment(item.data)}
      />
    )
  }

  cancelAttachment (attachment: Attachment) {
    return () => {
      this.state.attachments[attachment.id] &&
        this.state.attachments[attachment.id].cancel &&
        this.state.attachments[attachment.id].cancel()
    }
  }

  retryAttachment (attachment: Attachment) {
    return async () => {
      this.setState({
        attachments: {
          ...this.state.attachments,
          [attachment.id]: {
            ...this.state.attachments[attachment.id],
            error: null,
            progress: { loaded: 0.1, total: 1 },
          },
        },
      })
      this.props.storageOptions.uploadPath && await this.uploadAttachment(attachment, this.props.storageOptions.uploadPath)
    }
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
    // $FlowFixMe
    this.props.onComplete(Object.values(this.state.attachments).filter(a => a).map(a => a.data))
    this.props.navigator.dismiss()
  }

  cancel = () => {
    Object.values(this.state.attachments).forEach(attachment => {
      // $FlowFixMe
      attachment && attachment.cancel && this.cancelAttachment(attachment.data)()
    })
    this.props.navigator.dismiss()
  }

  addAttachment = async (attachment: Attachment) => {
    attachment.id = uuid()
    const shouldUpload = this.props.storageOptions.uploadPath != null
    this.setState({
      attachments: {
        ...this.state.attachments,
        [attachment.id]: {
          progress: shouldUpload ? { loaded: 0.1, total: 1 } : { loaded: 0, total: 0 },
          error: null,
          data: attachment,
        },
      },
    })

    this.props.storageOptions.uploadPath && await this.uploadAttachment(attachment, this.props.storageOptions.uploadPath)
  }

  removeAttachment = (attachment: Attachment) => () => {
    this.setState({
      attachments: {
        ...this.state.attachments,
        [attachment.id]: null,
      },
    })
  }

  showAttachment (attachment: Attachment) {
    return () => {
      this.props.navigator.show('/attachment', { modal: true }, {
        attachment,
      })
    }
  }

  captureCancel (attachment: Attachment): Function {
    return (cancel) => {
      this.setState({
        attachments: {
          ...this.state.attachments,
          [attachment.id]: {
            ...this.state.attachments[attachment.id],
            cancel,
          },
        },
      })
    }
  }

  async uploadAttachment (attachment: Attachment, path: string) {
    try {
      const file = await this.props.uploadAttachment(attachment, {
        path,
        cancelUpload: this.captureCancel(attachment),
        parentFolderPath: this.props.storageOptions.targetFolderPath,
        onProgress: this.updateProgress(attachment.id),
      })
      this.setState({
        attachments: {
          ...this.state.attachments,
          [attachment.id]: null,
          [file.id]: {
            ...this.state.attachments[attachment.id],
            error: null,
            cancel: null,
            data: file,
          },
        },
      })
    } catch (e) {
      const error = axios.isCancel(e) ? i18n('Upload cancelled by user') : e.message || i18n('Failed to upload attachment')
      this.setState({
        attachments: {
          ...this.state.attachments,
          [attachment.id]: {
            ...this.state.attachments[attachment.id],
            error,
            cancel: null,
          },
        },
      })
    }
  }

  updateProgress (id: string) {
    return (progress: Progress) => {
      this.setState({
        attachments: {
          ...this.state.attachments,
          [id]: {
            ...this.state.attachments[id],
            progress,
          },
        },
      })
    }
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginBottom: global.tabBarHeight,
  },
  attachmentPicker: {
    position: 'absolute',
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
  },
})

const mergeProps = (stateProps, dispatchProps, ownProps) => ({
  ...stateProps,
  ...dispatchProps,
  ...ownProps,
  uploadAttachment,
})

const Connected = connect(
  null,
  null,
  mergeProps,
)(Attachments)

export default (Connected: any)
