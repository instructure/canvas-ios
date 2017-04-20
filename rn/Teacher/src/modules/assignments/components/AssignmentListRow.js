/**
* @flow
*/

import React, { Component, Element } from 'react'
import {
  View,
  TouchableHighlight,
  StyleSheet,
} from 'react-native'

import i18n from 'format-message'
import { formattedDueDateWithStatus } from '../../../common/formatters'
import Icon from './AssignmentListRowIcon'
import AssignmentDates from '../../../common/AssignmentDates'
import { Text } from '../../../common/text'

type Props = {
  assignment: Assignment,
  tintColor: string,
  onPress: (Assignment) => void,
}

export default class AssignmentListRow extends Component<any, Props, any> {
  onPress = () => {
    const assignment = this.props.assignment
    this.props.onPress(assignment)
  }

  dueDate (assignment: Assignment): Element<View> {
    const dates = new AssignmentDates(assignment)

    if (dates.availabilityClosed()) {
      return <Text style={styles.dueAtTitle}>{i18n('Availability: Closed')}</Text>
    }

    if (dates.hasMultipleDueDates()) {
      return <Text style={styles.dueAtTitle}>{i18n('Multiple Due Dates')}</Text>
    }

    const formattedDate = formattedDueDateWithStatus(dates.bestDueAt())
    return <Text style={styles.dueAtTitle}>{formattedDate}</Text>
  }

  ungradedBubble (assignment: Assignment): Element<View> {
    if (!assignment.needs_grading_count) {
      return <View />
    }

    const text = i18n('{count} ungraded', { count: assignment.needs_grading_count }).toUpperCase()
    return (
      <Text style={styles.ungradedText}>{text}</Text>
    )
  }

  render (): Element<View> {
    const assignment = this.props.assignment
    return (
      <View style={styles.row} key={assignment.id}>
        <TouchableHighlight style={styles.touchableHighlight} onPress={this.onPress} testID={`assignment-${assignment.id}`}>
          <View style={styles.container}>
            {assignment.published ? <View style={styles.publishedIndicatorLine} /> : <View />}
            <Icon published={assignment.published} tintColor={this.props.tintColor} />
            <View style={styles.textContainer}>
              <Text
                style={styles.title}
                ellipsizeMode='tail'
                numberOfLines={2}>{assignment.name}</Text>
              {this.dueDate(assignment)}
              {this.ungradedBubble(assignment)}
            </View>
          </View>
        </TouchableHighlight>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  row: {
    flex: 1,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
  },
  touchableHighlight: {
    flex: 1,
  },
  container: {
    flex: 1,
    padding: 12,
    paddingLeft: 3,
    backgroundColor: 'white',
    alignItems: 'flex-start',
    flexDirection: 'row',
  },
  textContainer: {
    flex: 1,
  },
  title: {
    flex: 1,
    fontWeight: '600',
    color: '#2D3B45',
  },
  dueAtTitle: {
    color: '#8B969E',
    fontSize: 14,
    marginTop: 2,
  },
  ungradedText: {
    flex: 0,
    alignSelf: 'flex-start',
    fontSize: 11,
    fontWeight: '600',
    color: '#008EE2',
    borderRadius: 9,
    borderColor: '#008EE2',
    borderWidth: 1,
    backgroundColor: 'white',
    paddingTop: 3,
    paddingBottom: 1,
    paddingLeft: 6,
    paddingRight: 6,
    marginTop: 4,
    overflow: 'hidden',
  },
  publishedIndicatorLine: {
    backgroundColor: '#00AC18',
    position: 'absolute',
    top: 4,
    bottom: 4,
    left: 0,
    width: 3,
  },
})
