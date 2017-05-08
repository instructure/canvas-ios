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
  title: string | { value: string, ellipsizeMode?: string, numberOfLines?: number },
  subtitle?: string,
  image?: string,
  imageTint?: string,
  imageSize?: { height: number, width: number }, // Defaults to 20 x 20 if not supplied
  disclosureIndicator?: boolean,
  height?: number,
  border?: 'top' | 'bottom' | 'both',
  onPress?: Function,
  testID?: string,
  children: any,
  renderImage?: Function,
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
    const height = this.props.height
    const imageSize = this.props.imageSize || { height: 20, width: 20 }
    const title = this.props.title && typeof this.props.title === 'object' ? this.props.title : { value: this.props.title, ellipsizeMode: null, numberOfLines: 0 }
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
                { this.props.renderImage && this.props.renderImage() }
                { this.props.image && <Image style={[style.image, { tintColor: this.props.imageTint, height: imageSize.height, width: imageSize.width }]} source={this.props.image} /> }
                <View style={style.titlesContainer}>
                  { title &&
                    <Text
                      style={style.title}
                      ellipsizeMode={title.ellipsizeMode}
                      numberOfLines={title.numberOfLines}
                    >
                      {title.value}
                    </Text>
                  }
                  { this.props.subtitle && <Text style={style.subtitle}>{this.props.subtitle}</Text> }
                  { this.props.children }
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
    flexDirection: 'row',
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
  subtitle: {
    color: '#8B969E',
    fontSize: 14,
    marginTop: 2,
  },
  image: {
    resizeMode: 'contain',
    marginRight: 8,
  },
})
