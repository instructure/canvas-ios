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
import AudioComment from './AudioComment'
import SubmittedContent, { type SubmittedContentDataProps } from './SubmittedContent'
import Images from '../../../images'
import Button from 'react-native-button'
import i18n from 'format-message'
import Video from '../../../common/components/Video'

export default class CommentRow extends Component<CommentRowProps, any> {
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

  onAvatarPress = () => {
    if (this.props.onAvatarPress) {
      this.props.onAvatarPress(this.props.userID)
    }
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
        onPress={this.onAvatarPress}
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
            key={`commentRow_${i}`}
          />
        ))
      case 'media':
        switch (contents.mediaType) {
          case 'audio':
            return <AudioComment url={contents.url} from={from} />
          case 'video':
            if (!contents.url) return null
            let uri = contents.url
            if (uri.startsWith('/')) {
              uri = `file://${uri}`
            }
            return (
              <View style={{ flex: 1, height: 160 }}>
                <Video
                  source={{ uri }}
                  style={{ flex: 1 }}
                />
              </View>
            )
        }
        break
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
  | {
      type: 'media',
      mediaType: string,
      displayName: ?string,
      url: string,
    }

export type CommentRowProps = {
  error?: string,
  style?: Object,
  key: string,
  userID: string,
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
  onAvatarPress: Function,
}
