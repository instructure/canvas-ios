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
  TouchableWithoutFeedback,
  TouchableOpacity,
  LayoutAnimation,
  Image,
} from 'react-native'

import {
  Text,
  BOLD_FONT,
} from '../../../common/text'
import Avatar from '../../../common/components/Avatar'
import color from '../../../common/colors'
import { getSession } from '../../../canvas-api'
import i18n from 'format-message'
import find from 'lodash/find'
import Images from '../../../images'
import Video from '../../../common/components/Video'
import { LinkButton } from '../../../common/buttons'
import Hyperlink from 'react-native-hyperlink'

export type ConversationMessageProps = {
  conversation: Conversation,
  message: ConversationMessage,
  firstMessage: boolean,
  onReplyButtonPressed: Function,
  showOptionsActionSheet: Function,
  navigator: Navigator,
}

export default class ConversationMessageRow extends Component<ConversationMessageProps, any> {
  constructor (props: ConversationMessageProps) {
    super(props)
    this.state = {
      expanded: this.props.firstMessage,
    }
  }

  _replyButtonPressed = () => {
    this.props.navigator.show(`/conversations/${this.props.conversation.id}/add_message`, { modal: true }, {
      recipients: this.props.conversation.participants.filter(p => this.props.conversation.audience.includes(p.id)),
      contextName: this.props.conversation.context_name,
      contextCode: this.props.conversation.context_code,
      subject: this.props.conversation.subject,
      canSelectCourse: false,
      canEditSubject: false,
      navBarTitle: i18n('Reply'),
    })
  }

  onAvatarPress = () => {
    let courseID = this.props.conversation.context_code.split('_')[1]
    this.props.navigator.show(
      `/courses/${courseID}/users/${this.props.message.author_id}`,
      { modal: true, modalPresentationStyle: 'currentContext' }
    )
  }

  handleLink = (link: string) => {
    this.props.navigator.show(link, { deepLink: true })
  }

  _showAttachment = (attachment: Attachment) => {
    this.props.navigator.show('/attachment', { modal: true }, { attachment })
  }

  _showActionSheet = () => {
    this.props.showOptionsActionSheet(this.props.message.id)
  }

  _toggleExpanded = () => {
    LayoutAnimation.easeInEaseOut()
    this.setState({
      expanded: !this.state.expanded,
    })
  }

  _author = (): ConversationParticipant => {
    const convo = this.props.conversation
    const message = this.props.message
    return find(convo.participants, { id: message.author_id })
  }

  _audience = (): ConversationParticipant[] => {
    const participants = this.props.conversation.participants
    const audience = this.props.conversation.audience
    return audience.map((id) => find(participants, { id })).filter((a) => a)
  }

  // The count of participants minus the author and me
  _extraParicipipantCount = (): number => {
    const me = getSession().user
    const author = this._author()
    const participants = this.props.conversation.participants
    return participants.filter((p) => {
      return p.id !== me.id && p.id !== author.id
    }).length
  }

  _renderHeader = () => {
    const me = getSession().user
    const message = this.props.message
    const author = this._author()
    let authorName = author.name
    let recipientName = ''
    if (me.id === author.id) {
      authorName = i18n('me')

      const audience = this._audience()
      if (audience.length === 1) {
        recipientName = i18n('to {name}', { name: audience[0].name })
      } else if (audience.length > 1) {
        recipientName = i18n('to {count} others', { count: audience.length })
      }
    } else {
      const extras = (this._extraParicipipantCount() - 1)
      if (extras > 0) {
        authorName = i18n('{name} + {count, plural, one {# other} other {# others}}', { name: authorName, count: extras })
      }
      recipientName = i18n('to me')
    }
    const date = i18n("{ date, date, 'MMM d' } at { date, time, short }", { date: new Date(message.created_at) })

    return (<View style={styles.header}>
      <View style={{ flexDirection: 'row' }} accessible={true} accessibilityLabel={`${authorName} ${recipientName} ${date}`}>
        <View style={styles.avatar}>
          <Avatar
            height={32}
            avatarURL={author.avatar_url}
            userName={author.name}
            onPress={this.props.conversation.context_code ? this.onAvatarPress : undefined}
          />
        </View>
        <View>
          <Text>
            <Text style={styles.author}>{`${authorName} `}</Text>
            <Text style={styles.recipient}>{recipientName}</Text>
          </Text>
          <Text style={styles.dateText}>{date}</Text>
        </View>
      </View>
      { this._renderKabob() }
    </View>)
  }

  render () {
    const message = this.props.message
    return (
      <View testID={`inbox.conversation-message-${message.id}`}>
        <View style={styles.container}>
          { this._renderHeader() }
          <TouchableWithoutFeedback onPress={this._toggleExpanded}>
            <View style={styles.body}>
              <Hyperlink linkStyle={ { color: '#2980b9' } } onPress={this.handleLink}>
                <Text style={styles.bodyText} numberOfLines={this.state.expanded ? 0 : 2}>{message.body}</Text>
              </Hyperlink>
            </View>
          </TouchableWithoutFeedback>
          { this.props.message.attachments &&
            this.props.message.attachments.map((attachment, index) => {
              return (<TouchableOpacity testID={`inbox.conversation-message-${message.id}.attachment-${attachment.id}`} key={`inbox.conversation-message-${message.id}.attachment-${attachment.id}`} onPress={() => {
                this._showAttachment(attachment)
              }}>
                <View style={styles.attachment}>
                  <Image source={Images.attachment} style={styles.attachmentIcon} />
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
          { this.props.firstMessage &&
            <LinkButton
              testID='inbox.conversation-message-row.reply-button'
              onPress={this._replyButtonPressed}
              style={styles.replyButton}
              textStyle={styles.replyButtonText}
            >
              {i18n('Reply')}
            </LinkButton>
          }
        </View>
      </View>
    )
  }

  _renderKabob = () => {
    return (
      <TouchableOpacity
        style={styles.kabobButton}
        accessibilityTraits='button'
        accessible
        accessibilityLabel={i18n('Message options')}
        underlayColor='#ffffff00'
        testID={`conversation-message.kabob-${this.props.message.id}`}
        onPress={this._showActionSheet}
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
  replyButtonText: {
    fontSize: 16,
    fontWeight: '500',
  },
  avatar: {
    width: 32,
    height: 32,
    marginRight: global.style.defaultPadding / 2,
  },
  kabobButton: {
    justifyContent: 'center',
    alignItems: 'flex-end',
    width: 32,
    height: 32,
  },
  kabob: {
    width: 18,
    height: 18,
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
  },
  attachmentText: {
    color: color.link,
    fontFamily: BOLD_FONT,
    marginLeft: 6,
    fontSize: 14,
  },
})
