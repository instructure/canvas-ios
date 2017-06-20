// @flow

import React, { Component } from 'react'
import {
  View,
  FlatList,
  StyleSheet,
  TouchableOpacity,
  Image,
} from 'react-native'
import { connect } from 'react-redux'
import refresh from '../../../utils/refresh'
import Actions from '../actions'
import Screen from '../../../routing/Screen'
import branding from '../../../common/branding'
import i18n from 'format-message'
import ConversationMessage from '../components/ConversationMessageRow'
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
}

export type ConversationDetailsProps = ConversationOwnProps & RefreshProps & {
  navigator: Navigator,
}

export class ConversationDetails extends Component <any, ConversationDetailsProps, any> {
  _renderItem = ({ item, index }) => {
    return <ConversationMessage
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
      >
        { this._renderComponent() }
      </Screen>
    )
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
  if (convoState &&
      convoState.data &&
      convoState.data.messages) {
    messages = convoState.data.messages
  }

  return {
    conversation: convoState.data,
    conversationID,
    messages,
    pending: convoState.pending > 0,
    error: convoState.error,
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
