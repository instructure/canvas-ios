// @flow

import React from 'react'
import { View, StyleSheet, Image } from 'react-native'
import { Title } from '../text'

export type ListEmptyComponentProps = {
  title: string,
  image?: any,
}

export default class ListEmptyComponent extends React.PureComponent<any, ListEmptyComponentProps, any> {
  render () {
    return <View style={styles.container}>
              <Title>{this.props.title}</Title>
              { this.props.image && <Image source={this.props.image} /> }
           </View>
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    height: 100,
  },
})
