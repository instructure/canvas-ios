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

export function Heading2 ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.Text style={[styles.font, styles.h2, style]} {...props} />
}

export function Paragraph ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.Text style={[styles.font, styles.p, style]} {...props} />
}

const styles = StyleSheet.create({
  font: {
    // fontFamily: require('../env').fontFamily,
  },
  h1: {
    fontSize: 20,
    color: colors.darkText,
    fontWeight: '600',
    letterSpacing: -1,
  },
  h2: {
    fontSize: 16,
    color: colors.darkText,
    fontWeight: '400',
    letterSpacing: -1,
  },
  p: {
    fontSize: 16,
    lineHeight: 23,
    color: colors.lightText,
  },
  text: {
    fontSize: 16,
    color: colors.darkText,
  },
})
