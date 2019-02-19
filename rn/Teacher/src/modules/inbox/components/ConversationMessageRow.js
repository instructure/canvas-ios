//
// Copyright (C) 2017-present Instructure, Inc.
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

import i18n from 'format-message'
import * as React from 'react'
import {
  Image,
  LayoutAnimation,
  StyleSheet,
  TouchableOpacity,
  TouchableWithoutFeedback,
  View,
} from 'react-native'
import Hyperlink from 'react-native-hyperlink'

import { getSession } from '../../../canvas-api'
import { LinkButton } from '../../../common/buttons'
import { logEvent } from '../../../common/CanvasAnalytics'
import color from '../../../common/colors'
import { Text, BOLD_FONT } from '../../../common/text'
import Avatar from '../../../common/components/Avatar'
import Video from '../../../common/components/Video'
import Images from '../../../images'

type Props = {
  conversation: Conversation,
  message: ConversationMessage,
  firstMessage: boolean,
  showOptionsActionSheet: (string) => any,
  navigator: Navigator,
  onReply: (string) => any,
}

type State = {
  expanded: boolean,
}

export default class ConversationMessageRow extends React.Component<Props, State> {
  state = {
    expanded: this.props.firstMessage,
  }

  handleReplyPress = () => {
    logEvent('inbox_message_replied')
    this.props.onReply(this.props.message.id)
  }

  handleAvatarPress = () => {
    let courseID = this.props.conversation.context_code.split('_')[1]
    this.props.navigator.show(
      `/courses/${courseID}/users/${this.props.message.author_id}`,
      { modal: true, modalPresentationStyle: 'currentContext' }
    )
  }

  handleLink = (link: string) => {
    this.props.navigator.show(link, { deepLink: true })
  }

  showAttachment = (attachment: Attachment) => {
    this.props.navigator.show('/attachment', { modal: true }, { attachment })
  }

  showActionSheet = () => {
    this.props.showOptionsActionSheet(this.props.message.id)
  }

  toggleExpanded = () => {
    LayoutAnimation.easeInEaseOut()
    this.setState({
      expanded: !this.state.expanded,
    })
  }

  author (): ConversationParticipant {
    const convo = this.props.conversation
    const message = this.props.message
    // $FlowFixMe we know the author will always be in participants
    return convo.participants.find(({ id }) => id === message.author_id)
  }

  audience (): ConversationParticipant[] {
    const me = getSession().user.id
    const { audience, participants } = this.props.conversation
    const to = this.props.message.participating_user_ids || audience
    return participants.filter(p => p.id !== me && to.includes(p.id))
  }

  // The count of participants minus the author and me
  extraParicipipantCount (): number {
    const me = getSession().user.id
    const author = this.author().id
    return (
      this.props.message.participating_user_ids ||
      this.props.conversation.participants.map(p => p.id)
    ).filter(id => id !== me && id !== author).length
  }

  renderHeader () {
    const me = getSession().user
    const message = this.props.message
    const author = this.author()
    let authorName = author.name
    let recipientName = ''
    if (me.id === author.id) {
      authorName = i18n('me')

      const audience = this.audience()
      if (audience.length === 1) {
        recipientName = i18n('to {name}', { name: audience[0].name })
      } else if (audience.length > 1) {
        recipientName = i18n('to {count} others', { count: audience.length })
      }
    } else {
      const extras = this.extraParicipipantCount()
      if (extras > 0) {
        authorName = i18n('{name} + {count, plural, one {# other} other {# others}}', { name: authorName, count: extras })
      }
      recipientName = i18n('to me')
    }
    const date = i18n("{ date, date, 'MMM d' } at { date, time, short }", { date: new Date(message.created_at) })

    return (
      <View style={styles.header}>
        <View style={{ flexDirection: 'row', flex: 1 }} accessible={true} accessibilityLabel={`${authorName} ${recipientName} ${date}`}>
          <View style={styles.avatar}>
            <Avatar
              height={32}
              avatarURL={author.avatar_url}
              userName={author.name}
              onPress={this.props.conversation.context_code ? this.handleAvatarPress : undefined}
            />
          </View>
          <View style={{ flex: 1 }}>
            <Text numberOfLines={1}>
              <Text style={styles.author}>{`${authorName} `}</Text>
              <Text style={styles.recipient}>{recipientName}</Text>
            </Text>
            <Text style={styles.dateText}>{date}</Text>
          </View>
        </View>
        { this.renderKabob() }
      </View>
    )
  }

