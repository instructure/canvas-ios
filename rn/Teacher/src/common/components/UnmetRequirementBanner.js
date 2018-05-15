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

import React, { PureComponent } from 'react'
import {
  View,
  StyleSheet,
  LayoutAnimation,
} from 'react-native'
import { UnmetRequirementBannerText } from '../text'

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
    backgroundColor: '#EE0612',
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

const styles = StyleSheet.create({
  visible: {
    flex: 0.04,
    alignItems: 'stretch',
    flexDirection: 'column',
    backgroundColor: '#EE0612',
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
})
