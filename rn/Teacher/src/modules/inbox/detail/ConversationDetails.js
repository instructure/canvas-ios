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

import * as React from 'react'
import {
  Appearance,
  View,
  FlatList,
  TouchableOpacity,
  Image,
  ActionSheetIOS,
  Alert,
} from 'react-native'
import { connect } from 'react-redux'
import refresh from '../../../utils/refresh'
import InboxActions from '../actions'
import Screen from '../../../routing/Screen'
import { createStyleSheet } from '../../../common/stylesheet'
import i18n from 'format-message'
import ConversationMessageRow from '../components/ConversationMessageRow'
import { Heading1 } from '../../../common/text'
import Images from '../../../images'
import icon from '../../../images/inst-icons'
import RowSeparator from '../../../common/components/rows/RowSeparator'
import { getSession } from '../../../canvas-api'
import type { EventSubscription } from 'react-native/Libraries/vendor/emitter/EventEmitter'
import type { AppearancePreferences } from 'react-native/Libraries/Utilities/NativeAppearance'

export type ConversationOwnProps = {
  conversation?: ?Conversation,
  conversationID: string,
  messages: ConversationMessage[],
  pending?: boolean,
  error?: ?string,
}

export type RefreshProps = {
  refresh?: Function,
  refreshing?: boolean,
  refreshConversationDetails: Function,
  starConversation: Function,
  unstarConversation: Function,
  markAsRead: Function,
}

type Props =
  ConversationOwnProps &
  RefreshProps &
  NavigationProps &
  typeof InboxActions

type State = {
  deletePending: boolean,
}

export class ConversationDetails extends React.Component <Props, State> {
  state = {
    deletePending: false,
  }
  _appearanceChangeSubscription: ?EventSubscription

  componentDidMount () {
    if (this.props.conversation && this.props.conversation.workflow_state === 'unread') {
      this.props.markAsRead(this.props.conversationID)
    }

    this._appearanceChangeSubscription = Appearance.addChangeListener(
      (preferences: AppearancePreferences) => {
        this.setState(this.state)
      },
    )
  }

  componentWillUnmount () {
      this._appearanceChangeSubscription?.remove()
  }

  UNSAFE_componentWillReceiveProps (nextProps: Props) {
    if (this.state.deletePending && !nextProps.pending && !nextProps.conversation) {
      this.setState({ deletePending: false })
      this.close()
    }

    if (this.props.conversation && !nextProps.conversation) {
      this.close()
    }
  }

  close () {
    if (this.props.navigator.isModal) {
      this.props.navigator.dismiss()
    } else {
      this.props.navigator.pop()
    }
  }

  keyExtractor (item: ConversationMessage) {
    return item.id
  }

  renderItem = ({ item, index }: { item: ConversationMessage, index: number }) => {
    if (!this.props.conversation) return <View />
    return (
      <ConversationMessageRow
        navigator={this.props.navigator}
        message={item}
        conversation={this.props.conversation}
        firstMessage={index === 0}
        showOptionsActionSheet={this.showOptionsActionSheet}
        onReply={this.reply}
      />
    )
  }

  toggleStarred = () => {
    if (!this.props.conversation) return
    if (this.props.conversation.starred) {
      this.props.unstarConversation(this.props.conversationID)
    } else {
      this.props.starConversation(this.props.conversationID)
    }
  }

  renderHeader () {
    if (!this.props.conversation) return <View />

    const starred = this.props.conversation.starred
    const star = icon('star', starred ? 'solid' : 'line')

    return (
      <View style={styles.header}>
        <Heading1>{this.props.conversation.subject || i18n('No Subject')}</Heading1>
        <TouchableOpacity
          accessibilityLabel={starred ? i18n('Starred') : i18n('Un-starred')}
          accessibilityTraits='button'
          testID={`inbox.detail.${starred ? 'starred' : 'not-starred'}`}
          focusedOpacity={0.7}
          onPress={this.toggleStarred}
          hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
        >
          <Image source={star} style={styles.star} />
        </TouchableOpacity>
      </View>
    )
  }

  render () {
    return (
      <Screen
        navBarStyle='global'
        drawUnderNavBar
        customPageViewPath='/conversations'
        title={i18n('Message Details')}
        rightBarButtons={[
          {
            image: Images.kabob,
            testID: 'inbox.detail.options.button',
            action: this.showOptionsActionSheet,
            accessibilityLabel: i18n('Conversation options'),
          },
        ]}
      >
        <View style={styles.container}>
          <FlatList
            style={styles.list}
            data={this.props.messages.filter(message => !message.pendingDelete)}
            renderItem={this.renderItem}
            ListHeaderComponent={this.renderHeader()}
            refreshing={this.props.refreshing}
            onRefresh={this.props.refresh}
            ItemSeparatorComponent={RowSeparator}
            keyExtractor={this.keyExtractor}
          />
        </View>
      </Screen>
    )
  }

