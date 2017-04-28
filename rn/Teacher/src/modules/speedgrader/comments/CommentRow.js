// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import Avatar from '../../../common/components/Avatar'
import { formattedDueDate } from '../../../common/formatters'
import {
  Heading1,
  Paragraph,
} from '../../../common/text'
import ChatBubble from './ChatBubble'

export default class CommentRow extends Component<any, CommentRowProps, any> {
  renderHeader = () => {
    let usOrThem = styles.theirHeader
    let textAlignment = styles.theirText
    if (this.props.from === 'me') {
      textAlignment = styles.myText
      usOrThem = styles.myHeader
    }

    const nameAndDate =
      <View key="1" style={styles.nameAndDate}>
        <Heading1 style={[textAlignment, styles.title]}>
          {this.props.name}
        </Heading1>
        <Paragraph style={[textAlignment, styles.subtitle]}>
          {formattedDueDate(this.props.date)}
        </Paragraph>
      </View>

    const avatar =
      <Avatar
        key="0"
        avatarURL={this.props.avatarURL}
        userName={this.props.name}
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
      case 'comment':
        return <ChatBubble from={from} message={contents.message} />
      default:
        return undefined // TODO: other message content types
    }
  }

  render () {
    return (
      <View style={[styles.row, this.props.style]}>
        {this.renderHeader()}
        {this.renderContents()}
      </View>
    )
  }
}

const styles = StyleSheet.create({
  row: {
    paddingHorizontal: global.style.defaultPadding,
    paddingVertical: 8,
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

export type CommentRowProps = {
  style?: Object,
  key: string,
  name: string,
  date: Date,
  avatarURL: string,
  from: 'me' | 'them',
  contents: { type: 'comment', message: string }
          | { type: 'media_comment' } // TODO
          | { type: 'submission' }, // TODO
}
