// @flow

import React from 'react'
import { View, StyleSheet, ActivityIndicator } from 'react-native'

export default class ActivityIndicatorView extends React.Component<any, any, any> {
  render (): React.Element<View> {
    return <View style={styles.container}>
              <ActivityIndicator style={styles.indicator} />
           </View>
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  indicator: {
    flex: 1,
  },
})
