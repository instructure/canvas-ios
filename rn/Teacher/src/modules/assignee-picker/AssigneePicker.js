/**
 * @flow
 */

import React, { Component } from 'react'
import {
  View,
  ScrollView,
  Image,
  TouchableHighlight,
  StyleSheet,
} from 'react-native'

import { connect } from 'react-redux'
import { find } from 'lodash'
import i18n from 'format-message'
import colors from '../../common/colors'
import { route } from '../../routing'
import AssigneeRow from './AssigneeRow'
import Images from '../../images'
import { pickerMapStateToProps, type AssigneePickerProps, type Assignee } from './map-state-to-props'
import Actions from './actions.js'
import EnrollmentActions from '../enrollments/actions'
import UserActions from '../users/actions'
import { Text } from '../../common/text'

export class AssigneePicker extends Component<any, AssigneePickerProps, any> {

  static navigatorButtons = {
    rightButtons: [
      {
        title: i18n({
          default: 'Done',
          description: 'Button to close modal',
          id: 'done_edit_assignment',
        }),
        id: 'done',
        testID: 'assignee-picker.dismiss-btn',
      },
    ],
    leftButtons: [
      {
        title: i18n('Cancel'),
        id: 'cancel',
        testID: 'assignee-picker.cancel-btn',
      },
    ],
  }

  constructor (props: AssigneePickerProps) {
    super(props)
    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
    this.state = {
      selected: props.assignees || [],
    }
  }

  componentWillReceiveProps = (props: AssigneePickerProps) => {
    const assignees = props.assignees || []
    const selected = this.state.selected.map((item) => {
      const previous = find(assignees, { id: item.id })
      if (previous) {
        Object.assign(item, previous)
      }
      return item
    })

    const newAssignees = assignees.filter((a) => !find(selected, { id: a.id }))

    this.setState({ selected: [...selected, ...newAssignees] })
  }

  componentDidMount () {
    this.props.refreshSections(this.props.courseID)
    const userIds = this.props.assignees.filter(a => a.type === 'student').map(a => a.dataId)
    this.props.refreshUsers(userIds)
  }

  onNavigatorEvent = (event: NavigatorEvent): void => {
    switch (event.type) {
      case 'NavBarButtonPress':
        switch (event.id) {
          case 'done':
            if (this.props.callback) {
              this.props.callback(this.state.selected || [])
            } else {
              this.props.navigator.dismissModal()
            }
            break
          case 'cancel':
            this.props.navigator.dismissModal()
            break
        }
        break
    }
  }

  addAssignee = (animationStyle: ?string = 'slide-up') => {
    let destination = route(`/courses/${this.props.courseID}/assignee-search`, { onSelection: this.handleSelectedAssignee })
    this.props.navigator.showModal({
      ...destination,
      animationStyle,
    })
  }

  componentWillMount = () => {
    this.props.navigator.setTitle({
      title: i18n('Assignees'),
    })
  }

  handleSelectedAssignee = (assignee: Assignee) => {
    // If trying to add the same assignee twice, DENY
    const existing = find(this.state.selected, { id: assignee.id })
    if (!existing) {
      const selected = [...this.state.selected, assignee]
      this.setState({
        selected,
      })
    }

    this.props.navigator.dismissModal()
  }

  deleteAssignee = (assignee: Assignee) => {
    const selected = this.state.selected.filter((a) => {
      return a.id !== assignee.id
    })

    this.setState({
      selected,
    })
  }

  render (): React.Element<View> {
    return (<ScrollView style={styles.container}>
              { this.state.selected.length > 0 && <View style={styles.space} /> }
              { this.state.selected.map((assignee: Assignee) => <AssigneeRow assignee={assignee} onDelete={this.deleteAssignee} key={assignee.id}/>) }
              <View style={styles.space} />
              <TouchableHighlight style={styles.button} onPress={this.addAssignee}>
                <View style={styles.buttonContainer}>
                  <Image source={Images.add} style={styles.buttonImage} />
                  <Text style={styles.buttonText}>Add Assignee</Text>
                </View>
              </TouchableHighlight>
            </ScrollView>)
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.grey1,
  },
  space: {
    height: 40,
    backgroundColor: colors.grey1,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
  },
  button: {
    height: 54,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
  },
  buttonContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'white',
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
  },
  buttonText: {
    color: colors.primaryButton,
    fontSize: 16,
    fontWeight: '600',
  },
  buttonImage: {
    tintColor: colors.primaryButton,
    marginRight: 8,
    height: 18,
    width: 18,
  },
})

let Connected = connect(pickerMapStateToProps, { ...Actions, ...EnrollmentActions, ...UserActions })(AssigneePicker)
export default (Connected: Component<any, AssigneePickerProps, any>)
