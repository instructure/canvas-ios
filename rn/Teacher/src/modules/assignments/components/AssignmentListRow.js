/**
* @flow
*/

import React, { Component, Element } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'

import i18n from 'format-message'
import { formattedDueDateWithStatus } from '../../../common/formatters'
import Icon from '../../../common/components/PublishedIcon'
import AssignmentDates from '../../../common/AssignmentDates'
import { Text } from '../../../common/text'
import Row from '../../../common/components/rows/Row'
import Images from '../../../images'

type Props = {
  assignment: Assignment,
  tintColor: string,
  onPress: (Assignment) => void,
  selected: boolean,
}

export default class AssignmentListRow extends Component<any, Props, any> {
  onPress = () => {
    const assignment = this.props.assignment
    this.props.onPress(assignment)
  }

  dueDate (assignment: Assignment): string {
    const dates = new AssignmentDates(assignment)

    if (dates.availabilityClosed()) {
      return i18n('Availability: Closed')
    }

    if (dates.hasMultipleDueDates()) {
      return i18n('Multiple Due Dates')
    }

    return formattedDueDateWithStatus(dates.bestDueAt(), dates.bestAvailableTo()).join('  •  ')
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
    const { assignment, selected } = this.props
    return (
      <View>
        <View style={styles.row}>
          <Row
            renderImage={this._renderIcon}
            title={assignment.name}
            titleProps={{ ellipsizeMode: 'tail', numberOfLines: 2 }}
            subtitle={this.dueDate(assignment)}
            border='bottom'
            disclosureIndicator={true}
            testID={`assignment-list-row-${assignment.id}.assignments-cell`}
            onPress={this.onPress}
            selected={selected}
            height='auto'
          >
            {this.ungradedBubble(assignment)}
          </Row>
        </View>
        {this.props.assignment.published ? <View style={styles.publishedIndicatorLine} /> : <View />}
      </View>
    )
  }

  _renderIcon = () => {
    const assignment = this.props.assignment
    let image = Images.course.assignments
    let testIDSuffix = `-icon-${assignment.published ? 'published' : 'not-published'}-${assignment.id}.icon-img`
    let testID = `assignment-list-row-assignment${testIDSuffix}`
    if (assignment.submission_types.includes('online_quiz')) {
      image = Images.course.quizzes
      testID = `assignment-list-row-quiz${testIDSuffix}`
    } else if (assignment.submission_types.includes('discussion_topic')) {
      image = Images.course.discussions
      testID = `assignment-list-row-discussion${testIDSuffix}`
    }
    return (
      <View style={styles.icon} testID={testID}>
        <Icon published={assignment.published} tintColor={this.props.tintColor} style={styles.icon} image={image} />
      </View>
    )
  }
}

const styles = StyleSheet.create({
  row: {
    marginLeft: -10,
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
  icon: {
    alignSelf: 'flex-start',
  },
})
