/**
 * @flow
 */

import React from 'react'
import ReactNative, {
  StyleSheet,
} from 'react-native'
import BaseButton from 'react-native-button'
import colors from './colors'

export function Button ({ style, containerStyle, ...props }: Object): ReactNative.TouchableHighlight {
  return <BaseButton style={[styles.textColor, style]} containerStyle={[styles.container, containerStyle]} {...props} />
}

export function Link ({ style, containerStyle, ...props }: Object): ReactNative.TouchableHighlight {
  return <BaseButton style={[styles.linkTextColor, style]} containerStyle={containerStyle} {...props} />
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
  linkTextColor: {
    color: colors.prettyBlue,
  },
})
