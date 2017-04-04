/**
 * @flow
 */

import React from 'react'
import ReactNative, {
  StyleSheet,
} from 'react-native'
import colors from './colors'

export function Text ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.Text style={[styles.font, styles.text, style]} {...props} />
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

export function TextInput ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.TextInput style={[styles.font, styles.textInput, style]} {...props} />
}

export function ModalActivityIndicatorAlertText ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.Text style={[styles.font, styles.modalActivityIndicatorAlertText, style]} {...props} />
}

const styles = StyleSheet.create({
  font: {
    fontFamily: '.SFUIDisplay',
  },
  h1: {
    fontSize: 20,
    color: colors.darkText,
    fontFamily: '.SFUIDisplay-semibold',
  },
  h2: {
    fontSize: 16,
    color: colors.darkText,
    fontFamily: '.SFUIDisplay-medium',
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
  textInput: {
  },
  modalActivityIndicatorAlertText: {
    fontSize: 24,
    color: '#fff',
    fontFamily: '.SFUIDisplay-semibold',
  },
})
