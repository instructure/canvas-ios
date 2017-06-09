import React, { Component } from 'react'
import {
  View,
  FlatList,
  StyleSheet,
  ActivityIndicator,
  Text,
} from 'react-native'
import { connect } from 'react-redux'
import refresh from '../../utils/refresh'
import Actions from './actions'
import Screen from '../../routing/Screen'
import branding from '../../common/branding'
import ConversationRow from './components/ConversationRow'
import FilterHeader from './components/FilterHeader'
import EmptyInbox from './components/EmptyInbox'
import Images from '../../images'
import i18n from 'format-message'

export type InboxProps = {
  conversations: Conversation[],
  scope: InboxScope,
  next: ?Function,
}

export class Inbox extends Component {
  props: InboxProps

  componentWillReceiveProps (newProps: InboxProps) {
    if (newProps.scope !== this.props.scope) {
      handleRefresh(newProps)
    }
  }

  getNextPage = () => {
    if (!this.props.next) return
    handleRefresh(this.props, this.props.next)
  }

  _renderItem = ({ item, index }) => {
    return <ConversationRow conversation={item} drawsTopLine={index === 0} onPress={() => {}}/>
  }

  _renderLoading = () => {
    return (
      <View style={styles.loading}>
        <ActivityIndicator />
      </View>
    )
  }

  _onChangeFilter = (scope: InboxScope) => {
    this.props.updateInboxSelectedScope(scope)
  }

  _renderComponent = () => {
    if (!global.V05) {
      return (
        <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
          <Text style={{ fontSize: 18, color: 'gray' }}>{i18n('Coming Soon...')}</Text>
        </View>
      )
    }

    let emptyState
    if (this.props.conversations.length === 0) {
      if (this.props.scope === 'starred') {
        emptyState = <EmptyInbox
          image={Images.starLarge}
          title={i18n('No Starred Messages')}
          text={i18n('Star messages by tapping the star in the message.')}
        />
      } else {
        emptyState = <EmptyInbox
          image={Images.mail}
          title={i18n('No Messages')}
          text={i18n('Tap the "+" to create a new conversation')}
        />
      }
    }

    return (
      <View style={styles.container}>
        <FilterHeader selected={this.props.scope} onFilterChange={this._onChangeFilter} />
        { this.props.conversations.length === 0 && this.props.pending
            ? this._renderLoading()
            : emptyState || <FlatList
                data={this.props.conversations}
                renderItem={this._renderItem}
                refreshing={this.props.refreshing}
                onRefresh={this.props.refresh}
                keyExtractor={ (c) => c.id }
                onEndReached={this.getNextPage} />
        }
      </View>
    )
  }

  render () {
    return (
      <Screen
        navBarColor={branding.navBarColor}
        navBarStyle='dark'
        drawUnderNavBar={true}
        navBarImage={branding.headerImage}
      >
        { this._renderComponent() }
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  loading: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
})

export function mapStateToProps ({ inbox }: InboxState): InboxProps {
  const scope = inbox.selectedScope
  const scopeData = inbox[scope]
  const conversations = scopeData.refs.map((id) => inbox.conversations[id]).filter((c) => c)
  return {
    conversations,
    scope,
    pending: scopeData.pending,
    error: scopeData.error,
    next: scopeData.next,
  }
}

export function handleRefresh (props: InboxProps, next: Function): void {
  switch (props.scope) {
    case 'all': props.refreshInboxAll(next); break
    case 'unread': props.refreshInboxUnread(next); break
    case 'starred': props.refreshInboxStarred(next); break
    case 'sent': props.refreshInboxSent(next); break
    case 'archived': props.refreshInboxArchived(next); break
  }
}

export function shouldRefresh (props: InboxProps): boolean {
  return props => props.conversations.length === 0 || !props.next
}

export const Refreshed: any = refresh(
  handleRefresh,
  shouldRefresh,
  props => Boolean(props.pending)
)(Inbox)
const Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<any, Props, any>)
