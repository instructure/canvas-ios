/**
 * @flow
 */

import React, { Component } from 'react'
import {
  View,
  ScrollView,
  Text,
  Image,
  TouchableHighlight,
  StyleSheet,
} from 'react-native'

import i18n from 'format-message'
import colors from '../../common/colors'
import { route } from '../../routing'
import AssigneeRow from './AssigneeRow'
import Images from '../../images'

export type Props = {
  courseID: string,
  assignees: Assignee[],
  navigator: ReactNavigator,
}

export type Assignee = {
  id: string, // A combindation of dataId and type, so `student-2343` or `everyone`
  dataId: string, // the id from the actual data, which could collide across types
  type: 'student' | 'section' | 'everyone',
  name: string,
  info?: string, // Generally used as the subtitle in the AssigneeRow
  imageURL?: ?string,
}

export default class AssigneePicker extends Component<any, Props, any> {

  static navigatorButtons = {
    rightButtons: [
      {
        title: i18n({
          default: 'Done',
          description: 'Button to close modal',
          id: 'done_edit_assignment',
        }),
        id: 'dismiss',
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

  constructor (props: Props) {
    super(props)

    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
    this.state = {
      selected: props.assignees || [],
    }
  }

  onNavigatorEvent = (event: NavigatorEvent): void => {
    if (event.type === 'NavBarButtonPress') {
      if (event.id === 'cancel') {
        this.props.navigator.dismissModal()
      }
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
    const selected = [...this.state.selected, assignee]
    this.setState({
      selected,
    })
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
    fontWeight: 'bold',
  },
  buttonImage: {
    tintColor: colors.primaryButton,
    marginRight: 8,
  },
})
