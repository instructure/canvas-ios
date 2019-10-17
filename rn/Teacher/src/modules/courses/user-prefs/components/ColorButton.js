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
  TouchableHighlight,
  View,
  StyleSheet,
  Image,
} from 'react-native'
import i18n from 'format-message'
import Images from '../../../../images'
import { colors } from '../../../../common/stylesheet'

type Props = {
  color: string,
  colorName?: ?string,
  hidden?: boolean,
  onPress: (color: string) => void,
  selected: boolean,
}

export default class ColorButton extends Component<Props> {
  onPress = () => {
    this.props.onPress(this.props.color)
  }

  render () {
    return (
      <TouchableHighlight
        accessible={this.props.hidden !== true}
        style={styles.button}
        accessibilityLabel={this.props.colorName
          ? i18n('Choose {colorName} ({hexCode})', {
            colorName: this.props.colorName,
            hexCode: this.props.color,
          })
          : i18n('Choose {color}', { color: this.props.color })
        }
        onPress={this.onPress}
        underlayColor={colors.backgroundLightest}
        testID={`colorButton.${this.props.color}`}
      >
        <View
          style={[styles.color, { backgroundColor: this.props.color }]}
        >
          {this.props.selected &&
            <Image source={Images.check} />
          }
        </View>
      </TouchableHighlight>
    )
  }
}

const styles = StyleSheet.create({
  button: {
    height: 48,
    margin: 8,
  },
  color: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
})
