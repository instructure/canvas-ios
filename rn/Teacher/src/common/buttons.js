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
    let brandingStyles = { color: colors.primaryButtonColor }
    let textAttributes = this.props.textAttributes || {}
    return (
      <TouchableOpacity
        {...this.props}
      >
        <View>
          <Text style={[linkButtonStyles.textColor, linkButtonStyles.font, brandingStyles, textAttributes, this.props.style]}>
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
