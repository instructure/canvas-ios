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
import { parseErrorMessage } from '../../redux/middleware/error-handler'
import i18n from 'format-message'
import images from '../../images'
import AttachmentRow from './AttachmentRow'
import AttachmentPicker, { type FileType, type Source } from './AttachmentPicker'
import EmptyAttachments from './EmptyAttachments'
import uuid from 'uuid/v1'
import { uploadAttachment, isAbort, uploadMedia, type Progress } from '../../canvas-api'
import RowSeparator from '../../common/components/rows/RowSeparator'

type StorageOptions = {
  // If not provided the attachments will not be uploaded
  uploadPath?: string,

  // E.g. 'My Files', 'Course Files', etc
  targetFolderPath?: ?string,

  // If true, audio and video attachments will be uploaded as media comments
  // and have a mediaCommentID
  mediaServer?: boolean,
}

type AttachmentState = {
  id: string,
  fileID: ?string,
  progress: Progress,
  error: null,
  cancel?: ?(() => void),
  data: Attachment,
  index: number,
}

type State = {
  attachments: { [string]: AttachmentState },
}

export type Props = NavigationProps & {
  storageOptions: StorageOptions,
  attachments: Array<Attachment>,
  maxAllowed?: number,
  onComplete: (Array<Attachment>) => void,
  uploadAttachment: typeof uploadAttachment,
  uploadMedia: typeof uploadMedia,
  fileTypes?: Array<FileType>,
  userFiles: boolean,
}

export default class Attachments extends Component<Props, any> {
  state: State
  attachmentPicker: AttachmentPicker
  progress: { [string]: number }

  static defaultProps = {
    attachments: [],
    storageOptions: {},
    uploadAttachment,
    uploadMedia,
    userFiles: false,
  }

  constructor (props: Props) {
    super(props)

    this.progress = {}
    this.state = {
      attachments: props.attachments.reduce((current, attachment) => ({
        ...current,
        [attachment.id]: {
          id: attachment.id,
          progress: { loaded: 0, total: 0 },
          error: null,
          data: attachment,
          fileID: attachment.id,
          index: Object.keys(current).length,
        },
      }), {}),
    }
  }

  captureAttachmentPicker = (ref: any) => {
    this.attachmentPicker = ref
  }

  render () {
    const anyInProgress = Object.values(this.state.attachments).reduce((current, attachment) => {
      // $FlowFixMe
      return current || (attachment.error == null && attachment.fileID == null)
    }, false)
    // $FlowFixMe
    const canAdd = this.props.maxAllowed == null || Object.values(this.state.attachments).length < this.props.maxAllowed
    return (
      <Screen
        drawUnderNavBar
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
        showDismissButton={false}
      >
        <View style={styles.container}>
          <FlatList
            ListEmptyComponent={this.renderEmptyComponent}
            data={Object.values(this.state.attachments)}
            renderItem={this.renderRow}
            keyExtractor={(item, index) => item.data.id}
            testID='attachments.list.list'
            ItemSeparatorComponent={RowSeparator}
          />
          <AttachmentPicker
            style={styles.attachmentPicker}
            ref={this.captureAttachmentPicker}
            fileTypes={this.props.fileTypes || ['all']}
            navigator={this.props.navigator}
            userFiles={this.props.userFiles}
          />
        </View>
      </Screen>
    )
  }

  renderRow = ({ item, index }: { item: AttachmentState, index: number }) => {
    return (
      <AttachmentRow
        title={item.data.display_name}
        completed={item.fileID != null}
        error={item.error}
        progress={item.progress}
        fileID={item.fileID}
        onRemovePressed={this.removeAttachment(item)}
        onPress={this.showAttachment(item.data)}
        testID={`attachments.attachment-row.${index}`}
        onCancel={this.cancelAttachment(item)}
        onRetry={this.retryAttachment(item)}
      />
    )
  }

  cancelAttachment (attachment: AttachmentState) {
    return () => {
      this.state.attachments[attachment.id] &&
        this.state.attachments[attachment.id].cancel &&
        this.state.attachments[attachment.id].cancel()
    }
  }

