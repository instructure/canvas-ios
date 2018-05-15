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

/**
 * @flow
 */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  SectionList,
  StyleSheet,
} from 'react-native'

import i18n from 'format-message'
import SectionActions from './actions'
import EnrollmentActions from '../enrollments/actions'
import { searchMapStateToProps, type AssigneeSearchProps, type Assignee } from './map-state-to-props'
import AssigneeRow from './AssigneeRow'
import SearchBar from 'react-native-search-bar'
import { escapeRegExp } from 'lodash'
import Screen from '../../routing/Screen'
import SectionHeader from '../../common/components/rows/SectionHeader'
import ListEmptyComponent from '../../common/components/ListEmptyComponent'
import RowSeparator from '../../common/components/rows/RowSeparator'

export class AssigneeSearch extends Component<AssigneeSearchProps, any> {
  searchBar: SearchBar
  filterString: string

  state = {
    sections: [],
  }

  updateFilterString = (filterString: string) => {
    this.filterString = filterString
    this.updateData(this.props)
  }

  componentWillReceiveProps (props: AssigneeSearchProps) {
    this.updateData(props)
  }

  componentWillMount () {
    this.refresh()
    this.updateData(this.props)
  }

  dismiss = () => {
    this.props.navigator.dismiss()
  }

  refresh = () => {
    this.props.refreshSections(this.props.courseID)
    this.props.refreshEnrollments(this.props.courseID)
    this.props.refreshGroupsForCategory(this.props.assignment.group_category_id)
  }

  updateData (props: AssigneeSearchProps) {
    const sections = props.sections.map((item) => {
      return {
        id: 'section-' + item.id,
        dataId: item.id,
        type: 'section',
        name: item.name,
        info: i18n('{count} students', { count: item.total_students }),
      }
    })

    const groups = props.groups.map((item) => {
      return {
        id: 'group-' + item.id,
        dataId: item.id,
        type: 'group',
        name: item.name,
        info: i18n('{count} students', { count: item.members_count }),
      }
    })

    const enrollments = props.enrollments.map((item) => {
      return {
        id: 'student-' + item.user.id,
        dataId: item.user.id,
        type: 'student',
        name: item.user.name,
        info: item.user.email,
        imageURL: item.user.avatar_url,
      }
    })

    const everyone: Assignee = {
      id: 'everyone',
      dataId: 'everyone',
      type: 'everyone',
      name: i18n('Everyone'),
    }

    const filter = (items) => {
      if (!this.filterString) return items
      const trimmed = this.filterString.trim()
      const regex = RegExp(trimmed, 'i')
      return items.filter((item) => {
        let result = regex.test(escapeRegExp(item.name))
        if (item.info) {
          result = result || regex.test(escapeRegExp(item.info))
        }
        return result
      })
    }

    const data = [
      { data: filter([everyone]), key: 'everyone' },
      { data: filter(sections), key: i18n('Course Sections') },
      { data: filter(groups), key: i18n('Groups') },
      { data: filter(enrollments), key: i18n('Students') },
    ]

    this.setState({
      sections: data.filter((section) => section.data.length > 0),
    })
  }

  renderRow = ({ item, index }: {item: Assignee, index: number }) => {
    return <AssigneeRow assignee={item} onPress={this.onRowPress} />
  }

  renderSectionHeader = ({ section }: any) => {
    if (section.key === 'everyone') {
      return null
    }
    return <SectionHeader title={section.key} />
  }

  renderSearchBar = () => {
    return <SearchBar
      ref={ (c) => { this.searchBar = c }}
      onChangeText={this.updateFilterString}
      onSearchButtonPress={() => this.searchBar.unFocus()}
      onCancelButtonPress={() => this.searchBar.unFocus()}
      placeholder={i18n('Search')}
    />
  }

  onRowPress = (data: any) => {
    this.props.onSelection(data)
  }

  render () {
    const empty = <ListEmptyComponent title={i18n('No results')} />
    return (
      <Screen
        title={i18n('Add Assignee')}
        leftBarButtons={[
          {
            title: i18n('Cancel'),
            testID: 'assignee-picker.cancel-btn',
            action: this.dismiss,
          },
        ]}
      >
        <View style={styles.container}>
          { this.renderSearchBar() }
          <SectionList
            testID='assignee-picker.list'
            sections={this.state.sections}
            renderItem={this.renderRow}
            renderSectionHeader={this.renderSectionHeader}
            keyExtractor={(item) => item.id}
            ListHeaderComponent={<RowSeparator />}
            ListEmptyComponent={empty}
            refreshing={this.props.pending}
            onRefresh={this.refresh}
          />
        </View>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})

let Connected = connect(searchMapStateToProps, { ...SectionActions, ...EnrollmentActions })(AssigneeSearch)
export default (Connected: Component<AssigneeSearchProps, any>)
