/**
 * @flow
 */

import React, { Component } from 'react'
import ReactNative, {
  StyleSheet,
  View,
} from 'react-native'
import BaseButton from 'react-native-button'
import colors from './colors'
import branding from './branding'
import { Text, Heading1, BOLD_FONT } from './text'

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
  render (): React.Element<any> {
    let brandingStyles = {
      color: colors.primaryButtonColor,
    }
    return (
      <BaseButton {...this.props}><Text style={[linkButtonStyles.textColor, linkButtonStyles.font, brandingStyles, this.props.style]}>{this.props.children}</Text></BaseButton>
    )
  }
}

export class CircleToggle extends Component {
  props: {
    on: boolean,
    children?: any,
    style?: any,
    value: any,
    onPress: Function,
  }

  onPress = () => {
    this.props.onPress(this.props.value)
  }

  render () {
    let viewStyle = [circleButtonStyles.container, this.props.style]
    let textStyle = {
      fontWeight: '500',
      color: 'black',
    }
    if (this.props.on) {
      viewStyle.push({
        backgroundColor: branding.primaryBrandColor,
      })
      textStyle.color = 'white'
    }

    return (
      <BaseButton {...this.props} onPress={this.onPress} testID='circle-button'>
        <View style={viewStyle}>
          {typeof this.props.children === 'object'
            ? this.props.children
            : <Heading1 style={textStyle}>{this.props.children}</Heading1>
          }
        </View>
      </BaseButton>
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

const circleButtonStyles = StyleSheet.create({
  container: {
    borderColor: '#C7CDD1',
    borderWidth: StyleSheet.hairlineWidth,
    minWidth: 48,
    height: 48,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 24,
    flex: 1,
    paddingHorizontal: 8,
  },
})
