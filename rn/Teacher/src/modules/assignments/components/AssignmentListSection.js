/**
* @flow
*/

import React from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import { Text } from '../../../common/text'

type Props = {
  assignmentGroup: AssignmentGroup,
  onPress: (AssignmentGroup) => void,
}

export default class AssignmentListSection extends React.Component<any, Props, any> {

  render () {
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
    borderBottomColor: '#C7CDD1',
    backgroundColor: '#F5F5F5',
    justifyContent: 'center',
    paddingLeft: 16,
    paddingRight: 8,
  },
  title: {
    fontSize: 14,
    backgroundColor: '#F5F5F5',
    color: '#73818C',
    fontWeight: '600',
  },
})