  showOptionsActionSheet = (id?: string) => {
    const options = [
      i18n('Reply'),
      i18n('Reply All'),
      i18n('Forward'),
      i18n('Delete'),
      i18n('Cancel'),
    ]
    ActionSheetIOS.showActionSheetWithOptions(
      {
        options,
        destructiveButtonIndex: options.length - 2,
        cancelButtonIndex: options.length - 1,
      },
      this.handleOptionsActionSheet.bind(this, id)
    )
  }

  handleOptionsActionSheet (id: ?string, index: number) {
    switch (index) {
      case 0: return this.reply(id)
      case 1: return this.replyAll(id)
      case 2: return this.forwardMessage(id)
      case 3: return id
        ? this.deleteConversationMessage(id)
        : this.deleteConversation(this.props.conversationID)
    }
  }

  getReplyRecipients (id: ?string) {
    if (!this.props.conversation) return []
    const { participants } = this.props.conversation
    const message = this.props.messages.find(m => m.id === id) || this.props.messages[0]
    const author = message && message.author_id
    return author !== getSession().user.id
      ? participants.filter(p => p.id === author)
      : this.getReplyAllRecipients()
  }

  reply = (id: ?string) => {
    const { conversation } = this.props
    if (!conversation) return
    this.props.navigator.show(
      `/conversations/${this.props.conversationID}/add_message`,
      { modal: true },
      {
        recipients: this.getReplyRecipients(id),
        contextName: conversation.context_name,
        contextCode: conversation.context_code,
        subject: conversation.subject,
        canSelectCourse: false,
        canEditSubject: false,
        navBarTitle: i18n('Reply'),
      }
    )
  }

  getReplyAllRecipients (id: ?string) {
    if (!this.props.conversation) return []
    const { audience, participants } = this.props.conversation
    const message = this.props.messages.find(m => m.id === id)
    const to = (message && message.participating_user_ids) || audience
    const me = getSession().user.id
    return participants.filter(p => p.id !== me && to.includes(p.id))
  }

  replyAll (id: ?string) {
    const { conversation } = this.props
    if (!conversation) return
    this.props.navigator.show(
      `/conversations/${this.props.conversationID}/add_message`,
      { modal: true },
      {
        recipients: this.getReplyAllRecipients(id),
        contextName: conversation.context_name,
        contextCode: conversation.context_code,
        subject: conversation.subject,
        canSelectCourse: false,
        canEditSubject: false,
        navBarTitle: i18n('Reply'),
      }
    )
  }

  forwardMessage (id: ?string) {
    let conversation = this.props.conversation || {}
    if (!conversation.context_code) {
      return Alert.alert(
        i18n('Can not forward message'),
        i18n('That message can not be forwarded.')
      )
    }

    this.props.navigator.show(`/conversations/${conversation.id}/add_message`, {
      modal: true,
    }, {
      contextName: conversation.context_name,
      contextCode: conversation.context_code,
      subject: i18n('Fw: {subject}', {
        subject: conversation.subject,
      }),
      canEditSubject: false,
      showCourseSelect: false,
      includedMessages: id
        ? this.props.messages.filter(message => message.id === id)
        : this.props.messages,
      navBarTitle: i18n('Forward'),
      requireMessageBody: false,
    })
  }

  deleteConversation (id: string) {
    this.setState({ deletePending: true })
    this.props.deleteConversation(id)
  }

  deleteConversationMessage (id: string) {
    this.props.deleteConversationMessage(this.props.conversationID, id)
  }
}

const styles = createStyleSheet((colors, vars) => ({
  container: {
    flex: 1,
    backgroundColor: colors.backgroundLight,
  },
  loading: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  list: {
    backgroundColor: colors.backgroundLight,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: colors.backgroundLightest,
    padding: vars.padding,
    paddingBottom: vars.padding / 2,
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
  },
  star: {
    tintColor: colors.primary,
    height: 24,
    width: 24,
  },
}))

export function mapStateToProps (state: AppState, props: any) {
  const inbox = state.inbox
  const conversationID = props.conversationID
  const convoState = inbox.conversations[conversationID]
  let messages = []
  let conversation: ?Conversation
  if (convoState &&
    convoState.data) {
    conversation = convoState.data
    messages = convoState.data.messages || []
  }

  return {
    conversation,
    conversationID,
    messages,
    pending: convoState ? convoState.pending > 0 : false,
    error: convoState ? convoState.error : null,
  }
}

export function handleRefresh (props: $Shape<Props>) {
  props.refreshConversationDetails(props.conversationID)
}

export function shouldRefresh (props: ConversationOwnProps): boolean {
  if (!props.conversation) return true
  return !props.conversation.messages
}

export const Refreshed: any = refresh(
  handleRefresh,
  shouldRefresh,
  props => Boolean(props.pending)
)(ConversationDetails)
const Connected = connect(mapStateToProps, InboxActions)(Refreshed)
export default Connected
