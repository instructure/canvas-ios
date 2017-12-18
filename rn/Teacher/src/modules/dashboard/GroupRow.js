// @flow

import React from 'react'
import {
  View,
  TouchableHighlight,
  StyleSheet,
} from 'react-native'
import DashboardContent from './DashboardContent'
import {
  Text,
  SubTitle,
} from '../../common/text'

export type GroupRowProps = {
  id: string,
  color: string,
  name: string,
  contextName: string,
  term?: string,
  style?: any,
}

export default class GroupRow extends React.Component<GroupRowProps & { onPress: (string) => void }> {
  navigateToGroup = () => {
    this.props.onPress(this.props.id)
  }

  render () {
    const {
      id,
      name,
      contextName,
      color,
      term,
    } = this.props
    return (
      <TouchableHighlight
        onPress={this.navigateToGroup}
        underlayColor='transparent'
        testID={`group-row-${id}`}
      >
        <View>
          <DashboardContent
            style={this.props.style}
            contentStyle={styles.rowContent}
          >
            <View style={[styles.groupColor, { backgroundColor: color }]} />
            <View style={styles.groupDetails}>
              <Text style={styles.title}>{name}</Text>
              <SubTitle style={[{ color }, styles.context]}>{contextName}</SubTitle>
              {term && <SubTitle style={styles.term}>{term.toUpperCase()}</SubTitle>}
            </View>
          </DashboardContent>
        </View>
      </TouchableHighlight>
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
    minHeight: 82,
  },
  groupColor: {
    width: 4,
  },
  groupDetails: {
    margin: 8,
  },
  context: {
    fontWeight: '600',
    fontSize: 16,
  },
  title: {
    fontWeight: '600',
    fontSize: 18,
  },
  term: {
    fontSize: 12,
    fontWeight: '600',
  },
})
