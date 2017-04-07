/**
 * @flow
 */

import React, { Component } from 'react'

import {
  View,
  Text,
  TouchableHighlight,
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import colors from '../../../common/colors'
import { formattedDueDate } from '../../../common/formatters'
import AssignmentDates from '../../../common/AssignmentDates'

type Props = {
  assignment: Assignment,
}

export default class AssignmentDatesEditor extends Component<any, Props, any> {

  renderDate = (date: AssignmentDate): React.Element<View> => {
    const dateFormatter = (stringDate: ?string): string => {
      return stringDate ? formattedDueDate(new Date(stringDate)) : '--'
    }

    let title = date.title
    if (date.base) {
      const dates = new AssignmentDates(this.props.assignment)
      if (dates.allDates().length > 1) {
        title = i18n('Everyone else')
      } else {
        title = i18n('Everyone')
      }
    }

    return (<View style={styles.dateContainer} key={date.id || 'base'}>
              <View style={styles.row}>
                <Text style={styles.titleText}>{i18n('Assignees')}</Text>
                <Text style={styles.detailText}>{title}</Text>
              </View>
              <View style={styles.row}>
                <Text style={styles.titleText}>{i18n('Due Date')}</Text>
                <Text style={styles.detailText}>{dateFormatter(date.due_at)}</Text>
              </View>
              <View style={styles.row}>
                <Text style={styles.titleText}>{i18n('Available From')}</Text>
                <Text style={styles.detailText}>{dateFormatter(date.unlock_at)}</Text>
              </View>
              <View style={styles.row}>
                <Text style={styles.titleText}>{i18n('Available To')}</Text>
                <Text style={styles.detailText}>{dateFormatter(date.lock_at)}</Text>
              </View>
              <View style={styles.space} />
            </View>)
  }

  renderButton = (): React.Element<View> => {
    return (<TouchableHighlight style={styles.button}>
              <View style={styles.buttonInnerContainer}>
                <Text style={styles.buttonText}>{i18n('Add Due Date')}</Text>
              </View>
            </TouchableHighlight>)
  }

  render (): React.Element<View> {
    const dates = new AssignmentDates(this.props.assignment)
    const rows = dates.allDates().map(this.renderDate)
    const button = this.renderButton()
    return (<View style={styles.container}>
              {rows}
              {button}
              <View style={styles.space} />
            </View>)
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  dateContainer: {

  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    height: 54,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
  },
  titleText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: colors.darkText,
  },
  detailText: {
    fontSize: 16,
    fontWeight: '500',
    color: '#008EE2',
  },
  space: {
    height: 24,
    backgroundColor: '#F5F5F5',
  },
  button: {
    height: 54,
  },
  buttonInnerContainer: {
    flex: 1,
    backgroundColor: 'white',
    flexDirection: 'row',
    alignItems: 'center',
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
  },
  buttonText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#008EE2',
  },
})
