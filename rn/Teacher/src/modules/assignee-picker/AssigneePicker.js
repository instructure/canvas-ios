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
import {
  View,
  ScrollView,
  Image,
  TouchableHighlight,
  StyleSheet,
} from 'react-native'

import { connect } from 'react-redux'
import { find } from 'lodash'
import i18n from 'format-message'
import colors from '../../common/colors'
import AssigneeRow from './AssigneeRow'
import Images from '../../images'
import { pickerMapStateToProps, type AssigneePickerProps, type Assignee } from './map-state-to-props'
import Actions from './actions.js'
import EnrollmentActions from '../enrollments/actions'
import GroupActions from '../groups/actions'
import UserActions from '../users/actions'
import { Text } from '../../common/text'
import Screen from '../../routing/Screen'
import DisclosureIndicator from '../../common/components/DisclosureIndicator'

export class AssigneePicker extends Component<AssigneePickerProps, any> {
  constructor (props: AssigneePickerProps) {
    super(props)
    this.state = {
      selected: props.assignees || [],
    }
  }

  componentWillReceiveProps = (props: AssigneePickerProps) => {
    const assignees = props.assignees || []
    const selected = this.state.selected.map((item) => {
      const previous = find(assignees, { id: item.id })
      if (previous) {
        Object.assign(item, previous)
      }
      return item
    })

    const newAssignees = assignees.filter((a) => !find(selected, { id: a.id }))

    this.setState({ selected: [...selected, ...newAssignees] })
  }

  componentDidMount () {
    this.props.refreshSections(this.props.courseID)
    const userIds = this.props.assignees.filter(a => a.type === 'student').map(a => a.dataId)
    this.props.refreshUsers(this.props.courseID, userIds)
    this.props.assignees
      .filter(a => a.type === 'group')
      .forEach((group) => {
        this.props.refreshGroup(group.dataId)
      })
  }

  done = () => {
    if (this.props.callback) {
      this.props.callback(this.state.selected || [])
    } else {
      this.props.navigator.dismiss()
    }
  }

  dismiss = () => {
    this.props.navigator.dismiss()
  }

  addAssignee = () => {
    const url = `/courses/${this.props.courseID}/assignments/${this.props.assignmentID}/assignee-search`
    this.props.navigator.show(url, { modal: true, modalPresentationStyle: 'currentContext' }, { onSelection: this.handleSelectedAssignee })
  }

  handleSelectedAssignee = (assignee: Assignee) => {
    // If trying to add the same assignee twice, DENY
    const existing = find(this.state.selected, { id: assignee.id })
    if (!existing) {
      const selected = [...this.state.selected, assignee]
      this.setState({
        selected,
      })
    }

    this.props.navigator.dismiss()
  }

  deleteAssignee = (assignee: Assignee) => {
    const selected = this.state.selected.filter((a) => {
      return a.id !== assignee.id
    })

    this.setState({
      selected,
    })
  }

  render () {
    return (
      <Screen
        title={i18n('Assignees')}
        rightBarButtons={[
          {
            title: i18n('Done'),
            style: 'done',
            testID: 'assignee-picker.dismiss-btn',
            action: this.done,
          },
        ]}
        dismissButtonTitle={i18n('Cancel')}
      >
        <ScrollView style={styles.container}>
          { this.state.selected.length > 0 && <View style={styles.space} /> }
          { this.state.selected.map((assignee: Assignee) => <AssigneeRow assignee={assignee} onDelete={this.deleteAssignee} key={assignee.id}/>) }
          <View style={styles.space} />
          <TouchableHighlight style={styles.button} onPress={this.addAssignee}>
            <View style ={styles.rowContainer}>
              <View style={styles.buttonContainer}>
                <Image source={Images.add} style={styles.buttonImage} />
                <Text style={styles.buttonText}>{i18n('Add Assignee')}</Text>
              </View>
              <DisclosureIndicator />
            </View>
          </TouchableHighlight>
        </ScrollView>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.grey1,
  },
  space: {
    height: 40,
    backgroundColor: colors.grey1,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
  },
  button: {
    height: 'auto',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
  },
  buttonContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'white',
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
    paddingVertical: global.style.defaultPadding / 2,
  },
  buttonText: {
    color: colors.primaryButton,
    fontSize: 16,
    fontWeight: '600',
  },
  buttonImage: {
    tintColor: colors.primaryButton,
    marginRight: 8,
    height: 18,
    width: 18,
  },
  rowContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: 'white',
    paddingRight: global.style.defaultPadding,
    paddingVertical: global.style.defaultPadding / 2,
  },
})

let Connected = connect(pickerMapStateToProps, { ...Actions, ...EnrollmentActions, ...UserActions, ...GroupActions })(AssigneePicker)
export default (Connected: Component<AssigneePickerProps, any>)
