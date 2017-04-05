/**
* @flow
*/

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  ScrollView,
  Text,
  StyleSheet,
} from 'react-native'

import { mapStateToProps, type AssignmentDueDatesProps } from './map-state-to-props'
import UserProfileActions from '../users/actions'
import AssignmentDates from '../../common/AssignmentDates'
import { formattedDueDateWithStatus, formattedDueDate } from '../../common/formatters'
import colors from '../../common/colors'
import { extractDateFromString } from '../../utils/dateUtils'
import i18n from 'format-message'

export class AssignmentDueDates extends Component<any, AssignmentDueDatesProps, any> {

  static navigatorButtons = {
    rightButtons: [
      {
        title: i18n({
          default: 'Edit',
          description: 'Shown at the top of the app to allow the user to edit',
        }),
        id: 'edit',
        testID: 'e2e_rules',
      },
    ],
  }

  componentWillMount () {
    const studentIDs = new AssignmentDates(this.props.assignment).studentIDs()
    if (studentIDs.length) {
      this.props.refreshUsers(studentIDs)
    }
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

    return <View style={styles.row} key={date.id || 'base'} >
             <Text style={styles.title}>{formattedDueDateWithStatus(dueAt)}</Text>
             <Text style={styles.header}>{i18n('For')}</Text>
             <Text style={styles.content}>{title}</Text>
             <View style={styles.divider} />
             <Text style={styles.header}>{i18n('Available from')}</Text>
             <Text style={styles.content}>{availableFrom}</Text>
             <View style={styles.divider} />
             <Text style={styles.header}>{i18n('Available to')}</Text>
             <Text style={styles.content}>{availableTo}</Text>
             <View style={styles.divider} />
           </View>
  }

  render (): React.Element<View> {
    const dates = new AssignmentDates(this.props.assignment)
    const rows = dates.allDates().map((date) => {
      return this.renderRow(date, dates)
    })

    return <ScrollView style={styles.container}>
             {rows}
           </ScrollView>
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
  title: {
    fontSize: 20,
    fontWeight: '600',
    color: colors.darkText,
  },
  header: {
    color: colors.grey4,
    paddingTop: global.style.defaultPadding,
    fontSize: 16,
    fontWeight: '500',
  },
  content: {
    color: colors.darkText,
    paddingBottom: global.style.defaultPadding,
    fontSize: 16,
  },
  divider: {
    height: StyleSheet.hairlineWidth,
    backgroundColor: colors.grey2,
  },
})

let Connected = connect(mapStateToProps, UserProfileActions)(AssignmentDueDates)
export default (Connected: Component<any, AssignmentDueDatesProps, any>)
