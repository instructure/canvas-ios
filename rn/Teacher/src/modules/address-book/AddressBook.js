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

/* @flow */

import React, { Component } from 'react'
import {
  View,
  FlatList,
  StyleSheet,
} from 'react-native'
import { connect } from 'react-redux'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import Row from '../../common/components/rows/Row'
import Avatar from '../../common/components/Avatar'
import TypeAheadSearch from '../../common/TypeAheadSearch'
import ListEmptyComponent from '../../common/components/ListEmptyComponent'
import RowSeparator from '../../common/components/rows/RowSeparator'
import CoursesActions from '../courses/actions'

export type AddressBookDataProps = {
  permissions: ?{ [string]: boolean },
  courseID: ?string,
}

export type Props = {
  onSelect: (selected: AddressBookResult[]) => void,
  context: string,
  name: string,
}

export type AddressBookProps =
  NavigationProps &
  AddressBookDataProps &
  Props &
  typeof CoursesActions

type State = {
  searchResults: AddressBookResult[],
  searchString: string,
  error: ?string,
  pending: boolean,
}

function isBranch (id: string): boolean {
  return id.startsWith('course') ||
    id.startsWith('group') ||
    id.startsWith('section')
}

export class AddressBook extends Component<AddressBookProps, State> {
  typeAhead: ?TypeAheadSearch

  state: State = {
    searchResults: [],
    searchString: '',
    error: null,
    pending: false,
  }

  componentDidMount () {
    if (!(this.props.permissions && Object.keys(this.props.permissions).length) && this.props.courseID) {
      this.props.getCoursePermissions(this.props.courseID)
    }
  }

  _queryChanged = (query: string) => {
    this.setState({ searchString: query })
  }

  _requestStarted = () => {
    this.setState({
      pending: true,
    })
  }

  _requestFinished = (results: ?AddressBookResult[], error: ?string) => {
    this.setState({
      searchResults: results || [],
      pending: false,
      error,
    })
  }

  _nextRequestFinished = (results: ?AddressBookResult[], error: ?string) => {
    this.setState({
      searchResults: this.state.searchResults.concat(results || []),
      pending: false,
      error,
    })
  }

  _buildParams = (query: string) => ({
    context: this.props.context,
    search: query,
    synthetic_contexts: 1,
    per_page: 10,
    skip_visibility_checks: 1,
  })

  _onSelectItem = (item: AddressBookResult) => {
    if (isBranch(item.id)) {
      this.showItem(item)
      return
    }

    if (item.id.startsWith('branch')) {
      item = {
        id: this.props.context,
        name: this.props.name,
      }
    }

    this.props.onSelect([item])
  }

  _onCancel = () => {
    this.props.navigator.dismiss()
  }

  keyExtractor (item: AddressBookResult) {
    return item.id
  }

  _renderRow = ({ item, index }) => {
    let border = 'bottom'
    if (index === 0) {
      border = 'both'
    }
    const avatarName = item.id.startsWith('branch') ? i18n('All') : item.name
    const avatar = (<View style={styles.avatar}>
      <Avatar avatarURL={item.avatar_url} userName={avatarName}/>
    </View>)

    return <Row title={item.name}
      border={border}
      renderImage={() => avatar}
      testID={item.id}
      disclosureIndicator={isBranch(item.id)}
      onPress={() => this._onSelectItem(item)} />
  }

  _renderSearchBar = () => {
    return <TypeAheadSearch
      ref={r => { this.typeAhead = r }}
      endpoint='/search/recipients'
      parameters={this._buildParams}
      onRequestStarted={this._requestStarted}
      onRequestFinished={this._requestFinished}
      onNextRequestFinished={this._nextRequestFinished}
      onChangeText={this._queryChanged}
      defaultQuery=''
    />
  }

  _renderComponent = () => {
    const searchBar = this._renderSearchBar()
    const empty = <ListEmptyComponent title={i18n('No results')} />
    return (<View style={styles.container}>
      <FlatList
        data={this.data()}
        renderItem={this._renderRow}
        ListHeaderComponent={searchBar}
        ListEmptyComponent={this.state.pending ? null : empty}
        refreshing={this.state.pending}
        onEndReached={() => this.typeAhead && this.typeAhead.next()}
        ItemSeparatorComponent={RowSeparator}
        keyExtractor={this.keyExtractor}
      />
    </View>)
  }

  render () {
    return (
      <Screen
        drawUnderNavBar
        title={this.props.name}
        rightBarButtons={[{
          title: i18n('Cancel'),
          testID: 'address-book.cancel',
          action: this._onCancel,
        }]}
      >
        { this._renderComponent() }
      </Screen>
    )
  }

  data () {
    let permissions = this.props.permissions || {}
    let data = permissions && this.state.searchResults || []
    let shouldIncludeBranch = permissions.send_messages_all && permissions.send_messages

    if (!permissions.send_messages) {
      data = data.filter(result => !result.id.includes('group'))
    }

    if (shouldIncludeBranch && !this.state.searchString && !this.props.context.endsWith('sections')) {
      data = [this.branchResult(), ...data]
    }
    return data
  }

  branchResult () {
    return {
      id: `branch_${this.props.context}`,
      name: `${i18n('All in')} ${this.props.name}`,
    }
  }

  showItem (item: AddressBookResult) {
    this.props.navigator.show('/address-book', { modal: false }, {
      onSelect: this.props.onSelect,
      context: item.id,
      name: item.name,
    })
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

export function mapStateToProps (state: AppState, ownProps: Props) {
  let [ contextType, courseID ] = ownProps.context.split('_')
  if (contextType === 'course') {
    // courseID is already set correctly
  } else if (contextType === 'section') {
    let sectionData = state.entities.sections[courseID]
    courseID = sectionData && sectionData.course_id
  } else {
    courseID = null
  }
  let courseData = courseID && state.entities.courses[courseID]
  let permissions = courseData && courseData.permissions
  return { permissions, courseID }
}

const Connected = connect(mapStateToProps, CoursesActions)(AddressBook)
export default Connected
