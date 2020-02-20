//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import i18n from 'format-message'
import { colors } from '../../../common/stylesheet'
import Screen from '../../../routing/Screen'
import RichTextEditor from '../../../common/components/rich-text-editor/RichTextEditor'
import Actions from './actions'
import { isTeacher } from '../../app'
import Images from '../../../images'
import {
  ActivityIndicator,
  View,
  LayoutAnimation,
  processColor,
  NativeModules,
  StyleSheet,
} from 'react-native'

type OwnProps = {
  discussionID: string,
  context: CanvasContext,
  contextID: string,
  indexPath?: number[],
  entryID?: ?string,
  lastReplyAt: string,
  message: string,
  permissions: DiscussionPermissions,
  isEdit?: boolean,
}

type State = {
  pending: number,
  error?: ?string,
}

type Props = OwnProps & typeof Actions & NavigationProps & State

export class EditReply extends React.Component<Props, any> {
  state: any = {
    pending: false,
    attachment: null,
  }
  editor: ?RichTextEditor

  render () {
    const permissions = this.props.permissions
    let message = this.props.message || ''
    const { isEdit } = this.props
    return (
      <Screen
        title={isEdit ? i18n('Edit') : i18n('Reply')}
        navBarTitleColor={colors.textDarkest}
        navBarButtonColor={colors.linkColor}
        rightBarButtons={[
          {
            title: i18n('Done'),
            style: 'done',
            testID: 'DiscussionEditReply.doneButton',
            action: this._actionDonePressed,
          },
          permissions && permissions.attach && {
            image: Images.paperclip,
            testID: 'DiscussionEditReply.attachmentButton',
            action: this.addAttachment,
            accessibilityLabel: i18n('Edit attachment ({count})', { count: this.state.attachment ? '1' : i18n('none') }),
            badge: this.state.attachment && {
              text: '1',
              backgroundColor: processColor(colors.backgroundInfo),
              textColor: processColor(colors.white),
            },
          },
        ]}
        dismissButtonTitle={i18n('Cancel')}
      >
        <View style={{ flex: 1 }}>
          <RichTextEditor
            ref={(r) => { this.editor = r }}
            onChangeValue={this._valueChanged('message')}
            defaultValue={message}
            showToolbar='always'
            scrollEnabled={true}
            placeholder={i18n('Message')}
            focusOnLoad={true}
            navigator={this.props.navigator}
            attachmentUploadPath={isTeacher() ? `/${this.props.context}/${this.props.contextID}/files` : '/users/self/files'}
            context={this.props.context}
            contextID={this.props.contextID}
          />
          { this.state.pending &&
            <ActivityIndicator style={StyleSheet.absoluteFill} size='large' />
          }
        </View>
      </Screen>
    )
  }

  componentWillUnmount () {
    this.props.deletePendingReplies(this.props.discussionID)
  }

  _actionDonePressed = async () => {
    const message = this.editor && await this.editor.getHTML()
    const params = {
      message,
      attachment: this.state.attachment,
    }
    this.setState({ pending: true })
    const isNew = !this.props.isEdit
    try {
      if (isNew) {
        await this.props.createEntry(this.props.context, this.props.contextID, this.props.discussionID, this.props.entryID, params, this.props.indexPath, this.props.lastReplyAt).payload.promise
      } else {
        await this.props.editEntry(this.props.context, this.props.contextID, this.props.discussionID, this.props.entryID, params, this.props.indexPath).payload.promise
      }
      this.props.refreshDiscussionEntries(this.props.context, this.props.contextID, this.props.discussionID, true)
      await this.props.navigator.dismiss()
      if (isNew) {
        NativeModules.AppStoreReview.handleSuccessfulSubmit()
        NativeModules.ModuleItemsProgress.contributedDiscussion(this.props.contextID, this.props.discussionID)
      }
    } catch (e) {
      console.warn(e)
      this.setState({ pending: false })
    }
  }

  _valueChanged (property: string, transformer?: any, animated?: boolean = true): Function {
    return (value) => {
      if (transformer) { value = transformer(value) }
      this._valuesChanged({ [property]: value }, animated)
    }
  }

  _valuesChanged (values: Object, animated?: boolean) {
    if (animated) {
      LayoutAnimation.easeInEaseOut()
    }
    this.setState({ ...values })
  }

  addAttachment = () => {
    this.props.navigator.show('/attachments', { modal: true }, {
      attachments: this.state.attachment ? [this.state.attachment] : [],
      maxAllowed: 1,
      storageOptions: {
        uploadPath: null,
      },
      onComplete: this._valueChanged('attachment', (as) => as[0]),
    })
  }
}

export function mapStateToProps ({ entities }: AppState, { context, contextID, discussionID }: OwnProps): State {
  let pending = 0
  let error = null

  if (entities.discussions[discussionID] &&
      entities.discussions[discussionID].replies &&
      entities.discussions[discussionID].replies.new) {
    pending = entities.discussions[discussionID].replies.new.pending
    error = entities.discussions[discussionID].replies.new.error
  }
  if (!pending && !error &&
      entities.discussions[discussionID] &&
      entities.discussions[discussionID].replies &&
      entities.discussions[discussionID].replies.edit) {
    pending = entities.discussions[discussionID].replies.edit.pending
    error = entities.discussions[discussionID].replies.edit.error
  }

  return {
    pending,
    error,
  }
}

let Connected = connect(mapStateToProps, Actions)(EditReply)
export default (Connected: Component<Props, any>)
