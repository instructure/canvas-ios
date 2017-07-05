// @flow

import React, { Component } from 'react'
import {
  View,
  FlatList,
  StyleSheet,
  TouchableOpacity,
  Image,
  ActionSheetIOS,
} from 'react-native'
import { connect } from 'react-redux'
import refresh from '../../../utils/refresh'
import InboxActions from '../actions'
import Screen from '../../../routing/Screen'
import branding from '../../../common/branding'
import i18n from 'format-message'
import ConversationMessageRow from '../components/ConversationMessageRow'
import { Heading1 } from '../../../common/text'
import color from '../../../common/colors'
import Images from '../../../images'

export type ConversationOwnProps = {
  conversation: ?Conversation,
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

export type ConversationDetailsProps = ConversationOwnProps & RefreshProps & NavigationProps

export class ConversationDetails extends Component <any, ConversationDetailsProps, any> {
  constructor (props: ConversationDetailsProps) {
    super(props)

    this.state = {
      deletePending: false,
    }
  }

  componentDidMount () {
    this.props.markAsRead(this.props.conversationID)
  }

  _renderItem = ({ item, index }) => {
    return <ConversationMessageRow
              navigator={this.props.navigator}
              message={item}
              conversation={this.props.conversation}
              onReplyButtonPressed={ () => {} }
              firstMessage={index === 0}
              showOptionsActionSheet={this.showOptionsActionSheet} />
  }

  _toggleStarred = () => {
    if (!this.props.conversation) return
    if (this.props.conversation.starred) {
      this.props.unstarConversation(this.props.conversationID)
    } else {
      this.props.starConversation(this.props.conversationID)
    }
  }

  _renderHeader = () => {
    if (!this.props.conversation) return <View />

    const starred = this.props.conversation.starred
    const star = starred ? Images.starFilled : Images.starLined

    return (<View style={styles.header}>
              <Heading1>{this.props.conversation.subject || i18n('(no subject)')}</Heading1>
              <TouchableOpacity
                accessibilityLabel={starred ? i18n('Starred') : i18n('Un-starred')}
                accessibilityTraits='button'
                testID={`inbox.detail.${starred ? 'starred' : 'not-starred'}`}
                onPress={this._toggleStarred}
                hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
              >
                <View style={{ backgroundColor: 'white' }}>
                  <Image source={star} style={{ tintColor: branding.primaryBrandColor, height: 24, width: 24 }}/>
                </View>
              </TouchableOpacity>
            </View>)
  }

  _renderComponent = () => {
    const header = this._renderHeader()
    return (
      <View style={styles.container}>
        <FlatList
          style={styles.list}
          data={this.props.messages}
          renderItem={this._renderItem}
          ListHeaderComponent={header}
          refreshing={this.props.refreshing}
          onRefresh={this.props.refresh}
        />
      </View>
    )
  }

  render () {
    return (
      <Screen
        navBarColor={branding.navBarColor}
        navBarStyle='dark'
        drawUnderNavBar={true}
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
        { this._renderComponent() }
      </Screen>
    )
  }

  componentWillReceiveProps (nextProps: ConversationDetailsProps) {
    if (this.state.deletePending && !nextProps.pending && !nextProps.conversation) {
      this.setState({ deletePending: false })
      this.props.navigator.pop()
    }
  }

  showOptionsActionSheet = (id: string) => {
    id = id || this.props.conversationID

    const options = [
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
      this.handleOptionsActionSheet.bind(null, id),
    )
  }

  handleOptionsActionSheet = (id: string, index: number) => {
    switch (index) {
      case 0:
        this.forwardMessage(id)
        break
      case 1:
        this.deleteConversation(id)
        break
    }
  }

  deleteConversation (id: string) {
    this.setState({ deletePending: true })
    // $FlowFixMe
    this.props.deleteConversation(id)
  }

  forwardMessage (id: string) {
    let conversation = this.props.conversation || {}
    let includedMessages = []
    if (id === this.props.conversationID) {
      includedMessages = this.props.messages
    } else {
      includedMessages = this.props.messages.filter(message => message.id === id)
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
      includedMessages,
      navBarTitle: i18n('Forward'),
      requireMessageBody: false,
    })
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  loading: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  list: {
    backgroundColor: '#F5F5F5',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: 'white',
    padding: global.style.defaultPadding,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: color.seperatorColor,
  },
})

export function mapStateToProps (state: AppState, props: any): ConversationOwnProps {
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

export function handleRefresh (props: ConversationDetailsProps): void {
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
export default (Connected: Component<any, ConversationDetailsProps, any>)
