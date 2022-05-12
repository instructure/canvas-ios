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

import i18n from 'format-message'
import * as React from 'react'
import {
  Image,
  LayoutAnimation,
  TouchableOpacity,
  TouchableWithoutFeedback,
  View,
} from 'react-native'
import Hyperlink from 'react-native-hyperlink'

import { getSession } from '../../../canvas-api'
import { LinkButton } from '../../../common/buttons'
import { logEvent } from '../../../common/CanvasAnalytics'
import { colors, createStyleSheet } from '../../../common/stylesheet'
import { Text } from '../../../common/text'
import Avatar from '../../../common/components/Avatar'
import Video from '../../../common/components/Video'
import Images from '../../../images'
import { personDisplayName } from '../../../common/formatters'

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

  courseID () {
    let [ contextType, contextID ] = (this.props.conversation.context_code || '').split('_')
    let { author_id } = this.props.message
    const isCurrent = author_id === getSession().user.id
    let target = this.props.conversation.participants.find(({ id }) =>
      // current user doesn't have common courses so take from any other participant
      isCurrent ? id !== author_id : id === author_id
    )
    const ids = Object.keys(target?.common_courses ?? {})
    return contextType === 'course' && ids.includes(contextID) ? contextID : ids[0]
  }

  handleAvatarPress = () => {
    this.props.navigator.show(
      `/courses/${this.courseID()}/users/${this.props.message.author_id}`,
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
    let authorName = personDisplayName(author.name, author.pronouns)
    let recipientName = ''
    if (me.id === author.id) {
      authorName = i18n('me')

      const audience = this.audience()
      if (audience.length === 1) {
        const name = personDisplayName(audience[0].name, audience[0].pronouns)
        recipientName = i18n('to {name}', { name })
      } else if (audience.length > 1) {
        recipientName = i18n('to {count} others', { count: audience.length })
      }
    } else {
      const extras = this.extraParicipipantCount()
      if (extras > 0) {
        authorName = i18n('{name} + {count, plural, one {# other} other {# others}}', {
          name: authorName,
          count: extras,
        })
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
              onPress={this.courseID() != null ? this.handleAvatarPress : undefined}
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
              <Hyperlink linkStyle={ { color: colors.linkColor } } onPress={this.handleLink}>
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

const styles = createStyleSheet((colors, vars) => ({
  container: {
    flex: 1,
    padding: vars.padding,
    paddingTop: 12,
    backgroundColor: colors.backgroundLightest,
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
  },
  bottomSpacer: {
    flex: 1,
    backgroundColor: colors.backgroundLight,
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
    height: 16,
  },
  header: {
    flex: 1,
    paddingBottom: 12,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
  },
  author: {
    fontWeight: '600',
    fontSize: 14,
    color: colors.textDarkest,
  },
  recipient: {
    fontSize: 14,
    color: colors.textDark,
  },
  dateText: {
    color: colors.textDark,
    fontSize: 12,
  },
  body: {
    flex: 1,
    paddingTop: vars.padding,
  },
  bodyText: {
    fontSize: 16,
    color: colors.textDarkest,
    lineHeight: vars.isK5Enabled ? undefined : 24, // Manually calculated 'condensed' height for 16 point font
  },
  replyButton: {
    marginTop: vars.padding / 2,
  },
  avatar: {
    width: 32,
    height: 32,
    marginRight: vars.padding / 2,
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
    tintColor: colors.textDark,
    transform: [{ rotate: '180deg' }],
  },
  attachment: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: vars.padding / 2,
  },
  attachmentIcon: {
    tintColor: colors.linkColor,
    height: 14,
    width: 14,
  },
  attachmentText: {
    color: colors.linkColor,
    fontWeight: 'bold',
    marginLeft: 4,
    fontSize: 14,
  },
}))
