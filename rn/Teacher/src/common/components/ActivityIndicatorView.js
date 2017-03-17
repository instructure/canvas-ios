// @flow

import React from 'react'
import { View, StyleSheet, ActivityIndicator } from 'react-native'

type Props = {
  height: number,
}

export default class DisclosureIndicator extends React.Component<any, Props, any> {
  render (): React.Element<View> {
    return <View style={{ height: this.props.height }}>
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
