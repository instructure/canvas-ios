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
import ModalActivityIndicator from '../../../common/components/ModalActivityIndicator'
import {
  View,
  LayoutAnimation,
} from 'react-native'

type OwnProps = {
  discussionID: string,
  courseID: string,
  indexPath?: number[],
  entryID?: ?string,
  lastReplyAt: string,
}

type State = {
  pending: number,
  error?: ?string,
}

type Props = OwnProps & typeof Actions & NavigationProps & State

export class EditReply extends React.Component<any, Props, any> {
  props: Props

  constructor (props: Props) {
    super(props)
    this.state = {
      pending: false,
    }
  }

  render () {
    let message = this.props.message || ''
    return (
      <Screen
        title={i18n('Reply')}
        navBarStyle='light'
        navBarTitleColor={color.darkText}
        navBarButtonColor={color.link}
        rightBarButtons={[
          {
            title: i18n('Done'),
            style: 'done',
            testID: 'edit-discussion-reply.done-btn',
            action: this._actionDonePressed,
          },
        ]}
        leftBarButtons={[
          {
            title: i18n('Cancel'),
            testID: 'edit-discussion-reply.cancel-btn',
            action: this._actionCancelPressed,
          },
        ]}
      >
        <View style={{ flex: 1 }}>
          <ModalActivityIndicator text={i18n('Saving')} visible={this.state.pending} />
          <RichTextEditor
            onChangeValue={this._valueChanged('message')}
            defaultValue={message}
            showToolbar='always'
            scrollEnabled={true}
            placeholder={i18n('Message')}
            focusOnLoad={true}
            navigator={this.props.navigator}
          />
        </View>
      </Screen>
    )
  }

  componentWillReceiveProps (props: Props) {
    if (props.error) {
      this.setState({ pending: false })
      this._handleError(props.error)
      return
    }
    if (this.state.pending && !props.pending) {
      this.props.refreshDiscussionEntries(this.props.courseID, this.props.discussionID, true)
      this.props.navigator.dismissAllModals()
      return
    }
  }

  componentWillUnmount () {
    this.props.deletePendingReplies(this.props.discussionID)
  }

  _actionDonePressed = () => {
    const params = {
      message: this.state.message,
    }
    this.setState({ pending: true })
    if (this.props.isEdit) {
      this.props.editEntry(this.props.courseID, this.props.discussionID, this.props.entryID, params, this.props.indexPath)
    } else {
      this.props.createEntry(this.props.courseID, this.props.discussionID, this.props.entryID, params, this.props.indexPath, this.props.lastReplyAt)
    }
  }

  _actionCancelPressed = () => {
    this.props.navigator.dismiss()
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
}

export function mapStateToProps ({ entities }: AppState, { courseID, discussionID }: OwnProps): State {
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
export default (Connected: Component<any, Props, any>)
