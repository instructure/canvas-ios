/**
 * @flow
 */

import React from 'react'
import ReactNative, {
  StyleSheet,
} from 'react-native'
import BaseButton from 'react-native-button'

export function Button ({ style, containerStyle, ...props }: Object): ReactNative.TouchableHighlight {
  return <BaseButton style={[styles.textColor, style]} containerStyle={[styles.container, containerStyle]} {...props} />
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#368BD8',
    overflow: 'hidden',
    padding: 20,
    borderRadius: 8,
  },
  textColor: {
    color: '#fff',
  },
})
