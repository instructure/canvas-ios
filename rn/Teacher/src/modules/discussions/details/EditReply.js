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
import i18n from 'format-message'
import color from '../../../common/colors'
import Screen from '../../../routing/Screen'
import RichTextEditor from '../../../common/components/rich-text-editor/RichTextEditor'
import Actions from './actions'
import { alertError } from '../../../redux/middleware/error-handler'
import ModalOverlay from '../../../common/components/ModalOverlay'
import { isTeacher } from '../../app'
import Images from '../../../images'
import {
  View,
  LayoutAnimation,
  processColor,
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
        navBarTitleColor={color.darkText}
        navBarButtonColor={color.link}
        rightBarButtons={[
          {
            title: i18n('Done'),
            style: 'done',
            testID: 'edit-discussion-reply.done-btn',
            action: this._actionDonePressed,
          },
          permissions && permissions.attach && {
            image: Images.attachmentLarge,
            testID: 'edit-discussion-reply.attachment-btn',
            action: this.addAttachment,
            accessibilityLabel: i18n('Edit attachment ({count})', { count: this.state.attachment ? '1' : i18n('none') }),
            badge: this.state.attachment && {
              text: '1',
              backgroundColor: processColor('#008EE2'),
              textColor: processColor('white'),
            },
          },
        ]}
        dismissButtonTitle={i18n('Cancel')}
      >
        <View style={{ flex: 1 }}>
          <ModalOverlay text={i18n('Saving')} visible={this.state.pending} />
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
          />
        </View>
      </Screen>
    )
  }

  componentWillReceiveProps (props: Props) {
    if (props.error) {
      this._handleError(props.error)
      this.setState({ pending: false })
      return
    }
    if (this.state.pending && !props.pending) {
      this.props.refreshDiscussionEntries(this.props.context, this.props.contextID, this.props.discussionID, true)
      this.props.navigator.dismissAllModals()
      return
    }
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
    if (this.props.isEdit) {
      this.props.editEntry(this.props.context, this.props.contextID, this.props.discussionID, this.props.entryID, params, this.props.indexPath)
    } else {
      this.props.createEntry(this.props.context, this.props.contextID, this.props.discussionID, this.props.entryID, params, this.props.indexPath, this.props.lastReplyAt)
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

  _handleError (error: string) {
    setTimeout(() => {
      alertError(error)
    }, 1000)
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
