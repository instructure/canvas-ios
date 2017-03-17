/**
* @flow
*/

import React, { Component } from 'react'
import { connect } from 'react-redux'

import AssignmentDetailsActions from './actions'
import { stateToProps } from './props'

import {
  View,
  Text,
} from 'react-native'

type Props = {
  assignmentID: string,
}

export class AssignmentDetails extends Component<any, Props, any> {
  render (): React.Element<View> {
    return (
      <View>
        <Text>{this.props.assignmentID}</Text>
      </View>
    )
  }
}

const Connected = connect(stateToProps, AssignmentDetailsActions)(AssignmentDetails)
export default (Connected: Component<any, Props, any>)
