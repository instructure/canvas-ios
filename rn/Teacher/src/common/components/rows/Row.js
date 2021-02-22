//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import React, { Component } from 'react'
import {
  View,
  Image,
  TouchableHighlight,
} from 'react-native'
import { colors, createStyleSheet } from '../../stylesheet'

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
  accessibilityRole?: string,
  accessibilityState?: any,
  titleProps?: { ellipsizeMode?: string, numberOfLines?: number, accessibilityLabel?: string },
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

    let accessibilityRole = this.props.accessibilityRole

    if (accessibilityRole === undefined && this.props.onPress) {
      accessibilityRole = 'button'
    }

    let traits: {[string]: any} = {
      accessibilityRole,
      accessibilityLabel: this.props.accessibilityLabel,
      accessibilityState: this.props.accessibilityState,
    }

    if (this.props.accessible !== undefined) {
      traits['accessible'] = this.props.accessible
    }

    let underlayProps = {}
    let backgroundColor = colors.backgroundLightest
    if (this.props.selected) {
      underlayProps.underlayColor = colors.backgroundLight
      backgroundColor = colors.backgroundLight
    }

    // This broke highlighting basically everywhere, so it needs to be disabled.
    // if (this.props.selected !== undefined) {
    //   // This row uses selected state so dont ever show active state
    //   underlayProps.activeOpacity = 1
    // }

    const titleStyles = [style.title, this.props.titleStyles].filter(Boolean)
    const subtitleStyles = [style.subtitle, this.props.subtitleStyles].filter(Boolean)
    const RowView = this.props.onPress ? TouchableHighlight : View
    let titleA11y = this.props.titleProps?.accessibilityLabel

    return (<RowView style={[topBorder, bottomBorder]} { ...traits } onPress={this.onPress} testID={this.props.testID} {...underlayProps}>
      <View style={[style.container, { backgroundColor }, this.props.style]}>
        { this.props.renderImage && this.props.renderImage() }
        { this.props.image && <Image style={[style.image, { tintColor: this.props.imageTint, height: imageSize.height, width: imageSize.width }]} source={this.props.image} /> }
        <View style={[style.titlesContainer, { marginLeft: hasIcon ? 12 : 0 }]}>
          { Boolean(title) &&
            <Text
              style={titleStyles}
              ellipsizeMode={this.props.titleProps?.ellipsizeMode || 'tail'}
              numberOfLines={this.props.titleProps?.numberOfLines || 0}
              {... (titleA11y ? { accessibilityLabel: titleA11y } : {})}
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
    </RowView>)
  }
}

const style = createStyleSheet((colors, vars) => ({
  container: {
    flex: 1,
    flexDirection: 'row',
    minHeight: 54,
    alignItems: 'center',
    paddingTop: Math.floor(vars.padding / 1.25),
    paddingBottom: Math.floor(vars.padding / 1.25),
    paddingLeft: vars.padding,
    paddingRight: vars.padding,
    backgroundColor: colors.backgroundLightest,
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
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
  },
  bottomHairline: {
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
  },
  title: {
    color: colors.textDarkest,
    fontWeight: '600',
  },
  subtitle: {
    color: colors.textDark,
    fontSize: 14,
    marginTop: 2,
  },
  image: {
    resizeMode: 'contain',
  },
}))
