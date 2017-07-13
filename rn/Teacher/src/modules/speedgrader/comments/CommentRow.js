// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  Image,
  ActionSheetIOS,
} from 'react-native'
import Avatar from '../../../common/components/Avatar'
import { formattedDueDate } from '../../../common/formatters'
import {
  Heading1,
  Paragraph,
} from '../../../common/text'
import ChatBubble from './ChatBubble'
import SubmittedContent, { type SubmittedContentDataProps } from './SubmittedContent'
import Images from '../../../images'
import Button from 'react-native-button'
import i18n from 'format-message'

export default class CommentRow extends Component<any, CommentRowProps, any> {
  showFailedOptions = () => {
    ActionSheetIOS.showActionSheetWithOptions({
      options: [i18n('Retry'), i18n('Delete'), i18n('Cancel')],
      cancelButtonIndex: 2,
      destructiveButtonIndex: 1,
      title: i18n('Failed comment options'),
    }, (index) => {
      if (index === 2) return
      if (index === 0) {
        this.props.retryPendingComment(this.props.contents)
      }
      this.props.deletePendingComment(this.props.localID)
    })
  }

  renderHeader = () => {
    let usOrThem = styles.theirHeader
    let textAlignment = styles.theirText
    if (this.props.from === 'me') {
      textAlignment = styles.myText
      usOrThem = styles.myHeader
    }

    let name = this.props.name
    let avatarURL = this.props.avatarURL
    if (this.props.from === 'them' && this.props.anonymous) {
      name = i18n('Student')
      avatarURL = null
    }

    const nameAndDate =
      <View key="1" style={styles.nameAndDate}>
        <Heading1 style={[textAlignment, styles.title]}>
          {name}
        </Heading1>
        <Paragraph style={[textAlignment, styles.subtitle]}>
          {formattedDueDate(this.props.date)}
        </Paragraph>
      </View>

    const avatar =
      <Avatar
        key="0"
        avatarURL={avatarURL}
        userName={name}
      />

    const headerContent = [avatar, nameAndDate]

    return (
      <View style={[styles.header, usOrThem]} >
        {this.props.from === 'me'
          ? headerContent.reverse()
          : headerContent }
      </View>
    )
  }

  renderContents = () => {
    const { contents, from } = this.props
    switch (contents.type) {
      case 'text':
        return <ChatBubble from={from} message={contents.message} />
      case 'submission':
        return contents.items.map((content, i) => (
          <SubmittedContent
            {...content}
            attemptIndex={contents.attemptIndex}
            attachmentIndex={i}
            onPress={this.props.switchFile}
            submissionID={contents.submissionID}
          />
          ))
      default:
        return undefined // TODO: other message content types
    }
  }

  renderRetry = () => {
    if (this.props.from !== 'me') return

    if (this.props.error) {
      return (
        <Button onPress={this.showFailedOptions}>
          <Image
            accessibilityLabel={i18n('Failed comment options')}
            source={Images.speedGrader.warning}
          />
        </Button>
      )
    }

    return <View />
  }

  render () {
    return (
      <View style={[styles.row, this.props.style]}>
        {this.renderHeader()}
        <View style={styles.contents}>
          {this.renderRetry()}
          {this.renderContents()}
        </View>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  row: {
    paddingHorizontal: global.style.defaultPadding,
    paddingVertical: 8,
  },
  contents: {
    paddingTop: 4,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    flexWrap: 'wrap',
  },
  title: {
    fontSize: 16,
  },
  subtitle: {
    fontSize: 12,
    lineHeight: undefined,
  },
  myText: {
    textAlign: 'right',
  },
  theirText: {
    textAlign: 'left',
  },
  myHeader: {
    justifyContent: 'flex-end',
  },
  theirHeader: {
    justifyContent: 'flex-start',
  },
  nameAndDate: {
    paddingHorizontal: 8,
    justifyContent: 'center',
  },
  header: {
    flex: 1,
    paddingTop: 6,
    flexDirection: 'row',
  },
})

export type CommentContent = { type: 'text', message: string }
  | {
      type: 'submission',
      items: Array<SubmittedContentDataProps>,
      attemptIndex: number,
      submissionID: string,
    }

export type CommentRowProps = {
  error?: string,
  style?: Object,
  key: string,
  name: string,
  date: Date,
  avatarURL: string,
  from: 'me' | 'them',
  contents: CommentContent,
  pending: number,
  localID: string,
  deletePendingComment: (string) => void,
  retryPendingComment: (CommentContent) => void,
  switchFile: (string, number, number) => void,
}
