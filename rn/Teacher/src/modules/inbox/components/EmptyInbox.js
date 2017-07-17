// @flow

import React, { PureComponent } from 'react'
import { View, Image, StyleSheet } from 'react-native'
import { Text } from '../../../common/text'

export default class EmptyInbox extends PureComponent {
  render () {
    return (
      <View style={styles.container}>
        <Image style={styles.image} source={this.props.image} />
        <Text style={styles.title}>{this.props.title}</Text>
        <Text style={styles.text}>{this.props.text}</Text>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 50,
    height: 400,
  },
  image: {
    marginBottom: 36,
  },
  title: {
    fontSize: 24,
    fontWeight: '600',
    textAlign: 'center',
    marginBottom: 4,
  },
  text: {
    color: '#8B969E',
    fontSize: 16,
    textAlign: 'center',
  },
})
