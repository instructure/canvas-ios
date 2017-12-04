// @flow

import React from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import DashboardContent from './DashboardContent'
import {
  Text,
  SubTitle,
} from '../../common/text'

export type GroupRowProps = {
  color: string,
  name: string,
  courseName: string,
  term: string,
  style?: any,
}

export default class GroupRow extends React.Component<GroupRowProps> {
  render () {
    const {
      name,
      courseName,
      color,
      term,
    } = this.props
    return (
      <DashboardContent
        style={this.props.style}
        contentStyle={styles.rowContent}
      >
        <View style={[styles.groupColor, { backgroundColor: color }]} />
        <View style={styles.groupDetails}>
          <Text style={styles.title}>{name}</Text>
          <SubTitle style={{ color }}>{courseName}</SubTitle>
          <SubTitle style={{ fontSize: 12 }}>{term.toUpperCase()}</SubTitle>
        </View>
      </DashboardContent>
    )
  }
}

const styles = StyleSheet.create({
  icon: {
    tintColor: 'white',
    marginTop: 15.5,
  },
  rowContent: {
    flexDirection: 'row',
  },
  groupColor: {
    width: 4,
  },
  groupDetails: {
    margin: 8,
  },
  title: {
    fontWeight: '600',
  },
})
