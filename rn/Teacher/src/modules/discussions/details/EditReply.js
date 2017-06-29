// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import i18n from 'format-message'
import color from '../../../common/colors'
import Screen from '../../../routing/Screen'
import RichTextEditor from '../../../common/components/rich-text-editor/RichTextEditor'
import Actions from './actions'
import { ERROR_TITLE } from '../../../redux/middleware/error-handler'
import ModalActivityIndicator from '../../../common/components/ModalActivityIndicator'
import {
    View,
    LayoutAnimation,
    Alert,
} from 'react-native'

type OwnProps = {
  discussionID: string,
  courseID: string,
  parentIndexPath?: number[],
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
      this.setState({ pending: false })
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
      this.props.editEntry(this.props.courseID, this.props.discussionID, this.props.entryID, params, this.props.parentIndexPath)
    } else {
      this.props.createEntry(this.props.courseID, this.props.discussionID, this.props.entryID, params, this.props.parentIndexPath, this.props.lastReplyAt)
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
      Alert.alert(ERROR_TITLE, error)
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
  } else if (entities.discussions[discussionID] &&
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
