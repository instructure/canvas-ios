import React, { Component } from 'react'
import {
  View,
  FlatList,
  StyleSheet,
} from 'react-native'
import { connect } from 'react-redux'
import refresh from '../../utils/refresh'
import Actions from './actions'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import branding from '../../common/branding'
import ConversationRow from './components/ConversationRow'
import FilterHeader from './components/FilterHeader'

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

  _renderItem = ({ item, index }) => {
    return <ConversationRow conversation={item} drawsTopLine={index === 0} />
  }

  _onChangeFilter = (scope: InboxScope) => {
    this.props.updateInboxSelectedScope(scope)
  }

  _renderComponent = (): React.Element<View> => {
    return (
      <View style={styles.container}>
        <FilterHeader selected={this.props.scope} onFilterChange={this._onChangeFilter} />
        <FlatList
          data={this.props.conversations}
          renderItem={this._renderItem}
          refreshing={Boolean(this.props.pending)}
          onRefresh={this.props.refresh}
          keyExtractor={ (c) => c.id } />
      </View>
    )
  }

  render (): React.Element<{}> {
    return <Screen
        navBarColor={branding.navBarColor}
        navBarStyle='dark'
        drawUnderNavBar={true}
        title={i18n('Inbox')}>
        { this._renderComponent() }
      </Screen>
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
  }
}

export function handleRefresh (props: InboxProps): void {
  switch (props.scope) {
    case 'all': props.refreshInboxAll(); break
    case 'unread': props.refreshInboxUnread(); break
    case 'starred': props.refreshInboxStarred(); break
    case 'sent': props.refreshInboxSent(); break
    case 'archived': props.refreshInboxArchived(); break
  }
}

export const Refreshed: any = refresh(
  handleRefresh,
  props => props.conversations.length === 0,
  props => Boolean(props.pending)
)(Inbox)
const Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<any, Props, any>)
