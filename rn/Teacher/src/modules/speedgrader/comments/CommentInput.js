  // @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  Image,
  TextInput,
} from 'react-native'
import Button from 'react-native-button'
import i18n from 'format-message'
import Images from '../../../images'
import colors from '../../../common/colors'
import KeyboardSpacer from 'react-native-keyboard-spacer'
import DrawerState from '../utils/drawer-state'

type CommentInputProps = {
  makeComment(comment: SubmissionCommentParams): void,
  drawerState: DrawerState,
  allowMediaComments: boolean,
}

type State = {
  textComment: string,
}

export default class CommentInput extends Component<any, CommentInputProps, any> {
  state: State

  constructor (props: CommentInputProps) {
    super(props)
    this.state = { textComment: '' }
  }

  addMedia = () => {
    console.log('Add some media!')
  }

  submitComment = () => {
    this.props.makeComment({
      type: 'text',
      message: this.state.textComment,
    })
  }

  keyboardChanged = (visible: boolean) => {
    if (visible) {
      this.props.drawerState.snapTo(2, true)
    }
  }

  onChangeText = (text: string) => {
    this.setState({ textComment: text })
  }

  render () {
    const placeholder = i18n({
      default: 'Comment',
      description: 'Placeholder text for comment input field',
    })

    const addMedia = i18n({
      default: 'Add Media',
      description: 'Attach media to a message',
    })

    return (
      <View>
        <View style={styles.toolbar}>
          {this.props.allowMediaComments &&
            <Button
              containerStyle={styles.mediaButton}
              testID='submission-comment-add-media.button'
              onPress={this.addMedia}
              accessible
              accessibilityLabel={addMedia}
              accessibilityTraits={['button']}
            >
              <Image
                resizeMode="center"
                source={Images.add}
                style={styles.plus}
              />
            </Button>
          }
          <View style={styles.inputContainer}>
            <TextInput
              autoFocus
              multiline
              testID='submission-comment.text-input'
              placeholder={placeholder}
              placeholderTextColor={colors.lightText}
              style={styles.input}
              maxHeight={76}
              onChangeText={this.onChangeText}
              value={this.state.textComment}
            />
            <Button onPress={this.submitComment} containerStyle={styles.sendButton} testID='submit-comment'>
              <Image style={styles.sendButtonArrow} source={Images.upArrow} />
            </Button>
          </View>
        </View>
        <KeyboardSpacer onToggle={this.keyboardChanged} />
    </View>
    )
  }
}

CommentInput.defaultProps = {
  allowMediaComments: true,
}

const styles = StyleSheet.create({
  mediaButton: {
    // paddingTop: 6,
    alignSelf: 'center',
  },
  plus: {
    tintColor: colors.secondaryButton,
  },
  toolbar: {
    overflow: 'hidden',
    backgroundColor: '#F5F5F5',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.seperatorColor,
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
    paddingVertical: 8,
    paddingHorizontal: global.style.defaultPadding,
  },
  inputContainer: {
    flex: 1,
    borderRadius: 20,
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: colors.seperatorColor,
    overflow: 'hidden',
    backgroundColor: 'white',
    marginLeft: 4,
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
  },
  input: {
    fontSize: 16,
    lineHeight: 19,
    marginHorizontal: 10,
    marginTop: 2,
    marginBottom: 6,
    flex: 1,
  },
  sendButton: {
    backgroundColor: colors.primaryButtonColor,
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
    tintColor: 'white',
  },
})
