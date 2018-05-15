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
  ScrollView,
  StyleSheet,
} from 'react-native'

import { mapStateToProps, type AssignmentDueDatesProps } from './map-state-to-props'
import UserActions from '../users/actions'
import AssignmentDates from '../../common/AssignmentDates'
import { formattedDueDateWithStatus, formattedDueDate } from '../../common/formatters'
import colors from '../../common/colors'
import { extractDateFromString } from '../../utils/dateUtils'
import i18n from 'format-message'
import { Text, Heading1 } from '../../common/text'
import Screen from '../../routing/Screen'

export class AssignmentDueDates extends Component<AssignmentDueDatesProps, any> {
  componentWillMount () {
    const studentIDs = new AssignmentDates(this.props.assignment).studentIDs()
    if (studentIDs.length) {
      this.props.refreshUsers(this.props.courseID, studentIDs)
    }
  }

  editAssignment = () => {
    let route = `/courses/${this.props.courseID}/assignments/${this.props.assignment.id}/edit`
    if (this.props.quizID) {
      route = `/courses/${this.props.courseID}/quizzes/${this.props.quizID}/edit`
    }
    this.props.navigator.show(route, { modal: true })
  }

  renderRow (date: AssignmentDate, dates: AssignmentDates) {
    let title = date.title ? date.title : i18n('Everyone')

    const users = this.props.users
    const overrideID = date.id
    if (overrideID) {
      const override = dates.overrideForID(overrideID)
      if (override) {
        const students = (override.student_ids || []).map((id) => users[id]).filter((profile) => profile)
        if (students.length) {
          title = students.map((profile) => profile.name).filter((name) => name).join(', ')
        }
      }
    }

    const dueAt = extractDateFromString(date.due_at)
    const availableFrom = date.unlock_at ? formattedDueDate(new Date(date.unlock_at)) : '--'
    const availableTo = date.lock_at ? formattedDueDate(new Date(date.lock_at)) : '--'
    let availableFromAccessibilityLabel
    let availableToAccessibiltyLabel

    if (date.unlock_at) {
      availableFromAccessibilityLabel = i18n('Available from: {date}', { date: availableFrom })
    } else {
      availableFromAccessibilityLabel = i18n('No available from date set')
    }

    if (date.lock_at) {
      availableToAccessibiltyLabel = i18n('Available until: {date}', { date: availableTo })
    } else {
      availableToAccessibiltyLabel = i18n('No available until date set')
    }

    return (<View style={styles.row} key={date.id || 'base'} >
      <Heading1>{formattedDueDateWithStatus(dueAt, extractDateFromString(date.lock_at)).join('  •  ')}</Heading1>
      <View accessible={true}>
        <Text style={styles.header}>{i18n('For')}</Text>
        <Text style={styles.content}>{title}</Text>
      </View>
      <View style={styles.divider} />
      <View accessible={true} accessibilityLabel={availableFromAccessibilityLabel}>
        <Text style={styles.header}>{i18n('Available From')}</Text>
        <Text style={styles.content}>{availableFrom}</Text>
      </View>
      <View style={styles.divider} />
      <View accessible={true} accessibilityLabel={availableToAccessibiltyLabel}>
        <Text style={styles.header}>{i18n('Available Until')}</Text>
        <Text style={styles.content}>{availableTo}</Text>
      </View>
      <View style={styles.divider} />
    </View>)
  }

  render () {
    const dates = new AssignmentDates(this.props.assignment)
    const rows = dates.allDates().map((date) => {
      return this.renderRow(date, dates)
    })

    return (
      <Screen
        navBarColor={this.props.courseColor}
        navBarStyle='dark'
        rightBarButtons={[
          {
            title: i18n('Edit'),
            testID: 'assignment-due-dates.edit-btn',
            action: this.editAssignment,
          },
        ]}
      >
        <View style={styles.container}>
          <ScrollView style={styles.scrollContainer}>
            {rows}
          </ScrollView>
        </View>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContainer: {
    flex: 1,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
  },
  row: {
    paddingTop: global.style.defaultPadding,
  },
  header: {
    color: colors.grey4,
    paddingTop: global.style.defaultPadding,
    fontWeight: '500',
  },
  content: {
    paddingBottom: global.style.defaultPadding,
  },
  divider: {
    height: StyleSheet.hairlineWidth,
    backgroundColor: colors.grey2,
  },
})

let Connected = connect(mapStateToProps, UserActions)(AssignmentDueDates)
export default (Connected: Component<AssignmentDueDatesProps, any>)
