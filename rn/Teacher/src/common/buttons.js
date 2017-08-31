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

import React, { Component } from 'react'
import ReactNative, {
  View,
  StyleSheet,
  TouchableOpacity,
} from 'react-native'
import BaseButton from 'react-native-button'
import colors from './colors'
import { Text, BOLD_FONT } from './text'

export function Button ({ style, containerStyle, ...props }: Object): ReactNative.TouchableHighlight {
  let brandingContainerStyles = {
    backgroundColor: colors.primaryButtonColor,
  }
  let brandingStyles = {
    color: colors.primaryButtonTextColor,
  }
  return (<BaseButton style={[styles.textColor, brandingStyles, style]} containerStyle={[styles.container, brandingContainerStyles, containerStyle]} {...props} />)
}

export class LinkButton extends Component {
  render () {
    const brandingStyles = { color: colors.primaryButtonColor }
    const textAttributes = this.props.textAttributes || {}
    const textStyles = [linkButtonStyles.textColor, linkButtonStyles.font, brandingStyles, textAttributes, this.props.textStyle].filter(Boolean)
    const propsWithoutTextStyle = {
      ...this.props,
    }
    delete propsWithoutTextStyle.textStyle
    return (
      <TouchableOpacity
        {...propsWithoutTextStyle}
        accessibilityTraits='button'
      >
        <View>
          <Text style={textStyles}>
            {this.props.children}
          </Text>
        </View>
      </TouchableOpacity>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.primaryButtonColor,
    overflow: 'hidden',
    padding: 10,
    borderRadius: 8,
  },
  textColor: {
    color: colors.primaryButtonTextColor,
  },
})

const linkButtonStyles = StyleSheet.create({
  font: {
    fontFamily: BOLD_FONT,
  },
  textColor: {
    fontSize: 14,
    color: colors.primaryButtonColor,
  },
})
