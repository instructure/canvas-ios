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
        <View style={styles.toolbar} >
          <Button
            containerStyle={styles.mediaButton}
            testID='submission-comment.add-media'
            onPress={this.addMedia}
            accessible
            accessibilityTraits={['button']}
            accessibilityLabel={addMedia}
          >
            <Image
              resizeMode="center"
              source={Images.add}
              style={styles.plus}
            />
          </Button>
          <View style={styles.inputContainer} >
            <TextInput
              autoFocus
              multiline
              testID='submission-comment.text-input'
              placeholder={placeholder}
              placeholderTextColor={colors.lightText}
              style={styles.input}
              maxHeight={76}
              onSubmitEditing={this.submitComment}
            />
          </View>
        </View>
        <KeyboardSpacer onToggle={this.keyboardChanged} />
      </View>
    )
  }
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
  },
  input: {
    fontSize: 17,
    marginHorizontal: 10,
    marginTop: 0,
    marginBottom: 4,
  },
})
