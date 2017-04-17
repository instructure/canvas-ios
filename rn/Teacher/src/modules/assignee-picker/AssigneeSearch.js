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

export class AssigneeSearch extends Component<any, AssigneeSearchProps, any> {

  static navigatorButtons = {
    leftButtons: [
      {
        title: i18n('Cancel'),
        id: 'cancel',
        testID: 'assignee-picker.cancel-btn',
      },
    ],
  }

  constructor (props: AssigneeSearchProps) {
    super(props)

    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
    this.state = {
      data: [],
    }
  }

  onNavigatorEvent = (event: NavigatorEvent): void => {
    if (event.type === 'NavBarButtonPress') {
      if (event.id === 'cancel') {
        this.props.navigator.dismissModal()
      }
    }
  }

  componentWillReceiveProps (props: AssigneeSearchProps) {
    this.updateData()
  }

  componentWillMount () {
    this.refreshData()
    this.updateData()

    this.props.navigator.setTitle({
      title: i18n('Add Assignee'),
    })
  }

  refreshData () {
    this.props.refreshSections(this.props.courseID)
    this.props.refreshEnrollments(this.props.courseID)
  }

  updateData () {
    const sections = (this.props.sections || []).map((item) => {
      return {
        id: 'section-' + item.id,
        dataId: item.id,
        type: 'section',
        name: item.name,
        info: i18n('{count} students', { count: item.total_students }),
      }
    })

    const enrollments = (this.props.enrollments || []).map((item) => {
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

    const data = [everyone, ...sections, ...enrollments]
    this.setState({
      data,
    })
  }

  renderRow = ({ item, index }: {item: Assignee, index: number }) => {
    return <AssigneeRow assignee={item} onPress={this.onRowPress} />
  }

  onRowPress = (data: any) => {
    this.props.onSelection(data)
  }

  render (): React.Element<View> {
    return (<View style={styles.container}>
              <FlatList
                testID='assignee-picker.list'
                data={this.state.data}
                renderItem={this.renderRow}
                keyExtractor={(item) => item.id}
              />
            </View>)
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})

let Connected = connect(searchMapStateToProps, { ...SectionActions, ...EnrollmentActions })(AssigneeSearch)
export default (Connected: Component<any, AssigneeSearchProps, any>)
