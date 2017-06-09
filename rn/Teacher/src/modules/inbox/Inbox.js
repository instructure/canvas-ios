import React, { Component } from 'react'
import {
  View,
  FlatList,
  StyleSheet,
  Text,
} from 'react-native'
import { connect } from 'react-redux'
import refresh from '../../utils/refresh'
import Actions from './actions'
import Screen from '../../routing/Screen'
import branding from '../../common/branding'
import ConversationRow from './components/ConversationRow'
import FilterHeader from './components/FilterHeader'
import i18n from 'format-message'

export type InboxProps = {
  conversations: Conversation[],
  scope: InboxScope,
  next: ?Function,
}

export class Inbox extends Component {

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

  _onChangeFilter = (scope: InboxScope) => {
    this.props.updateInboxSelectedScope(scope)
  }

  _renderComponent = (): React.Element<View> => {
    if (!global.V05) {
      return (
        <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
          <Text style={{ fontSize: 18, color: 'gray' }}>{i18n('Coming Soon...')}</Text>
        </View>
      )
    }
    return (
      <View style={styles.container}>
        <FilterHeader selected={this.props.scope} onFilterChange={this._onChangeFilter} />
        <FlatList
          data={this.props.conversations}
          renderItem={this._renderItem}
          refreshing={Boolean(this.props.pending)}
          onRefresh={this.props.refresh}
          keyExtractor={ (c) => c.id }
          onEndReached={this.getNextPage}
        />
      </View>
    )
  }

  render (): React.Element<{}> {
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

export const Refreshed: any = refresh(
  handleRefresh,
  props => props.conversations.length === 0 || !props.next,
  props => Boolean(props.pending)
)(Inbox)
const Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<any, Props, any>)
