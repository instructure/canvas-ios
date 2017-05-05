// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  Image,
  TouchableHighlight,
} from 'react-native'
import color from '../../colors'

import DisclosureIndicator from '../DisclosureIndicator'
import { Text } from '../../text'

export type RowProps = {
  title: string,
  subtitle?: string,
  image?: string,
  imageTint?: string,
  imageSize?: { height: number, width: number }, // Defaults to 20 x 20 if not supplied
  disclosureIndicator?: boolean,
  height?: number, // If not supplied defaults to 54
  border?: 'top' | 'bottom' | 'both',
  onPress?: Function,
  testID?: string,
  identifier: string, // Passed in as the first parameter to the onPress callback
  accessories: any,
}

export default class Row extends Component<any, RowProps, any> {

  onPress = () => {
    if (this.props.onPress) {
      this.props.onPress(this.props.identifier)
    }
  }

  render () {
    const height = this.props.height || 54
    const imageSize = this.props.imageSize || { height: 20, width: 20 }
    let topBorder
    let bottomBorder

    if (this.props.border === 'top' || this.props.border === 'both') {
      topBorder = style.topHairline
    }

    if (this.props.border === 'bottom' || this.props.border === 'both') {
      bottomBorder = style.bottomHairline
    }

    let traits = {}
    if (this.props.onPress) {
      traits.accessibilityTraits = 'button'
    }

    return (<TouchableHighlight style={[{ height }, topBorder, bottomBorder]} { ...traits } onPress={this.onPress} testID={this.props.testID}>
              <View style={style.container}>
                { this.props.image && <Image style={[style.image, { tintColor: this.props.imageTint, height: imageSize.height, width: imageSize.width }]} source={this.props.image} /> }
                <View style={style.titlesContainer}>
                  { this.props.title && <Text style={style.title}>{this.props.title}</Text> }
                  { this.props.subtitle && <Text>{this.props.subtitle}</Text> }
                </View>
                <View style={style.accessoryContainer}>
                  { this.props.accessories }
                  { this.props.disclosureIndicator && <DisclosureIndicator /> }
                </View>
              </View>
            </TouchableHighlight>)
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    paddingTop: global.style.defaultPadding / 2,
    paddingBottom: global.style.defaultPadding / 2,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
    backgroundColor: 'white',
  },
  titlesContainer: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
  },
  accessoryContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  topHairline: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: color.seperatorColor,
  },
  bottomHairline: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: color.seperatorColor,
  },
  title: {
    fontWeight: '600',
  },
  image: {
    resizeMode: 'contain',
    marginRight: 8,
  },
})
