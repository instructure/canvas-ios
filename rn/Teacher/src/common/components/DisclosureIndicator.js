// @flow

import React from 'react'
import { View, StyleSheet } from 'react-native'

export default class DisclosureIndicator extends React.Component {
  render (): React.Element<View> {
    return <View style={styles.disclosureIndicator} />
  }
}

const styles = StyleSheet.create({
  disclosureIndicator: {
    width: 10,
    height: 10,
    marginLeft: 7,
    backgroundColor: 'transparent',
    borderTopWidth: 2,
    borderRightWidth: 2,
    borderColor: '#c7c7cc',
    transform: [{
      rotate: '45deg',
    }],
    alignSelf: 'center',
  },
})
