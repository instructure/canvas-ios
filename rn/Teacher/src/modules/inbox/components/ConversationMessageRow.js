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
import { getSession } from '../../../api/session'
import i18n from 'format-message'
import find from 'lodash/find'
import { formattedDate } from '../../../utils/dateUtils'
import Images from '../../../images'
import { LinkButton } from '../../../common/buttons'

export type ConversationMessageProps = {
  conversation: Conversation,
  message: ConversationMessage,
  firstMessage: boolean,
  onReplyButtonPressed: Function,
  navigator: Navigator,
}

export default class ConversationMessageRow extends Component<any, ConversationMessageProps, any> {

  constructor (props: ConversationMessageProps) {
    super(props)
    this.state = {
      expanded: this.props.firstMessage,
    }
  }

  _replyButtonPressed = () => {
    this.props.onReplyButtonPressed(this.props.message.id)
  }

  _showAttachment = (attachment: Attachment) => {
    this.props.navigator.show('/attachment', { modal: true }, { attachment })
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
    const me = (getSession() || {}).user
    const author = this._author()
    const participants = this.props.conversation.participants
    return participants.filter((p) => {
      return p.id !== me.id && p.id !== author.id
    }).length
  }

  _renderHeader = () => {
    const me = (getSession() || {}).user
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
      const extras = this._extraParicipipantCount()
      if (extras > 0) {
        authorName = i18n('{name} + {count} others', { name: authorName, count: extras })
      }
      recipientName = i18n('to me')
    }

    return (<View style={styles.header}>
              <View style={{ flexDirection: 'row' }}>
                <View style={styles.avatar}>
                    <Avatar height={32} avatarURL={author.avatar_url} userName={author.name}/>
                  </View>
                <View>
                  <Text>
                    <Text style={styles.author}>{`${authorName} `}</Text>
                    <Text style={styles.recipient}>{recipientName}</Text>
                  </Text>
                  <Text style={styles.dateText}>{formattedDate(message.created_at)}</Text>
                </View>
              </View>
              { this._renderKabob() }
            </View>)
  }

  render () {
    const message = this.props.message
    return (<View>
              <TouchableWithoutFeedback testID={`inbox.conversation-message-${message.id}`} onPress={this._toggleExpanded}>
                  <View style={styles.container}>
                    { this._renderHeader() }
                    <View style={styles.body}>
                      <Text style={styles.bodyText} numberOfLines={this.state.expanded ? 0 : 2}>{message.body}</Text>
                    </View>
                    { this.props.message.attachments &&
                      this.props.message.attachments.map((attachment, index) => {
                        return (<TouchableOpacity testID={`inbox.conversation-message-${message.id}.attachment-${attachment.id}`} onPress={() => {
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
                    { this.props.firstMessage &&
                      <LinkButton onPress={this._replyButtonPressed}
                                  style={styles.replyButton}>{i18n('Reply')}</LinkButton>}
                  </View>
              </TouchableWithoutFeedback>
              <View style={styles.bottomSpacer} />
            </View>)
  }

  _renderKabob = () => {
    return (
      <TouchableOpacity
          style={styles.kabobButton}
          accessibilityTraits='button'
          accessible={true}
          accessibilityLabel={i18n('Message options')}
          underlayColor='#ffffff00'
          testID={`conversation-message.kabob-${this.props.message.id}`}
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
