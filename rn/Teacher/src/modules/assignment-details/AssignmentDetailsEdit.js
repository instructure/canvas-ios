/**
 * @flow
 */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import { updateMapStateToProps, type AssignmentDetailsProps } from './map-state-to-props'
import AssignmentActions from '../assignments/actions'
import i18n from 'format-message'
import EditSectionHeader from './components/EditSectionHeader'
import { TextInput } from '../../common/text'
import ModalActivityIndicator from '../../common/components/ModalActivityIndicator'
import { Navigation } from 'react-native-navigation'
import {
  View,
  StyleSheet,
  ScrollView,
} from 'react-native'

export class AssignmentDetailsEdit extends Component<any, AssignmentDetailsProps, any> {
  props: AssignmentDetailsProps
  state: any = {}

  static navigatorButtons = {
    rightButtons: [
      {
        title: i18n({
          default: 'Done',
          description: 'Button to close modal',
          id: 'done_edit_assignment',
        }),
        id: 'dismiss',
        testID: 'edit-assignment.dismiss-btn',
      },
    ],
  }

  constructor (props: AssignmentDetailsProps) {
    super(props)
    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
    this.state = { assignment: Object.assign({}, props.assignmentDetails) }
  }

  componentDidMount () {
    this.props.navigator.setTitle({
      title: i18n({
        default: 'Edit Assignment Details',
        description: 'Title of Assignment details EDIT screen',
      }),
    })
  }

  render (): React.Element<View> {
    let sectionTitle = i18n({
      default: 'Title',
      description: 'Assignment details edit title header',
    })

    let savingText = i18n({
      default: 'Saving',
      description: 'Text when a request to update an assignment is made and user is waiting',
    })

    let assignmentTitlePlaceHolder = i18n({ default: 'Title', description: 'Assignemnt details title placeholder' })

    return (
      <View style={{ flex: 1 }}>
        <ModalActivityIndicator text={savingText} visible={this.state.pending > 0}/>
        <ScrollView style={style.container}>
        <EditSectionHeader title={sectionTitle}/>
        <View style={style.row} >
          <TextInput style={style.title}
                     value={ this.defaultValueForInput('name') }
                     multiline={ true }
                     placeholder={assignmentTitlePlaceHolder}
                     onChangeText={ title => this.updateFromInput('name', title) }
                     testID='titleInput'
          />
        </View>
        </ScrollView>
      </View>
    )
  }

  updateFromInput (key: string, value: string) {
    const assignment = this.state.assignment
    assignment[key] = value
    this.setState({ assignment })
  }

  defaultValueForInput (key: string): string {
    let assignment = this.state.assignment
    return assignment[key].toString()
  }

  onNavigatorEvent = (event: NavigatorEvent) => {
    switch (event.type) {
      case 'NavBarButtonPress':
        switch (event.id) {
          case 'dismiss':
            this.actionDonePressed()
            break
        }
        break
    }
  }

  actionDonePressed () {
    this.setState({ pending: 1 })
    this.props.updateAssignment(this.props.courseID, this.state.assignment, this.props.assignmentDetails)
  }

  componentWillReceiveProps (nextProps: AssignmentDetailsProps) {
    if (this.state.pending && (nextProps.assignmentDetails && !nextProps.pending)) {
      this.setState({ pending: 0 })
      if (!nextProps.error) {
        Navigation.dismissAllModals()
      }
    }
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
  },
  row: {
    paddingTop: global.style.defaultPadding / 2,
    paddingBottom: global.style.defaultPadding / 2,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
  },
  title: {
    height: 45,
  },
})

let Connected = connect(updateMapStateToProps, AssignmentActions)(AssignmentDetailsEdit)
export default (Connected: Component<any, AssignmentDetailsProps, any>)
