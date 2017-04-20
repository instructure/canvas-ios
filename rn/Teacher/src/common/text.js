/**
 * @flow
 */

import React from 'react'
import ReactNative, {
  StyleSheet,
} from 'react-native'
import colors from './colors'
import flattenStyle from 'flattenStyle'

const REGULAR_FONT = '.SFUIDisplay'
export const MEDIUM_FONT: string = '.SFUIDisplay-medium'
const SEMI_BOLD_FONT = '.SFUIDisplay-semibold'
export const BOLD_FONT: string = '.SFUIDisplay-bold'

export function Text ({ style, ...props }: Object): ReactNative.Text {
  let font = fontFamilyFromStyle(style)
  return <ReactNative.Text style={ [styles.font, styles.text, style, { fontFamily: font }] } {...props} />
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
  let font = fontFamilyFromStyle(style)
  return <ReactNative.TextInput style={[styles.font, styles.textInput, style, { fontFamily: font }]} {...props} />
}

export function ModalActivityIndicatorAlertText ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.Text style={[styles.font, styles.modalActivityIndicatorAlertText, style]} {...props} />
}

const FontWeight: { [string]: string } = {
  normal: REGULAR_FONT,
  bold: BOLD_FONT,            // 700 weight
  semibold: SEMI_BOLD_FONT,   // 600 weight
  '700': BOLD_FONT,
  '600': SEMI_BOLD_FONT,
  '500': MEDIUM_FONT,
  '300': REGULAR_FONT,
}

function fontFamilyFromStyle (style: Object): string {
  let styleObj = flattenStyle(style) || {}
  let fontWeight = styleObj.fontWeight
  let defaultKey = 'normal'
  let weight = fontWeight || defaultKey
  return FontWeight[weight] || FontWeight[defaultKey]
}

const styles = StyleSheet.create({
  font: {
    fontFamily: REGULAR_FONT,
  },
  h1: {
    fontSize: 20,
    color: colors.darkText,
    fontFamily: SEMI_BOLD_FONT,
  },
  h2: {
    fontSize: 16,
    color: colors.darkText,
    fontFamily: BOLD_FONT,
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
    fontSize: 17,
  },
  modalActivityIndicatorAlertText: {
    fontSize: 24,
    color: '#fff',
    fontFamily: SEMI_BOLD_FONT,
  },
})
