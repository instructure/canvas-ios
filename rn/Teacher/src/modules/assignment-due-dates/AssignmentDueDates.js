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
import UserProfileActions from '../users/actions'
import AssignmentDates from '../../common/AssignmentDates'
import { formattedDueDateWithStatus, formattedDueDate } from '../../common/formatters'
import colors from '../../common/colors'
import { extractDateFromString } from '../../utils/dateUtils'
import i18n from 'format-message'
import { Text, Heading1 } from '../../common/text'
import Screen from '../../routing/Screen'

export class AssignmentDueDates extends Component<any, AssignmentDueDatesProps, any> {

  componentWillMount () {
    const studentIDs = new AssignmentDates(this.props.assignment).studentIDs()
    if (studentIDs.length) {
      this.props.refreshUsers(studentIDs)
    }
  }

  editAssignment = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/assignments/${this.props.assignmentID}/edit`, { modal: true })
  }

  renderRow (date: AssignmentDate, dates: AssignmentDates): React.Element<View> {
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
      availableFromAccessibilityLabel = i18n({
        default: 'Available from: {date}',
        description: 'Accessibility label for when there is no available from date set',
      }, {
        date: availableFrom,
      })
    } else {
      availableFromAccessibilityLabel = i18n({
        default: 'No available from date set',
        description: 'Accessibility label for when there is no available from date set',
      })
    }

    if (date.lock_at) {
      availableToAccessibiltyLabel = i18n({
        default: 'Available to: {date}',
        description: 'Accessibility label for when there is no available to date set',
      }, {
        date: availableTo,
      })
    } else {
      availableToAccessibiltyLabel = i18n({
        default: 'No available to date set',
        description: 'Accessibility label for when there is no available to date set',
      })
    }

    return (<View style={styles.row} key={date.id || 'base'} >
              <Heading1>{formattedDueDateWithStatus(dueAt, extractDateFromString(date.lock_at)).join('  •  ')}</Heading1>
              <View accessible={true}>
                <Text style={styles.header}>{i18n('For')}</Text>
                <Text style={styles.content}>{title}</Text>
              </View>
              <View style={styles.divider} />
              <View accessible={true} accessibilityLabel={availableFromAccessibilityLabel}>
                <Text style={styles.header}>{i18n('Available from')}</Text>
                <Text style={styles.content}>{availableFrom}</Text>
              </View>
              <View style={styles.divider} />
              <View accessible={true} accessibilityLabel={availableToAccessibiltyLabel}>
                <Text style={styles.header}>{i18n('Available to')}</Text>
                <Text style={styles.content}>{availableTo}</Text>
              </View>
              <View style={styles.divider} />
            </View>)
  }

  render (): React.Element<View> {
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
            title: i18n({
              default: 'Edit',
              description: 'Shown at the top of the app to allow the user to edit',
            }),
            testID: 'assignment-due-dates.edit-btn',
            action: this.editAssignment,
          },
        ]}
      >
        <ScrollView style={styles.container}>
          {rows}
        </ScrollView>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
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

let Connected = connect(mapStateToProps, UserProfileActions)(AssignmentDueDates)
export default (Connected: Component<any, AssignmentDueDatesProps, any>)