  render () {
    const message = this.props.message
    return (
      <View testID={`inbox.conversation-message-${message.id}`} style={{ flex: 1 }}>
        <View style={styles.container}>
          { this.renderHeader() }
          <TouchableWithoutFeedback onPress={this.toggleExpanded}>
            <View style={styles.body}>
              <Hyperlink linkStyle={ { color: '#2980b9' } } onPress={this.handleLink}>
                <Text style={styles.bodyText} numberOfLines={this.state.expanded ? 0 : 2}>{message.body}</Text>
              </Hyperlink>
            </View>
          </TouchableWithoutFeedback>
          { this.props.message.attachments &&
            this.props.message.attachments.map((attachment, index) => {
              return (<TouchableOpacity testID={`inbox.conversation-message-${message.id}.attachment-${attachment.id}`} key={attachment.id} onPress={() => {
                this.showAttachment(attachment)
              }}>
                <View style={styles.attachment}>
                  <Image source={Images.paperclip} style={styles.attachmentIcon} />
                  <Text style={styles.attachmentText}>
                    {attachment.display_name}
                  </Text>
                </View>
              </TouchableOpacity>)
            })
          }
          { this.props.message.media_comment &&
              <View style={{ flex: 1, height: 160 }}>
                <Video
                  source={{ uri: this.props.message.media_comment.url }}
                  style={{ flex: 1 }}
                />
              </View>}
          <LinkButton
            testID='inbox.conversation-message-row.reply-button'
            onPress={this.handleReplyPress}
            style={styles.replyButton}
          >
            {i18n('Reply')}
          </LinkButton>
        </View>
      </View>
    )
  }

  renderKabob () {
    return (
      <TouchableOpacity
        style={styles.kabobButton}
        accessibilityTraits='button'
        accessible
        accessibilityLabel={i18n('Message options')}
        underlayColor='#ffffff00'
        testID={`conversation-message.kabob-${this.props.message.id}`}
        onPress={this.showActionSheet}
        hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
      >
        <Image style={styles.kabob} source={Images.kabob}/>
      </TouchableOpacity>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: global.style.defaultPadding,
    paddingTop: 12,
    backgroundColor: 'white',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: color.seperatorColor,
  },
  bottomSpacer: {
    flex: 1,
    backgroundColor: '#F5F5F5',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: color.seperatorColor,
    height: 16,
  },
  header: {
    flex: 1,
    paddingBottom: 12,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: color.seperatorColor,
  },
  author: {
    fontWeight: '600',
    fontSize: 14,
    color: color.darkText,
  },
  recipient: {
    fontSize: 14,
    color: color.grey4,
  },
  dateText: {
    color: color.grey4,
    fontSize: 12,
  },
  body: {
    flex: 1,
    paddingTop: global.style.defaultPadding,
  },
  bodyText: {
    fontSize: 16,
    color: color.darkText,
  },
  replyButton: {
    marginTop: global.style.defaultPadding / 2,
  },
  avatar: {
    width: 32,
    height: 32,
    marginRight: global.style.defaultPadding / 2,
  },
  kabobButton: {
    justifyContent: 'center',
    alignItems: 'flex-end',
    width: 24,
    height: 24,
  },
  kabob: {
    width: 18,
    height: 18,
    margin: 3,
    tintColor: color.grey4,
    transform: [{ rotate: '180deg' }],
  },
  attachment: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: global.style.defaultPadding / 2,
  },
  attachmentIcon: {
    tintColor: color.link,
    height: 14,
    width: 14,
  },
  attachmentText: {
    color: color.link,
    fontFamily: BOLD_FONT,
    marginLeft: 4,
    fontSize: 14,
  },
})
