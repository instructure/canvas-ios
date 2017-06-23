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
import { default as InboxActions } from '../actions'
import Screen from '../../../routing/Screen'
import branding from '../../../common/branding'
import i18n from 'format-message'
import ConversationMessage from '../components/ConversationMessageRow'
import { Heading1 } from '../../../common/text'
import color from '../../../common/colors'
import Images from '../../../images'

const {
  refreshConversationDetails,
  starConversation,
  unstarConversation,
  deleteConversation,
} = InboxActions

const Actions = {
  refreshConversationDetails,
  starConversation,
  unstarConversation,
  deleteConversation,
}

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
}

export type ConversationDetailsProps = ConversationOwnProps & RefreshProps & NavigationProps

export class ConversationDetails extends Component <any, ConversationDetailsProps, any> {
  constructor (props: ConversationDetailsProps) {
    super(props)

    this.state = {
      deletePending: false,
    }
  }

  _renderItem = ({ item, index }) => {
    return <ConversationMessage
              navigator={this.props.navigator}
              message={item}
              conversation={this.props.conversation}
              onReplyButtonPressed={ () => {} }
              firstMessage={index === 0} />
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

    const star = this.props.conversation.starred ? Images.starFilled : Images.starLined

    return (<View style={styles.header}>
              <Heading1>{this.props.conversation.subject || i18n('(no subject)')}</Heading1>
              <TouchableOpacity onPress={this._toggleStarred} hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
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

  showOptionsActionSheet = () => {
    const options = [
      i18n('Delete'),
      i18n('Cancel'),
    ]
    ActionSheetIOS.showActionSheetWithOptions(
      {
        options,
        destructiveButtonIndex: options.length - 2,
        cancelButtonIndex: options.length - 1,
      },
      this.handleOptionsActionSheet,
    )
  }

  handleOptionsActionSheet = (index: number) => {
    switch (index) {
      case 0:
        this.deleteConversation()
        break
    }
  }

  deleteConversation () {
    this.setState({ deletePending: true })
    // $FlowFixMe
    this.props.deleteConversation(this.props.conversationID)
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
const Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<any, ConversationDetailsProps, any>)
