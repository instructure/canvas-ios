/**
 * @flow
 */

import React from 'react'
import ReactNative, {
  StyleSheet,
} from 'react-native'
import colors from './colors'

export function Text ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.Text style={[styles.font, style]} {...props} />
}

export function Heading1 ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.Text style={[styles.font, styles.h1, style]} {...props} />
}

export function Paragraph ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.Text style={[styles.font, styles.p, style]} {...props} />
}

const styles = StyleSheet.create({
  font: {
    // fontFamily: require('../env').fontFamily,
  },
  h1: {
    fontSize: 24,
    lineHeight: 27,
    color: colors.darkText,
    fontWeight: 'bold',
    letterSpacing: -1,
  },
  p: {
    fontSize: 16,
    lineHeight: 23,
    color: colors.lightText,
  },
})
