/**
 * @flow
 */

import React, { Component } from 'react'

import {
  View,
  Text,
  TouchableHighlight,
  TouchableOpacity,
  StyleSheet,
  Alert,
} from 'react-native'
import i18n from 'format-message'
import colors from '../../../common/colors'
import { formattedDueDate } from '../../../common/formatters'
import AssignmentDates from '../../../common/AssignmentDates'
import { route } from '../../../routing'
import { type Assignee } from '../../assignee-picker/map-state-to-props'
import uuid from 'uuid/v1'
import { cloneDeep } from 'lodash'
import EditSectionHeader from './EditSectionHeader'

type Props = {
  assignment: Assignment,
  navigator: ReactNavigator,
}

// So, the data we get back from the api is a little confusing.
// There is a big mishmash of dates and things spread across the assignment object,
// the overrides object and the all_dates object
// This mashes all that data together so that it's pretty easy to consume
export type StagedAssignmentDate = {
  id: string, // Will be the id, or base if it's a base date for everyone. If it's a new date, will have a uuid
  isNew?: boolean, // Is it a new date, meaning it hasn't been pushed to the server yet
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
        id: date.id || 'base',
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
    const dates = this.state.dates.map((date) => {
      if (date.base) { return date }
      if (((date.student_ids && date.student_ids.length === 0) || !date.student_ids) &&
          !date.course_section_id &&
          !date.group_id) {
        const newDate = cloneDeep(date)
        newDate.valid = false
        valid = false
        return newDate
      } else {
        return date
      }
    })

    this.setState({
      dates,
    })

    return valid
  }

  // Once editing is complete, send the staged assignment in here for updates
  updateAssignment = (assignment: Assignment) => {
    return AssignmentDatesEditor.updateAssignmentWithDates(assignment, this.state.dates)
  }

  addAdditionalDueDate = () => {
    const dates = this.state.dates.slice()
    dates.push({
      id: uuid(),
      isNew: true,
      base: false,
      valid: true,
    })
    this.setState({
      dates,
    })
  }

  static updateAssignmentWithDates = (assignment: Assignment, dates: StagedAssignmentDate[]) => {
    const overrides = []
    dates.forEach((date) => {
      if (date.base) {
        assignment.due_at = date.due_at || null
        assignment.lock_at = date.lock_at || null
        assignment.unlock_at = date.unlock_at || null
      } else {
        // $FlowFixMe
        const override: AssignmentOverride = {
          due_at: date.due_at || null,
          unlock_at: date.unlock_at || null,
          lock_at: date.lock_at || null,
        }

        if (date.course_section_id) { override.course_section_id = date.course_section_id }
        if (date.student_ids) { override.student_ids = date.student_ids }
        if (date.group_id) { override.group_id = date.group_id }

        if (!date.isNew) {
          override.id = date.id
        }

        overrides.push(override)
      }
    })

    assignment.overrides = overrides
    return assignment
  }

  static assigneesFromDate = (date: StagedAssignmentDate) => {
    let assignees: Assignee[] = []
    if (date.base) {
      assignees.push({
        id: 'everyone',
        dataId: 'everyone',
        type: 'everyone',
        name: i18n('Everyone'),
      })
    }

    const studentIds = date.student_ids
    if (studentIds) {
      const studentAssignees = studentIds.map((id) => {
        return {
          id: `student-${id}`,
          dataId: id,
          type: 'student',
          name: 'student', // TODO, hrm, where do I get this information at this point?
        }
      })
      assignees = assignees.concat(studentAssignees)
    }

    const sectionId = date.course_section_id
    if (sectionId) {
      assignees.push({
        id: `section-${sectionId}`,
        dataId: sectionId,
        type: 'section',
        name: 'Section',
      })
    }

    const groupId = date.group_id
    if (groupId) {
      assignees.push({
        id: `group-${groupId}`,
        dataId: groupId,
        type: 'group',
        name: 'Group',
      })
    }

    return assignees
  }

  // One dates can turn into many dates, based on what the assignees are
  // For example, if the date previously has a single section, and the user adds multiple sections,
  // That means there is now more than one date, because only one section per date is allowed
  // Although, one date can have multiple students
  static updateDateWithAssignees = (date: StagedAssignmentDate, assignees: Assignee[]): StagedAssignmentDate[] => {
    const createNewDate = (props: Object): StagedAssignmentDate => {
      const aDate = {
        id: date.id,
        base: date.base,
        isNew: true,
        valid: true,
      }

      Object.assign(aDate, props)

      return aDate
    }

    // If all assignees have been removed, it's basically completely new date again
    if (assignees.length === 0) {
      const newDate = createNewDate({
        valid: false,
        base: false,
        id: uuid(),
      })
      return [newDate]
    }

    let base: ?StagedAssignmentDate = null
    let student: ?StagedAssignmentDate = null
    let sections: StagedAssignmentDate[] = []
    let groups: StagedAssignmentDate[] = []

    assignees.forEach((a) => {
      switch (a.type) {
        case 'everyone':
          base = createNewDate({
            id: 'base',
            base: true,
            title: i18n('Everyone'),
          })
          break
        case 'student':
          if (!student) {
            student = createNewDate({
              base: false,
              student_ids: [a.dataId],
            })
          } else {
            const ids = student.student_ids || []
            student.student_ids = ids.concat([a.dataId])
          }
          student.title = i18n(`{
            count, plural,
                =0 {0 students}
              one {# student}
            other {# students}
          }`, { count: (student.student_ids || []).length })
          break
        case 'section':
          sections.push(createNewDate({
            base: false,
            course_section_id: a.dataId,
            title: a.name,
          }))
          break
        case 'group':
          groups.push(createNewDate({
            base: false,
            group_id: a.dataId,
            title: a.name,
          }))
          break
      }
    })

    let newDates: StagedAssignmentDate[] = []
    if (base) { newDates.push(base) }
    if (student) { newDates.push(student) }

    return [...newDates, ...sections, ...groups]
  }

  selectAssignees = (date: StagedAssignmentDate) => {
    const callback = (assignees: Assignee[]) => {
      this.props.navigator.dismissModal()
      const dates = (this.state.dates || []).filter((d) => d.id !== date.id)
      const newDates = AssignmentDatesEditor.updateDateWithAssignees(date, assignees)
      this.setState({
        dates: [...dates, ...newDates],
      })
    }

    let assignees = AssignmentDatesEditor.assigneesFromDate(date)
    let destination = route(`/courses/${this.props.assignment.course_id}/assignee-picker`, { assignees, callback })
    this.props.navigator.showModal(destination)
  }

  removeDate = (date: StagedAssignmentDate) => {
    if (date.base) return

    let remove = () => {
      const dates = this.state.dates.filter((d) => d.id !== date.id)
      this.setState({
        dates,
      })
    }

    Alert.alert(
      i18n('Are you sure?'),
      i18n('You cannot undo this action'),
      [
        { text: i18n('Remove'), onPress: remove, style: 'destructive' },
        { text: i18n('Cancel'), style: 'cancel' },
      ],
      { cancelable: false }
    )
  }

  renderRemoveButton = (date: StagedAssignmentDate): React.Element<View> => {
    if (date.base) return <View />

    return <View style={styles.removeButtonContainer}>
      <TouchableOpacity onPress={() => this.removeDate(date)}>
        <View>
          <Text style={styles.removeButton}>Remove</Text>
        </View>
      </TouchableOpacity>
    </View>
  }

  renderDate = (date: StagedAssignmentDate): React.Element<View> => {
    const dateFormatter = (stringDate: ?string): string => {
      return stringDate ? formattedDueDate(new Date(stringDate)) : '--'
    }

    let assigneeStyle = date.valid ? styles.titleText : styles.invalidTitleText

    let dueDatesTitle = i18n({
      default: 'Assign To',
      description: 'Assignment details due dates header',
    })

    let removeButton = this.renderRemoveButton(date)

    return (<View style={styles.dateContainer} key={date.id || 'base'}>
              <EditSectionHeader title={dueDatesTitle} style={styles.headerText}>
                {removeButton}
              </EditSectionHeader>
              <TouchableHighlight style={styles.row} onPress={() => this.selectAssignees(date)}>
                <View style={styles.rowContainer}>
                  <Text style={assigneeStyle}>{i18n('Assignees')}</Text>
                  <Text style={styles.detailText}>{date.title}</Text>
                </View>
              </TouchableHighlight>
              <TouchableHighlight style={styles.row}>
                <View style={styles.rowContainer}>
                  <Text style={styles.titleText}>{i18n('Due Date')}</Text>
                  <Text style={styles.detailText}>{dateFormatter(date.due_at)}</Text>
                </View>
              </TouchableHighlight>
              <TouchableHighlight style={styles.row}>
                <View style={styles.rowContainer}>
                  <Text style={styles.titleText}>{i18n('Available From')}</Text>
                  <Text style={styles.detailText}>{dateFormatter(date.unlock_at)}</Text>
                </View>
              </TouchableHighlight>
              <TouchableHighlight style={styles.row}>
                <View style={styles.rowContainer}>
                  <Text style={styles.titleText}>{i18n('Available To')}</Text>
                  <Text style={styles.detailText}>{dateFormatter(date.lock_at)}</Text>
                </View>
              </TouchableHighlight>
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
              <View style={styles.space} />
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
    height: 54,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
  },
  rowContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: 'white',
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
  },
  headerText: {
    borderTopWidth: 0,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
  },
  titleText: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.darkText,
  },
  invalidTitleText: {
    fontSize: 16,
    fontWeight: '600',
    color: 'red',
  },
  detailText: {
    fontSize: 16,
    color: '#008EE2',
  },
  space: {
    height: 24,
    backgroundColor: '#F5F5F5',
  },
  button: {
    height: 54,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.seperatorColor,
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
    fontWeight: '600',
    color: '#008EE2',
  },
  removeButtonContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-end',
    alignItems: 'flex-end',
    paddingRight: global.style.defaultPadding,
    paddingTop: 14,
  },
  removeButton: {
    fontSize: 12,
    color: 'red',
    fontWeight: '500',
  },
})
