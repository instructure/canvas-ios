/**
 * @flow
 */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  FlatList,
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

export class AssigneeSearch extends Component<any, AssigneeSearchProps, any> {
  searchBar: SearchBar
  filterString: string

  constructor (props: AssigneeSearchProps) {
    super(props)

    this.state = {
      data: [],
    }
  }

  updateFilterString = (filterString: string) => {
    this.filterString = filterString
    this.updateData(this.props.sections, this.props.enrollments)
  }

  componentWillReceiveProps (props: AssigneeSearchProps) {
    this.updateData(props.sections, props.enrollments)
  }

  componentWillMount () {
    this.refreshData()
    this.updateData()
  }

  dismiss = () => {
    this.props.navigator.dismiss()
  }

  refreshData () {
    this.props.refreshSections(this.props.courseID)
    this.props.refreshEnrollments(this.props.courseID)
  }

  updateData (newSections: Section[] = [], newEnrollments: Enrollment[] = []) {
    const sections = newSections.map((item) => {
      return {
        id: 'section-' + item.id,
        dataId: item.id,
        type: 'section',
        name: item.name,
        info: i18n('{count} students', { count: item.total_students }),
      }
    })

    const enrollments = newEnrollments.map((item) => {
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

    let data = [everyone, ...sections, ...enrollments]
    if (this.filterString) {
      data = data.filter((item) => {
        const regex = RegExp(this.filterString, 'i')
        let result = regex.test(escapeRegExp(item.name))
        if (item.info) {
          result = result || regex.test(escapeRegExp(item.info))
        }
        return result
      })
    }
    this.setState({
      data,
    })
  }

  renderRow = ({ item, index }: {item: Assignee, index: number }) => {
    return <AssigneeRow assignee={item} onPress={this.onRowPress} />
  }

  renderSearchBar = () => {
    return <SearchBar
            ref={ (c) => { this.searchBar = c }}
            onChangeText={this.updateFilterString}
            onSearchButtonPress={() => this.searchBar.unFocus()}
            onCancelButtonPress={() => this.searchBar.unFocus()}
            />
  }

  onRowPress = (data: any) => {
    this.props.onSelection(data)
  }

  render (): React.Element<View> {
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
          <FlatList
            testID='assignee-picker.list'
            data={this.state.data}
            renderItem={this.renderRow}
            keyExtractor={(item) => item.id}
            ListHeaderComponent={this.renderSearchBar}
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
export default (Connected: Component<any, AssigneeSearchProps, any>)
