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
  StyleSheet,
} from 'react-native'
import colors from './colors'

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
            color: colors.grey4,
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

const styles = StyleSheet.create({
  h1: {
    fontSize: 24,
    color: colors.darkText,
    fontWeight: '800',
  },
  h2: {
    fontSize: 16,
    color: colors.darkText,
    fontWeight: 'bold',
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
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
    fontWeight: '800',
  },
  text: {
    fontSize: 16,
    color: colors.darkText,
  },
  formLabel: {
    color: colors.grey5,
    fontSize: 14,
    fontWeight: '600',
    marginLeft: global.style.defaultPadding,
    marginTop: global.style.defaultPadding,
    marginBottom: global.style.defaultPadding / 2,
  },
  textInput: {
    fontSize: 17,
  },
  modalOverlayText: {
    fontSize: 24,
    color: '#fff',
    fontWeight: '600',
  },
  unmetRequirementBannerText: {
    fontSize: 12,
    color: '#fff',
    fontWeight: '500',
  },
  unmetRequirementSubscriptText: {
    fontSize: 14,
    color: '#EE0612',
    fontWeight: 'normal',
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
