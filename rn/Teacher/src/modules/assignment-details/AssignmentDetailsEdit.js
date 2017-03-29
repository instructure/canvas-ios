/**
 * @flow
 */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import { mapStateToProps, type AssignmentDetailsProps } from './map-state-to-props'
import i18n from 'format-message'
import EditSectionHeader from './components/EditSectionHeader'
import { PADDING } from './../../common/globalStyle'
import {
  View,
  StyleSheet,
  ScrollView,
  TextInput,
} from 'react-native'

export class AssignmentDetailsEdit extends Component<any, AssignmentDetailsProps, any> {
  props: AssignmentDetailsProps

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
  }

  render (): React.Element<View> {
    let assignment = this.props.assignmentDetails

    let sectionTitle = i18n({
      default: 'Title',
      description: 'Assignment details edit title header',
    })

    return (
      <ScrollView style={style.container}>
        <EditSectionHeader title={sectionTitle}/>
        <View style={style.row} >
          <TextInput style={style.title } editable = {true} value={assignment.name} multiline={true} numberOfLines={4}/>
        </View>
      </ScrollView>
    )
  }

  onNavigatorEvent = (event: NavigatorEvent) => {
    switch (event.type) {
      case 'NavBarButtonPress':
        switch (event.id) {
          case 'dismiss':
            this.closeModal()
            break
        }
        break
    }
  }

  closeModal () {
    this.props.navigator.dismissModal()
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
  },
  row: {
    padding: PADDING,
  },
  title: {
    height: 100,
  },
})

let Connected = connect(mapStateToProps, undefined)(AssignmentDetailsEdit)
export default (Connected: Component<any, AssignmentDetailsProps, any>)
