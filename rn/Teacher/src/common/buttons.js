/**
 * @flow
 */

import React, { Component } from 'react'
import ReactNative, {
  StyleSheet,
  Text,
} from 'react-native'
import BaseButton from 'react-native-button'
import { branding } from './branding'

export function Button ({ style, containerStyle, ...props }: Object): ReactNative.TouchableHighlight {
  let brandingContainerStyles = {
    backgroundColor: branding.primaryButtonColor,
  }
  let brandingStyles = {
    color: branding.primaryButtonTextColor,
  }
  return (<BaseButton style={[styles.textColor, brandingStyles, style]} containerStyle={[styles.container, brandingContainerStyles, containerStyle]} {...props} />)
}

export class LinkButton extends Component {
  render (): React.Element<any> {
    let brandingStyles = {
      color: branding.primaryButtonColor,
    }
    return (
      <BaseButton {...this.props} ><Text style={[linkButtonStyles.textColor, brandingStyles]}>{this.props.children}</Text></BaseButton>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: branding.primaryButtonColor,
    overflow: 'hidden',
    padding: 20,
    borderRadius: 8,
  },
  textColor: {
    color: branding.primaryButtonTextColor,
  },
})

const linkButtonStyles = StyleSheet.create({
  textColor: {
    fontSize: 14,
    fontWeight: '500',
    color: branding.primaryButtonColor,
  },
})

