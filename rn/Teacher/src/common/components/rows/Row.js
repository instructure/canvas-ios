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
  height?: number | string, // number or 'auto' which will not set the height. Default is 54
  border?: 'top' | 'bottom' | 'both',
  onPress?: Function,
  testID?: string,
  children: any,
  renderImage?: Function,
  identifier: any, // Passed in as the first parameter to the onPress callback
  accessories: any,
  accessibilityLabel: ?string,
  accessibilityTraits: ?string | ?string[],
  titleProps?: { ellipsizeMode?: string, numberOfLines?: number },
  selected: boolean,
  titleStyles?: Text.propTypes,
}

export default class Row extends Component<any, RowProps, any> {

  onPress = () => {
    if (this.props.onPress) {
      this.props.onPress(this.props.identifier)
    }
  }

  render () {
    let height = this.props.height
    if (typeof height === 'string' && height === 'auto') {
      height = undefined
    } else {
      height = height || 54
    }
    const imageSize = this.props.imageSize || { height: 20, width: 20 }
    const title = this.props.title
    const testID = this.props.testID || 'row.undefined-cell'

    let topBorder
    let bottomBorder

    if (this.props.border === 'top' || this.props.border === 'both') {
      topBorder = style.topHairline
    }

    if (this.props.border === 'bottom' || this.props.border === 'both') {
      bottomBorder = style.bottomHairline
    }

    let accessibilityTraits = typeof this.props.accessibilityTraits === 'string' ? [this.props.accessibilityTraits] : (this.props.accessibilityTraits || [])
    if (this.props.onPress && !accessibilityTraits.includes('button')) {
      accessibilityTraits.push('button')
    }

    let traits = {
      accessibilityTraits,
      accessibilityLabel: this.props.accessibilityLabel,
    }

    let underlayProps = {}
    let backgroundColor = 'white'
    if (this.props.selected) {
      underlayProps.underlayColor = color.grey1
      backgroundColor = color.grey1
    }

    return (<TouchableHighlight style={[{ height }, topBorder, bottomBorder]} { ...traits } onPress={this.onPress} testID={this.props.testID} {...underlayProps} >
              <View style={[style.container, { backgroundColor }]}>
                { this.props.renderImage && this.props.renderImage() }
                { this.props.image && <Image style={[style.image, { tintColor: this.props.imageTint, height: imageSize.height, width: imageSize.width }]} source={this.props.image} /> }
                <View style={style.titlesContainer}>
                  { Boolean(title) &&
                    <Text
                      style={[style.title, this.props.titleStyles]}
                      ellipsizeMode={(this.props.titleProps && this.props.titleProps.ellipsizeMode) || 'tail'}
                      numberOfLines={(this.props.titleProps && this.props.titleProps.numberOfLines) || 0}
                    >
                      {title}
                    </Text>
                  }
                  { Boolean(this.props.subtitle) && <Text style={style.subtitle} testID={`${testID}-subtitle-lbl`}>{this.props.subtitle}</Text> }
                  { this.props.children }
                </View>
                { Boolean(this.props.accessories || this.props.disclosureIndicator) &&
                  <View style={style.accessoryContainer}>
                    <View style={style.accessories}>
                      { this.props.accessories }
                      { this.props.disclosureIndicator && <DisclosureIndicator /> }
                    </View>
                  </View>
                }
              </View>
            </TouchableHighlight>)
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    paddingTop: global.style.defaultPadding / 1.25,
    paddingBottom: global.style.defaultPadding / 1.25,
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
    flex: 0,
  },
  accessories: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
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
