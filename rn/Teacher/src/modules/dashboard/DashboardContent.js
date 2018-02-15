// @flow

import * as React from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'

export default ({ children, style, contentStyle, hideShadow, ...props }: {
  children?: React.Node,
  style?: any,
  contentStyle?: any,
  hideShadow?: boolean,
}) => (
  <View {...props} style={[!hideShadow && styles.shadow, style]}>
    <View style={[styles.content, contentStyle]}>
      {children}
    </View>
  </View>
)

const styles = StyleSheet.create({
  shadow: {
    shadowColor: '#000',
    shadowRadius: 1,
    shadowOpacity: 0.2,
    shadowOffset: {
      width: 0,
      height: 1,
    },
    backgroundColor: '#ffffff01',
  },
  content: {
    borderColor: '#e3e3e3',
    borderWidth: StyleSheet.hairlineWidth,
    borderRadius: 4,
    overflow: 'hidden',
    flex: 1,
    backgroundColor: 'white',
  },
})
