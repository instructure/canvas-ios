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
  FlatList,
  StyleSheet,
} from 'react-native'
import { connect } from 'react-redux'
import refresh from '../../utils/refresh'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import Row from '../../common/components/rows/Row'
import Avatar from '../../common/components/Avatar'
import GroupActions from './actions'
import ListEmptyComponent from '../../common/components/ListEmptyComponent'
import RowSeparator from '../../common/components/rows/RowSeparator'

type StateProps = {
  group: ?Group,
  groupID: string,
  pending: number,
  error: ?string,
}

type RouterProps = {
  groupID: string,
  courseID: string,
}

type GroupActionsProps = {
  listUsersForGroup: Function,
}

type GroupListProps = RouterProps & GroupActionsProps & NavigationProps & StateProps & RefreshProps

export class GroupList extends Component<GroupListProps, any> {
  constructor (props: GroupListProps) {
    super(props)

    this.state = {
      error: null,
      pending: false,
    }
  }

  navigateToContextCard = (userID: string) => {
    this.props.navigator.show(
      `/courses/${this.props.courseID}/users/${userID}`,
      { modal: true }
    )
  }

  keyExtractor (item: Group) {
    return item.id
  }

  _renderRow = ({ item, index }) => {
    let border = index === 0 ? 'both' : 'bottom'

    const avatar = (
      <View style={styles.avatar}>
        <Avatar
          avatarURL={item.avatar_url}
          userName={item.name}
          onPress={() => this.navigateToContextCard(item.id)}
        />
      </View>
    )

    return <Row title={item.name}
      border={border}
      renderImage={() => avatar}
      testID={item.id}
    />
  }

  _renderComponent = () => {
    const empty = <ListEmptyComponent title={i18n('No results')} />
    let data = this.props.group ? this.props.group.users : []
    return (
      <View style={styles.container}>
        <FlatList
          data={data}
          refreshing={this.props.refreshing}
          onRefresh={this.props.refresh}
          renderItem={this._renderRow}
          ListEmptyComponent={this.state.pending ? null : empty}
          refreshing={this.state.pending}
          ItemSeparatorComponent={RowSeparator}
          keyExtractor={this.keyExtractor}
        />
      </View>)
  }

  render () {
    const title = this.props.group ? this.props.group.name : ''
    return (
      <Screen
        drawUnderNavBar={false}
        title={title}
      >
        {this._renderComponent()}
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  avatar: {
    width: 40,
    height: 40,
    marginRight: global.style.defaultPadding,
  },
})

export function mapStateToProps (state: AppState, ownProps: RouterProps): StateProps {
  let pending = 0
  let error = null
  let groupID = ownProps.groupID
  let group = null

  if (state.entities.groups && state.entities.groups[ownProps.groupID]) {
    pending = state.entities.groups[ownProps.groupID].pending
    error = state.entities.groups[ownProps.groupID].error
    group = state.entities.groups[ownProps.groupID].group
  }

  return {
    pending,
    error,
    groupID,
    group,
  }
}

export let Refreshed: any = refresh(
  props => { props.listUsersForGroup(props.groupID) },
  props => !props.group || !props.users,
  props => Boolean(props.pending)
)(GroupList)
const Connected = connect(mapStateToProps, GroupActions)(Refreshed)
export default (Connected: GroupList)
