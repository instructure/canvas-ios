/**
 * @flow
 */

import React from 'react'
import ReactNative, {
  View,
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
  return <ReactNative.Text style={[styles.font, styles.h1, style]} {...props} accessibilityTraits='header' />
}

export function Heading2 ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.Text style={[styles.font, styles.h2, style]} {...props} />
}

export function Title ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.Text style={[styles.font, styles.title, style]} { ...props } />
}

export function SubTitle ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.Text style={[styles.font, styles.subtitle, style]} { ...props } />
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

export function UnmetRequirementBannerText ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.Text style={[styles.font, styles.unmetRequirementBannerText, style]} {...props} />
}

export function UnmetRequirementSubscriptText ({ style, ...props }: Object): ReactNative.Text {
  return <ReactNative.Text style={[styles.font, styles.unmetRequirementSubscriptText, style]} {...props} />
}

export function SectionHeader ({ style, ...props }: Object): ReactNative.Element<View> {
  return (
    <View style={styles.sectionHeader} key={props.key}>
      <Text style={styles.sectionHeaderTitle} {...props} accessibilityTraits='header' />
    </View>
  )
}

export function Separated (props: Object): ReactNative.Element<View> {
  const separator = (
    <Text
      style={[props.style, { fontSize: props.separatorFontSize || 10, alignSelf: 'center' }]}
    >
      {props.separator}
    </Text>
  )
  const result = props.separated
    .slice(1)
    .reduce((incoming, value) => incoming.concat([
      separator,
      <Text {...props}>{value}</Text>,
    ]), [<Text {...props}>{props.separated[0]}</Text>])
  return (
    <View style={{ flexDirection: 'row' }}>
      {result}
    </View>
  )
}

export function DotSeparated (props: Object): ReactNative.Element<*> {
  return <Separated {...props} separator={'  •  '} />
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
  title: {
    fontSize: 16,
    fontFamily: SEMI_BOLD_FONT,
    color: colors.darkText,
  },
  subtitle: {
    fontSize: 14,
    color: colors.lightText,
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
  unmetRequirementBannerText: {
    fontSize: 12,
    color: '#fff',
    fontFamily: MEDIUM_FONT,
  },
  unmetRequirementSubscriptText: {
    fontSize: 14,
    color: '#EE0612',
    fontFamily: REGULAR_FONT,
  },
  sectionHeader: {
    flex: 1,
    height: 24,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#C7CDD1',
    backgroundColor: '#F5F5F5',
    justifyContent: 'center',
    paddingLeft: 16,
    paddingRight: 8,
  },
  sectionHeaderTitle: {
    fontSize: 14,
    backgroundColor: '#F5F5F5',
    color: '#73818C',
    fontWeight: '600',
  },
})
