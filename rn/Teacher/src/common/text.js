//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

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

export const REGULAR_FONT = '.SFUIDisplay'
export const REGULAR_FONT_ITALIC = '.SFUIDisplay-italic'
export const MEDIUM_FONT = '.SFUIDisplay-medium'
export const MEDIUM_FONT_ITALIC = 'SFUIDisplay-medium-italic'
export const SEMI_BOLD_FONT = '.SFUIDisplay-semibold'
export const SEMI_BOLD_FONT_ITALIC = '.SFUIDisplay-semibold-italic'
export const BOLD_FONT = '.SFUIDisplay-bold'
export const BOLD_FONT_ITALIC = '.SFUIDisplay-bold-italic'
export const HEAVY_FONT = '.SFUIDisplay-heavy'
export const HEAVY_FONT_ITALIC = '.SFUIDisplay-heavy-italic'

export function Text ({ style, ...props }: Object) {
  let font = fontFamilyFromStyle(style)
  return <ReactNative.Text style={ [styles.font, styles.text, style, { fontFamily: font }] } {...props} />
}

Text.propTypes = ReactNative.Text.propTypes

export function Heading1 ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.font, styles.h1, style]} {...props} accessibilityTraits='header' />
}

export function Heading2 ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.font, styles.h2, style]} {...props} />
}

export function Title ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.font, styles.title, style]} { ...props } />
}

export function SubTitle ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.font, styles.subtitle, style]} { ...props } />
}

export function Paragraph ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.font, styles.p, style]} {...props} />
}

export function Heavy ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.heavy, style]} {...props} />
}

export function TextInput ({ style, ...props }: Object) {
  let font = fontFamilyFromStyle(style)
  return <ReactNative.TextInput style={[styles.font, styles.textInput, style, { fontFamily: font }]} {...props} />
}

export function ModalOverlayText ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.font, styles.modalOverlayText, style]} {...props} />
}

export function UnmetRequirementBannerText ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.font, styles.unmetRequirementBannerText, style]} {...props} />
}

export function UnmetRequirementSubscriptText ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.font, styles.unmetRequirementSubscriptText, style]} {...props} />
}

export function Separated (props: Object) {
  const uniqueKey = Math.random().toString(36).substr(2, 16)
  let count = 0
  const result = props.separated
    .slice(1)
    .reduce((incoming, value) => incoming.concat([
      <Text key={`separated_key_${uniqueKey}_${count++}`}
        style={[
          props.style,
          {
            fontSize: props.separatorFontSize || 10,
            alignSelf: 'center',
            color: colors.grey4,
          },
        ]}
      >
        {props.separator}
      </Text>,
      <Text {...props} key={`separated_value_${uniqueKey}_${count}`}>{value}</Text>,
    ]),
    [<Text {...props} key={props.separated[0]}>{props.separated[0]}</Text>])
  return (
    <View style={{ flexDirection: 'row' }}>
      {result}
    </View>
  )
}

export function DotSeparated (props: Object) {
  return <Separated {...props} separator={'  •  '} />
}

const FontWeight = {
  normal: {
    normal: REGULAR_FONT,
    italic: REGULAR_FONT_ITALIC,
  },
  bold: { // 700 weight
    normal: BOLD_FONT,
    italic: BOLD_FONT_ITALIC,
  },
  semibold: { // 600 weight
    normal: SEMI_BOLD_FONT,
    italic: SEMI_BOLD_FONT_ITALIC,
  },
  medium: { // 500 weight
    normal: MEDIUM_FONT,
    italic: MEDIUM_FONT_ITALIC,
  },
  '700': { // 700 weight
    normal: BOLD_FONT,
    italic: BOLD_FONT_ITALIC,
  },
  '600': {
    normal: SEMI_BOLD_FONT,
    italic: SEMI_BOLD_FONT_ITALIC,
  },
  '500': {
    normal: MEDIUM_FONT,
    italic: MEDIUM_FONT_ITALIC,
  },
  '400': {
    normal: REGULAR_FONT,
    italic: REGULAR_FONT_ITALIC,
  },
  '300': {
    normal: REGULAR_FONT,
    italic: REGULAR_FONT_ITALIC,
  },
}

function fontFamilyFromStyle (style: Object): string {
  let styleObj = flattenStyle(style) || {}
  let fontWeight = styleObj.fontWeight || 'normal'
  let fontStyle = styleObj.fontStyle || 'normal'
  return FontWeight[fontWeight][fontStyle]
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
  heavy: {
    fontSize: 24,
    color: colors.darkText,
    fontFamily: HEAVY_FONT,
  },
  text: {
    fontSize: 16,
    color: colors.darkText,
  },
  textInput: {
    fontSize: 17,
  },
  modalOverlayText: {
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
