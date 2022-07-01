//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/**
 * @flow
 */

import * as React from 'react'
import ReactNative, {
  View,
} from 'react-native'
import { colors, createStyleSheet } from './stylesheet'

export function Text ({ style, ...props }: Object) {
  return <ReactNative.Text style={ [styles.text, style] } {...props} />
}

Text.propTypes = ReactNative.Text.propTypes
type TextProps = React.ElementConfig<typeof ReactNative.Text>

export function Heading1 ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.h1, style]} {...props} accessibilityRole='header' />
}

export function Heading2 ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.h2, style]} {...props} />
}

export function Title ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.title, style]} { ...props } />
}

export function SubTitle ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.subtitle, style]} { ...props } />
}

export function Paragraph ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.p, style]} {...props} />
}

export function Heavy ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.heavy, style]} {...props} />
}

export function FormLabel ({ style, ...props }: TextProps) {
  return <ReactNative.Text style={[styles.formLabel, style]} accessibilityTraits='header' {...props} />
}

export function TextInput ({ style, ...props }: Object) {
  return <ReactNative.TextInput style={[styles.textInput, style]} {...props} />
}

export function ModalOverlayText ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.modalOverlayText, style]} {...props} />
}

export function UnmetRequirementBannerText ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.unmetRequirementBannerText, style]} {...props} />
}

export function UnmetRequirementSubscriptText ({ style, ...props }: Object) {
  return <ReactNative.Text style={[styles.unmetRequirementSubscriptText, style]} {...props} />
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
            color: colors.textDark,
          },
        ]}
        accessibilityLabel=''
        accessible={false}
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

const k5Font = 'BalsamiqSans-Regular'
const regularFont = 'Lato-Regular'
const styles = createStyleSheet((colors, vars) => ({
  h1: {
    fontSize: 24,
    color: colors.textDarkest,
    fontWeight: '800',
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  h2: {
    fontSize: 16,
    color: colors.textDarkest,
    fontWeight: 'bold',
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.textDarkest,
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  subtitle: {
    fontSize: 14,
    color: colors.textDark,
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  p: {
    fontSize: 16,
    lineHeight: 23,
    color: colors.textDark,
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  heavy: {
    fontSize: 24,
    color: colors.textDarkest,
    fontWeight: '800',
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  text: {
    fontSize: 16,
    color: colors.textDarkest,
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  formLabel: {
    color: colors.textDark,
    fontSize: 14,
    fontWeight: '600',
    marginLeft: vars.padding,
    marginTop: vars.padding,
    marginBottom: vars.padding / 2,
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  textInput: {
    fontSize: 17,
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  modalOverlayText: {
    fontSize: 24,
    color: colors.textLightest,
    fontWeight: '600',
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  unmetRequirementBannerText: {
    fontSize: 12,
    color: colors.white,
    fontWeight: '500',
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  unmetRequirementSubscriptText: {
    fontSize: 14,
    color: colors.textDanger,
    fontWeight: 'normal',
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  sectionHeader: {
    flex: 1,
    height: 24,
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
    backgroundColor: colors.backgroundLight,
    justifyContent: 'center',
    paddingLeft: 16,
    paddingRight: 8,
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  sectionHeaderTitle: {
    fontSize: 14,
    backgroundColor: colors.backgroundLight,
    color: colors.textDark,
    fontWeight: '600',
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
}))
