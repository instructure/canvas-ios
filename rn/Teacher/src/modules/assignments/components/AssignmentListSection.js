/**
* @flow
*/

import React, { Component, Element } from 'react'
import {
  View,
  Text,
  StyleSheet,
} from 'react-native'

type Props = {
  assignmentGroup: AssignmentGroup,
  onPress: (AssignmentGroup) => void,
}

export default class AssignmentListSection extends Component<any, Props, any> {
  onPress = () => {
    const assignmentGroup = this.props.assignmentGroup
    this.props.onPress(assignmentGroup)
  }

  render (): Element<View> {
    const group = this.props.assignmentGroup
    return (
      <View style={styles.section} key={group.id}>
        <Text style={styles.title}>{group.name}</Text>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  section: {
    flex: 1,
    height: 24,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
    backgroundColor: '#f5f5f5',
    justifyContent: 'center',
    paddingLeft: 8,
    paddingRight: 8,
  },
  title: {
    backgroundColor: '#f5f5f5',
    color: '#73818b',
    fontWeight: 'bold',
  },
})
