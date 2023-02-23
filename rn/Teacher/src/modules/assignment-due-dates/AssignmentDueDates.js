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

/**
* @flow
*/

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  ScrollView,
} from 'react-native'

import { mapStateToProps, type AssignmentDueDatesProps } from './map-state-to-props'
import UserActions from '../users/actions'
import AssignmentActions from '../assignments/actions'
import AssignmentDates from '../../common/AssignmentDates'
import {
  formattedDueDateWithStatus,
  formattedDueDate,
  personDisplayName,
} from '../../common/formatters'
import { createStyleSheet } from '../../common/stylesheet'
import { extractDateFromString } from '../../utils/dateUtils'
import i18n from 'format-message'
import { Text, Heading1 } from '../../common/text'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import Screen from '../../routing/Screen'

const Actions = {
  ...UserActions,
  ...AssignmentActions,
}

export class AssignmentDueDates extends Component<AssignmentDueDatesProps, any> {
  UNSAFE_componentWillMount () {
    const studentIDs = this.props.assignment && new AssignmentDates(this.props.assignment).studentIDs()
    if (studentIDs?.length) {
      this.props.refreshUsers(this.props.courseID, studentIDs)
    }
    this.props.refreshAssignment(this.props.courseID, this.props.assignmentID)
  }

  editAssignment = () => {
    let route = `/courses/${this.props.courseID}/assignments/${this.props.assignmentID}/edit`
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
          title = students
            .map((profile) => personDisplayName(profile.name, profile.pronouns))
            .filter((name) => name)
            .join(', ')
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

    let key = date.id || 'base'
    return (<View style={styles.row} key={key} testID={key} >
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
    if (this.props.assignment == null) {
      return <ActivityIndicatorView />
    }
    const dates = new AssignmentDates(this.props.assignment)
    const rows = dates.allDates().map((date) => {
      return this.renderRow(date, dates)
    })

    return (
      <Screen
        title={i18n('Due Dates')}
        navBarStyle='context'
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

const styles = createStyleSheet((colors, vars) => ({
  container: {
    flex: 1,
  },
  scrollContainer: {
    flex: 1,
    paddingLeft: vars.padding,
    paddingRight: vars.padding,
  },
  row: {
    paddingTop: vars.padding,
  },
  header: {
    color: colors.textDark,
    paddingTop: vars.padding,
    fontWeight: '500',
  },
  content: {
    paddingBottom: vars.padding,
  },
  divider: {
    height: vars.hairlineWidth,
    backgroundColor: colors.borderMedium,
  },
}))

let Connected = connect(mapStateToProps, Actions)(AssignmentDueDates)
export default (Connected: Component<AssignmentDueDatesProps, any>)
