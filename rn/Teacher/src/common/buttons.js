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
      <BaseButton {...this.props}><Text style={[linkButtonStyles.textColor, linkButtonStyles.font, brandingStyles, this.props.style]}>{this.props.children}</Text></BaseButton>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: branding.primaryButtonColor,
    overflow: 'hidden',
    padding: 10,
    borderRadius: 8,
  },
  textColor: {
    color: branding.primaryButtonTextColor,
  },
})

const linkButtonStyles = StyleSheet.create({
  font: {
    fontFamily: '.SFUIDisplay-medium',
  },
  textColor: {
    fontSize: 14,
    color: branding.primaryButtonColor,
  },
})

