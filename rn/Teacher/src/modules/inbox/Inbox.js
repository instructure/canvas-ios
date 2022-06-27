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

/* @flow */

import React, { Component } from 'react'
import {
  Appearance,
  View,
  FlatList,
  StyleSheet,
  ActivityIndicator,
} from 'react-native'
import { connect } from 'react-redux'
import refresh from '../../utils/refresh'
import Actions from './actions'
import Screen from '../../routing/Screen'
import ConversationRow from './components/ConversationRow'
import CourseFilter from './components/CourseFilter'
import FilterHeader from './components/FilterHeader'
import EmptyInbox from './components/EmptyInbox'
import icon from '../../images/inst-icons'
import i18n from 'format-message'
import RowSeparator from '../../common/components/rows/RowSeparator'
import CourseActions from '../courses/actions'
import App from '../app'
import { logEvent } from '../../common/CanvasAnalytics'
import type { EventSubscription } from 'react-native/Libraries/vendor/emitter/EventEmitter'
import type { AppearancePreferences } from 'react-native/Libraries/Utilities/NativeAppearance'

export type InboxProps = {
  conversations: Conversation[],
  scope: InboxScope,
  courses: Array<Course>,
  next: ?Function,
  navigator: Navigator,
  refreshing: boolean,
  refresh: Function,
} & typeof Actions & typeof CourseActions

export class Inbox extends Component<InboxProps, any> {
  state = { selectedCourse: 'all' }
  _appearanceChangeSubscription: ?EventSubscription

  UNSAFE_componentWillReceiveProps (newProps: InboxProps) {
    if (newProps.scope !== this.props.scope) {
      handleRefresh(newProps)
    }
  }

  componentDidMount () {
    this._appearanceChangeSubscription = Appearance.addChangeListener(
      (preferences: AppearancePreferences) => {
        this.setState(this.state)
      },
    )
  }

  componentWillUnmount () {
    this._appearanceChangeSubscription?.remove()
  }

  getNextPage = () => {
    if (!this.props.next) return
    handleRefresh(this.props, this.props.next)
  }

  _onSelectConversation = (conversationID: string) => {
    logEvent('conversation_selected')
    const path = `/conversations/${conversationID}`
    this.props.navigator.show(path)
  }

  addMessage = () => {
    logEvent('new_message_composed')
    this.props.navigator.show('/conversations/compose', { modal: true })
  }

  showProfile = () => {
    this.props.navigator.show('/profile', { modal: true, modalPresentationStyle: 'drawer', embedInNavigationController: false })
  }

  _renderItem = ({ item, index }) => {
    return <ConversationRow
      conversation={item}
      drawsTopLine={index === 0}
      onPress={this._onSelectConversation}/>
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

  _clearCourseFilter = () => {
    this.setState({ selectedCourse: 'all' })
  }

  _updateCourseFilter = (id: string) => {
    this.setState({ selectedCourse: id })
  }

  _filteredConversations () {
    return this.props.conversations.filter((convo) => {
      if (this.state.selectedCourse === 'all') return true
      if (!convo.context_code) return false
      return convo.context_code.replace('course_', '') === this.state.selectedCourse
    })
  }

  _renderComponent = () => {
    const conversations = this._filteredConversations()

    return (
      <View style={styles.container}>
        <FilterHeader selected={this.props.scope} onFilterChange={this._onChangeFilter} />
        { this.props.courses && this.props.courses.length > 0 &&
          <CourseFilter courses={this.props.courses}
            selectedCourse={this.state.selectedCourse}
            onClearFilter={this._clearCourseFilter}
            onSelectFilter={this._updateCourseFilter} />
        }
        { conversations.length === 0 && this.props.pending
          ? this._renderLoading()
          : <FlatList
            ListEmptyComponent={this._emptyComponent}
            data={conversations}
            renderItem={this._renderItem}
            refreshing={this.props.refreshing}
            onRefresh={this.props.refresh}
            keyExtractor={ (c) => c.id }
            onEndReached={this.getNextPage}
            ItemSeparatorComponent={RowSeparator}
          />
        }
      </View>
    )
  }

  _emptyComponent = () => {
    const starred = this.props.scope === 'starred'
    return (
      <EmptyInbox
        title={starred ? i18n('No Starred Messages') : i18n('No Messages')}
        text={
          starred
            ? i18n('Star messages by tapping the star in the message.')
            : i18n('Tap the "+" to create a new conversation')
        }
      />
    )
  }

  render () {
    return (
      <Screen
        navBarStyle='global'
        drawUnderNavBar
        navBarLogo
        rightBarButtons={[{
          accessibilityLabel: i18n('New Message'),
          testID: 'inbox.new-message',
          image: icon('add', 'solid'),
          width: 24,
          height: 24,
          action: this.addMessage,
        }]}
        leftBarButtons={[{
          image: icon('hamburger', 'solid'),
          width: 24,
          height: 24,
          testID: 'Inbox.profileButton',
          action: this.showProfile,
          accessibilityLabel: i18n('Profile Menu'),
        }]}
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

export function mapStateToProps ({ inbox, entities }: AppState) {
  const scope = inbox.selectedScope
  const scopeData = inbox[scope]
  const conversations = scopeData.refs.map((id) => inbox.conversations[id] && inbox.conversations[id].data).filter(Boolean)
  const courses = Object.keys(entities.courses)
    .reduce((acc, id) => {
      const course = entities.courses[id].course

      if (course == null || course.name == null) {
        return acc
      }

      acc.push(course)
      return acc
    }, [])
    .filter(App.current().filterCourse)
  return {
    conversations,
    scope,
    courses,
    pending: scopeData.pending,
    error: scopeData.error,
    next: scopeData.next,
  }
}

export function handleRefresh (props: Object, next?: Function): void {
  if (!props.courses || props.courses.length === 0) {
    props.refreshCourses()
  }
  switch (props.scope) {
    case 'all': props.refreshInboxAll(next); break
    case 'unread': props.refreshInboxUnread(next); break
    case 'starred': props.refreshInboxStarred(next); break
    case 'sent': props.refreshInboxSent(next); break
    case 'archived': props.refreshInboxArchived(next); break
  }
}

export function shouldRefresh (props: InboxProps): boolean {
  return props.conversations.length === 0 || !props.next
}

export const Refreshed: any = refresh(
  // $FlowFixMe
  handleRefresh,
  shouldRefresh,
  props => Boolean(props.pending)
)(Inbox)
const Connected = connect(mapStateToProps, { ...Actions, ...CourseActions })(Refreshed)
export default Connected
