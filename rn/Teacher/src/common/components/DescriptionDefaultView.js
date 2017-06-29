// @flow

import React from 'react'
import {
    View,
    Text,
    StyleSheet,
} from 'react-native'

type Props = {
  text: string,
  testID: string,
}

export default class DescriptionDefaultView extends React.Component<any, Props, any> {

  render () {
    return (
      <View style={[styles.container]} testID={`${this.props.testID}.view`}>
        <Text style={styles.text}>{this.props.text}</Text>
      </View>
    )
  }
}

DescriptionDefaultView.defaultProps = {
  text: 'Help your students with this assignment by adding instructions.',
}

const styles = StyleSheet.create({
  container: {
    height: 56,
    marginTop: 4,
    paddingTop: 8,
    paddingHorizontal: 12,
    paddingBottom: 12,
    backgroundColor: '#F5F5F5',
    borderRadius: 3,
  },
  text: {
    alignItems: 'flex-start',
    textAlign: 'left',
    color: '#73818C',
    fontSize: 14,
  },
})
