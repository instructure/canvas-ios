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

import React, { PureComponent } from 'react'
import {
  View,
  LayoutAnimation,
} from 'react-native'
import { UnmetRequirementBannerText } from '../text'
import { colors, createStyleSheet } from '../stylesheet'

type Props = {
  visible: boolean,
  text: string,
  backgroundColor: string,
  testID?: string,
}

export default class UnmetRequirementBanner extends PureComponent<Props, any> {
  static defaultProps = {
    visible: false,
    text: 'Unmet Requirements',
    backgroundColor: colors.backgroundDanger,
  }

  componentWillUpdate () {
    LayoutAnimation.easeInEaseOut()
  }

  render () {
    let bannerStyle = this.props.visible ? styles.visible : styles.hidden

    return (
      <View style={bannerStyle}>
        <View style={styles.textContainer}>
          <UnmetRequirementBannerText style={styles.textContent} testID={this.props.testID}>{this.props.text}</UnmetRequirementBannerText>
        </View>
      </View>
    )
  }
}

const styles = createStyleSheet(colors => ({
  visible: {
    flex: 0.04,
    alignItems: 'stretch',
    flexDirection: 'column',
    backgroundColor: colors.backgroundDanger,
  },
  hidden: {
    flex: 0,
  },
  textContainer: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  textContent: {
    alignItems: 'center',
    textAlign: 'center',
  },
}))
