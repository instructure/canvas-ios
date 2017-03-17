/**
* @flow
*/

import React, { Component, Element } from 'react'
import {
  View,
  TouchableHighlight,
  Text,
  StyleSheet,
} from 'react-native'

import Icon from './AssignmentListRowIcon'

type Props = {
  assignment: Assignment,
  onPress: (Assignment) => void,
}

export default class AssignmentListRow extends Component<any, Props, any> {
  onPress = () => {
    const assignment = this.props.assignment
    this.props.onPress(assignment)
  }

  render (): Element<View> {
    const assignment = this.props.assignment
    return (
      <View style={styles.row} key={assignment.id}>
        <TouchableHighlight style={styles.touchableHighlight} onPress={this.onPress}>
          <View style={styles.container}>
            <Icon published={assignment.published} />
            <Text
              style={styles.title}
              ellipsizeMode='tail'
              numberOfLines={2}>{assignment.name}</Text>
          </View>
        </TouchableHighlight>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  row: {
    flex: 1,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
  },
  touchableHighlight: {
    flex: 1,
  },
  container: {
    flex: 1,
    padding: 8,
    backgroundColor: 'white',
    alignItems: 'center',
    flexDirection: 'row',
  },
  title: {
    flex: 1,
    fontSize: 17,
    fontWeight: 'bold',
    color: '#2d3b44',
  },
})
