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
import {
  View,
  Image,
  TextInput,
  TouchableOpacity,
} from 'react-native'
import i18n from 'format-message'
import Images from '../../../images'
import { colors, createStyleSheet } from '../../../common/stylesheet'
import KeyboardSpacer from 'react-native-keyboard-spacer'
import DrawerState from '../utils/drawer-state'
import { getBottomSpace } from 'react-native-iphone-x-helper'

export type Comment
  = { type: 'text', comment: string }

type CommentInputProps = {
  makeComment(comment: Comment): void,
  drawerState: DrawerState,
  addMedia?: () => void,
  initialValue: ?string,
  disabled?: boolean,
  autoFocus?: boolean,
  onBlur?: () => void,
}

type State = {}
type PersistentComment = { text: string }

export default class CommentInput extends Component<CommentInputProps, State> {
  static defaultProps = {
    disabled: false,
  }
  static persistentComment: PersistentComment = { text: '' }
  _textInput: TextInput

  constructor (props: any) {
    super(props)
    if (this.props.initialValue && this.props.initialValue.length > 0) {
      CommentInput.persistentComment.text = this.props.initialValue
    }
  }

  makeComment = () => {
    let text = CommentInput.persistentComment.text
    if (!text || text.length === 0) {
      return
    }
    CommentInput.persistentComment.text = ''
    this.forceUpdate()
    this._textInput.blur()

    this.props.makeComment({
      type: 'text',
      comment: text,
    })
  }

  keyboardChanged = (visible: boolean) => {
    if (visible) {
      this.props.drawerState.snapTo(2, true)
    }
  }

  textChanged = (text: string) => {
    CommentInput.persistentComment.text = text
    this.forceUpdate()
  }

  onBlur = () => {
    this.props.onBlur && this.props.onBlur()
  }

  captureTextInput = (textInput: any) => {
    this._textInput = textInput
  }

  render () {
    const placeholder = i18n('Comment')

    const addMedia = i18n('Add Media')

    const send = i18n('Send')

    const disableSend = !CommentInput.persistentComment.text || CommentInput.persistentComment.text.length === 0 || this.props.disabled

    return (
      <View>
        <View style={styles.toolbar}>
          { Boolean(this.props.addMedia) &&
            <TouchableOpacity
              style={styles.mediaButton}
              testID='SubmissionComments.addMediaButton'
              onPress={this.props.addMedia}
              accessible
              accessibilityLabel={addMedia}
              accessibilityTraits={['button']}
              hitSlop={{ top: 11, right: 11, bottom: 11, left: 11 }}
            >
              <Image
                resizeMode="center"
                source={Images.add}
                style={styles.plus}
              />
            </TouchableOpacity>
          }
          <View style={styles.inputContainer}>
            <TextInput
              autoFocus={
                (typeof (jest) === 'undefined') &&
                this.props.autoFocus != null &&
                this.props.autoFocus
              }
              multiline
              testID='SubmissionComments.commentTextView'
              placeholder={placeholder}
              placeholderTextColor={colors.textDark}
              style={styles.input}
              maxHeight={76}
              onChangeText={this.textChanged}
              ref={this.captureTextInput}
              value={CommentInput.persistentComment.text}
              onBlur={this.onBlur}
            />
            {
              CommentInput.persistentComment.text != null &&
              CommentInput.persistentComment.text.length > 0 &&
              <TouchableOpacity
                style={styles.sendButton}
                testID='SubmissionComments.addCommentButton'
                onPress={!disableSend ? this.makeComment : null}
                accessibilityLabel={send}
                accessibilityTraits={['button']}
                activeOpacity={disableSend ? 1 : 0.2}
                hitSlop={{ top: 10, right: 10, bottom: 10, left: 10 }}
              >
                <Image
                  style={styles.sendButtonArrow}
                  source={Images.upArrow}
                />
              </TouchableOpacity>
            }
          </View>
        </View>
        <KeyboardSpacer topSpacing={-getBottomSpace()} onToggle={this.keyboardChanged} />
      </View>
    )
  }
}

const styles = createStyleSheet((colors, vars) => ({
  mediaButton: {
    alignSelf: 'center',
    paddingHorizontal: 11,
  },
  plus: {
    tintColor: colors.textDark,
  },
  toolbar: {
    overflow: 'hidden',
    backgroundColor: colors.backgroundLight,
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
    paddingVertical: 8,
    paddingRight: vars.padding,
  },
  inputContainer: {
    flex: 1,
    borderRadius: 20,
    borderWidth: vars.hairlineWidth,
    borderColor: colors.borderMedium,
    overflow: 'hidden',
    backgroundColor: colors.backgroundLightest,
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
  },
  input: {
    fontSize: 16,
    lineHeight: 19,
    marginLeft: 10,
    marginRight: 24,
    marginTop: 2,
    marginBottom: 6,
    flex: 1,
  },
  sendButton: {
    backgroundColor: colors.buttonPrimaryBackground,
    width: 24,
    height: 24,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    flex: 0,
    marginTop: 4,
    marginRight: 4,
  },
  sendButtonArrow: {
    tintColor: colors.buttonPrimaryText,
    marginBottom: 1,
  },
}))
