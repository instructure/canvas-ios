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

// So, the data we get back from the api is a little confusing.
// There is a big mishmash of dates and things spread across the assignment object,
// the overrides object and the all_dates object
// This mashes all that data together so that it's pretty easy to consume
type StagedAssignmentDate = {
  id: ?string, // If empty and base is true, it's a base date. If empty and base is false, this hasn't been saved to the server yet.
  base: boolean,
  title?: string,
  due_at?: ?string,
  unlock_at?: ?string,
  lock_at?: ?string,
  student_ids?: ?string[],
  course_section_id?: ?string,
  group_id?: ?string,
  valid: boolean,
}

type State = {
  dates: StagedAssignmentDate[],
}

// These this component is rendered, it makes a copy of the assignment overrides and uses that as display
// At any time, you can call the results method to get an updated view on edits that were made
// Call validate to perform validation. (validation checks to see if there are any assignees, that's all. :))
export default class AssignmentDatesEditor extends Component<any, Props, any> {
  state: State

  constructor (props: Props) {
    super(props)

    const dateManager = new AssignmentDates(props.assignment)
    const allDates = dateManager.allDates()
    const dates: StagedAssignmentDate[] = allDates.map((date) => {
      let staged: StagedAssignmentDate = {
        id: date.id,
        base: date.base || false,
        title: date.title,
        due_at: date.due_at,
        unlock_at: date.unlock_at,
        lock_at: date.lock_at,
        valid: true,
      }
      const dateID = date.id
      // If the date has an ID, there is a override associated with it
      if (dateID) {
        const override = dateManager.overrideForID(dateID)
        if (override) {
          staged.group_id = override.group_id
          staged.course_section_id = override.course_section_id
          staged.student_ids = override.student_ids
        }
      } else {
        staged.title = (allDates.length > 1) ? i18n('Everyone else') : i18n('Everyone')
      }
      return staged
    }).filter(item => item)

    this.state = {
      dates,
    }
  }

  validate = (): boolean => {
    let valid = true
    this.state.dates.forEach((date) => {
      if (date.base) return
      if (((date.student_ids && date.student_ids.length === 0) || !date.student_ids) &&
          !date.course_section_id &&
          !date.group_id) {
        date.valid = false
        valid = false
      }
    })

    if (!valid) {
      this.setState({
        dates: this.state.dates,
      })
    }

    return valid
  }

  // Once editing is complete, send the staged assignment in here for updates
  updateAssignment = (assignment: Assignment) => {
  }

  addAdditionalDueDate = () => {
    const dates = this.state.dates.slice()
    dates.push({
      id: null,
      base: false,
      valid: true,
    })
    this.setState({
      dates,
    })
  }

  renderDate = (date: StagedAssignmentDate): React.Element<View> => {
    const dateFormatter = (stringDate: ?string): string => {
      return stringDate ? formattedDueDate(new Date(stringDate)) : '--'
    }

    let assigneeStyle = date.valid ? styles.titleText : styles.invalidTitleText

    return (<View style={styles.dateContainer} key={date.id || 'base'}>
              <View style={styles.row}>
                <Text style={assigneeStyle}>{i18n('Assignees')}</Text>
                <Text style={styles.detailText}>{date.title}</Text>
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
    return (<TouchableHighlight style={styles.button} onPress={this.addAdditionalDueDate}>
              <View style={styles.buttonInnerContainer}>
                <Text style={styles.buttonText}>{i18n('Add Due Date')}</Text>
              </View>
            </TouchableHighlight>)
  }

  render (): React.Element<View> {
    const rows = this.state.dates.map(this.renderDate)
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
  invalidTitleText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: 'red',
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
