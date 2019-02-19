//
// Copyright (C) 2017-present Instructure, Inc.
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

// @flow

import * as React from 'react'
import {
  View,
  TouchableOpacity,
} from 'react-native'
import BaseButton from 'react-native-button'
import { createStyleSheet } from './branding'
import { Text } from './text'

type ButtonProps = React.ElementConfig<typeof BaseButton>

export const Button = ({ containerStyle, style, ...props }: ButtonProps) => (
  <BaseButton
    containerStyle={[styles.container, containerStyle]}
    style={[styles.text, style]}
    {...props}
  />
)

type TextStyle = $PropertyType<React.ElementConfig<typeof Text>, 'style'>
type LinkButtonProps = {
  textStyle?: TextStyle,
} & React.ElementConfig<typeof TouchableOpacity>

export const LinkButton = ({ children, textStyle, ...props }: LinkButtonProps) => (
  <TouchableOpacity
    accessibilityTraits='button'
    hitSlop={{ top: 15, left: 15, bottom: 15, right: 15 }}
    {...props}
  >
    <View>
      <Text style={[linkButtonStyles.text, textStyle]}>
        {children}
      </Text>
    </View>
  </TouchableOpacity>
)

const styles = createStyleSheet(colors => ({
  container: {
    backgroundColor: colors.primaryButtonColor,
    overflow: 'hidden',
    padding: 10,
    borderRadius: 8,
  },
  text: {
    color: colors.primaryButtonTextColor,
  },
}))

const linkButtonStyles = createStyleSheet(colors => ({
  text: {
    fontSize: 16,
    fontWeight: '500',
    color: colors.primaryButtonColor,
  },
}))
