/**
 * @flow
 *
 * - When single due date assigned to everyone, display due date, assignees (i.e., "Everyone"), and available from/to dates
 * - When single due date assigned to one person, display due date, assignee (e.g., "Tom Smith"), and available from/to dates
 * - When single due date assigned to one section or group, display due date, assignee (e.g., "Student Group 2") and available from/to dates
 * - When single due date assigned to more than one person and less than everyone, display due date, assignees (e.g., "20 people"), and available from/to dates
 * - When multiple due dates, display "Multiple due dates"
 * - Assigned to multiple sections or groups, treat as multiple due dates
 * - Assigned to at least one section or group and at least one person, treat as multiple due dates
 * - if no Available To date, display double dash
 * - if available to date is in the past, display "Availability: Closed" rather than available from/to dates
 * - If multiple due dates, don't show closed unless all availability dates are past
 */

import React, { Component } from 'react'

import {
  View,
  Text,
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'

import AssignmentDates from '../../../common/AssignmentDates'
import { formattedDueDate } from '../../../common/formatters'
import colors from '../../../common/colors'

type Props = {
  assignment: Assignment,
}

export default class DueDates extends Component<any, Props, any> {

  renderMultipleDueDates (): React.Element<View> {
    const title = i18n({
      default: 'Multiple Due Dates',
      description: 'Assignment details information about due dates, when there are more than one due date to display',
    })

    return <View style={styles.container}>
             <Text>{title}</Text>
           </View>
  }

  renderAvailability (dates: AssignmentDates): React.Element<View> {
    if (dates.availabilityClosed()) {
      const availabilityClosedTitle = i18n({
        default: 'Availability:',
        description: 'Assignment due date "Available to:" field',
      })

      const availabilityClosedInfo = i18n({
        default: 'Closed',
        description: 'Assignment due date "Available to:" field',
      })

      return <View>
               <Text style={styles.textContainer}>
                 <Text style={styles.descriptionText}>{availabilityClosedTitle}</Text>
                 <Text style={styles.infoText}>{` ${availabilityClosedInfo}`}</Text>
               </Text>
             </View>
    }

    const availableFromTitle = i18n({
      default: 'Available from:',
      description: 'Assignment due date "Available from:" field',
    })

    const availableToTitle = i18n({
      default: 'Available to:',
      description: 'Assignment due date "Available to:" field',
    })

    const availableFrom = dates.bestAvailableFrom()
    const availableTo = dates.bestAvailableTo()
    const availableFromText = availableFrom ? formattedDueDate(availableFrom) : '-'
    const availableToText = availableTo ? formattedDueDate(availableTo) : '-'

    return <View>
             <Text style={styles.textContainer}>
               <Text style={styles.descriptionText}>{availableFromTitle}</Text>
               <Text style={styles.infoText}>{` ${availableFromText}`}</Text>
             </Text>
             <Text style={styles.textContainer}>
               <Text style={styles.descriptionText}>{availableToTitle}</Text>
               <Text style={styles.infoText}>{` ${availableToText}`}</Text>
             </Text>
          </View>
  }

  renderSingleDueDate (dates: AssignmentDates): ReactElement<View> {
    const dueTitle = i18n({
      default: 'Due:',
      description: 'Assignment due date "Due:" field. Looks something like this when finished: "Due: March 13, 2019"',
    })

    const forTitle = i18n({
      default: 'For:',
      description: 'Assignment due date "For:" field',
    })

    const availability = this.renderAvailability(dates)

    return <View style={styles.container}>
             <Text style={styles.textContainer}>
               <Text style={styles.descriptionText}>{dueTitle}</Text>
               <Text style={styles.infoText}>{` ${formattedDueDate(dates.bestDueAt())}`}</Text>
             </Text>
             <Text style={styles.textContainer}>
               <Text style={styles.descriptionText}>{forTitle}</Text>
               <Text style={styles.infoText}>{` ${dates.bestDueDateTitle()}`}</Text>
             </Text>
             {availability}
           </View>
  }

  render (): React.Element<View> {
    const dates = new AssignmentDates(this.props.assignment)

    if (dates.hasMultipleDueDates()) {
      return this.renderMultipleDueDates()
    }

    return this.renderSingleDueDate(dates)
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  textContainer: {
    paddingTop: 2,
  },
  descriptionText: {
    color: colors.darkText,
    fontWeight: '600',
    fontSize: 16,
  },
  infoText: {
    color: colors.darkText,
    fontSize: 16,
  },
})
