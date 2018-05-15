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
  subtitle?: ?string,
  image?: { uri: string } | number,
  imageTint?: string,
  imageSize?: { height: number, width: number }, // Defaults to 20 x 20 if not supplied
  disclosureIndicator?: boolean,
  border?: 'top' | 'bottom' | 'both',
  onPress?: Function,
  testID?: string,
  children?: React$Node,
  renderImage?: Function,
  identifier?: any, // Passed in as the first parameter to the onPress callback
  accessories?: any,
  accessibilityLabel?: ?string,
  accessibilityTraits?: React$ElementProps<typeof View>,
  titleProps?: { ellipsizeMode?: string, numberOfLines?: number },
  selected?: ?boolean,
  titleStyles?: any,
  subtitleStyles?: any,
}

export default class Row extends Component<RowProps> {
  onPress = () => {
    if (this.props.onPress) {
      this.props.onPress(this.props.identifier)
    }
  }

  render () {
    const imageSize = this.props.imageSize || { height: 20, width: 20 }
    const title = this.props.title
    const testID = this.props.testID || 'row.undefined-cell'
    const hasIcon = this.props.image || this.props.renderImage

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

    let traits: {[string]: any} = {
      accessibilityTraits,
      accessibilityLabel: this.props.accessibilityLabel,
    }

    if (this.props.accessible !== undefined) {
      traits['accessible'] = this.props.accessible
    }

    let underlayProps = {}
    let backgroundColor = 'white'
    if (this.props.selected) {
      underlayProps.underlayColor = color.grey1
      backgroundColor = color.grey1
    }

    const titleStyles = [style.title, this.props.titleStyles].filter(Boolean)
    const subtitleStyles = [style.subtitle, this.props.subtitleStyles].filter(Boolean)

    return (<TouchableHighlight style={[topBorder, bottomBorder]} { ...traits } onPress={this.onPress} testID={this.props.testID} {...underlayProps} >
      <View style={[style.container, { backgroundColor }]}>
        { this.props.renderImage && this.props.renderImage() }
        { this.props.image && <Image style={[style.image, { tintColor: this.props.imageTint, height: imageSize.height, width: imageSize.width }]} source={this.props.image} /> }
        <View style={[style.titlesContainer, { marginLeft: hasIcon ? 12 : 0 }]}>
          { Boolean(title) &&
            <Text
              style={titleStyles}
              ellipsizeMode={(this.props.titleProps && this.props.titleProps.ellipsizeMode) || 'tail'}
              numberOfLines={(this.props.titleProps && this.props.titleProps.numberOfLines) || 0}
            >
              {title}
            </Text>
          }
          { Boolean(this.props.subtitle) && <Text style={subtitleStyles} testID={`${testID}-subtitle-lbl`}>{this.props.subtitle}</Text> }
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
    minHeight: 54,
    alignItems: 'center',
    paddingTop: Math.floor(global.style.defaultPadding / 1.25),
    paddingBottom: Math.floor(global.style.defaultPadding / 1.25),
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
  },
})