  retryAttachment (attachment: AttachmentState) {
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

      await this.uploadAttachment(attachment.data)
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
    const attachments = Object.values(this.state.attachments)
      .filter((a: any) => a.error == null)
      .sort((a: any, b: any) => a.index - b.index)
      .map((a: any) => a.data)
    this.props.onComplete(attachments)
    this.props.navigator.dismiss()
  }

  cancel = () => {
    Object.values(this.state.attachments).forEach(attachment => {
      // $FlowFixMe
      attachment && attachment.cancel && this.cancelAttachment(attachment.data)()
    })
    this.props.navigator.dismiss()
  }

  addAttachment = async (attachment: Attachment, source: Source) => {
    attachment.id = uuid()
    const shouldUpload = source !== 'userFiles' &&
      (this.props.storageOptions.uploadPath != null || this.uploadAsMediaComment(attachment))
    this.setState({
      attachments: {
        ...this.state.attachments,
        [attachment.id]: {
          id: attachment.id,
          progress: shouldUpload ? { loaded: 0.1, total: 1 } : { loaded: 0, total: 0 },
          error: null,
          data: attachment,
          fileID: shouldUpload ? null : attachment.id,
          index: Object.keys(this.state.attachments).length,
        },
      },
    })

    if (shouldUpload) {
      await this.uploadAttachment(attachment)
    }
  }

  removeAttachment = (attachment: AttachmentState) => () => {
    const attachments = { ...this.state.attachments }
    delete attachments[attachment.id]
    this.setState({ attachments })
  }

  showAttachment (attachment: Attachment) {
    return () => {
      this.props.navigator.show('/attachment', { modal: true }, {
        attachment,
      })
    }
  }

  captureCancel (attachment: Attachment) {
    return (cancel: Function) => {
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

  async uploadAttachment (attachment: Attachment) {
    this.progress[attachment.id] = 0
    try {
      let upload
      if (this.uploadAsMediaComment(attachment)) {
        upload = this.uploadMedia(attachment)
      } else {
        upload = this.uploadFile(attachment)
      }

      const file = await upload
      if (!file) return // options said not to uplaod

      this.setState({
        attachments: {
          ...this.state.attachments,
          [attachment.id]: {
            ...this.state.attachments[attachment.id],
            error: null,
            cancel: null,
            data: file,
            fileID: file.id,
          },
        },
      })
    } catch (e) {
      this.handleUploadError(e, attachment)
    }
  }

  uploadFile = async (attachment: Attachment) => {
    let path = this.props.storageOptions.uploadPath
    if (!path) return

    const file = await this.props.uploadAttachment(attachment, {
      path,
      cancelUpload: this.captureCancel(attachment),
      parentFolderPath: this.props.storageOptions.targetFolderPath,
      onProgress: this.updateProgress(attachment.id),
    })

    // it's very important to preserve the `attachment` uri for previews
    return { ...attachment, ...file }
  }

  uploadMedia = async (attachment: Attachment) => {
    const mediaID = await this.props.uploadMedia(attachment.uri, attachment.mime_class, {
      onProgress: this.updateProgress(attachment.id),
      cancelUpload: this.captureCancel(attachment),
    })
    return { ...attachment, id: mediaID, media_entry_id: mediaID }
  }

  uploadAsMediaComment = (attachment: Attachment) => {
    return Boolean(this.props.storageOptions.mediaServer && ['video', 'audio'].includes(attachment.mime_class))
  }

  handleUploadError = (error: any, attachment: Attachment) => {
    const e = isAbort(error)
      ? i18n('Upload cancelled by user')
      : parseErrorMessage(error)
    this.setState({
      attachments: {
        ...this.state.attachments,
        [attachment.id]: {
          ...this.state.attachments[attachment.id],
          error: e,
          cancel: null,
          fileID: null,
        },
      },
    })
  }

  updateProgress (id: string) {
    return (progress: Progress) => {
      const ratio = progress.loaded / progress.total
      const delta = Math.max(ratio - this.progress[id])
      if (delta >= 0.3 || ratio >= 1) {
        this.progress[id] = ratio
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
