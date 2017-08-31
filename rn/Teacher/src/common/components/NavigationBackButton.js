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

import React from 'react'
import { View, Image, StyleSheet } from 'react-native'
import Button from 'react-native-button'
import Images from '../../images'
import i18n from 'format-message'

export default class NavigationBackButton extends React.Component {
  render () {
    return <Button style={styles.backButton} {...this.props}>
            <View style={{ paddingRight: 31 }} accessible={true} accessibilityTraits={'button'} accessibilityLabel={i18n('Back')}>
              <Image source={Images.backIcon} style={styles.navButtonImage} />
            </View>
           </Button>
  }
}

const styles = StyleSheet.create({
  backButton: {
    color: 'white',
    backgroundColor: 'transparent',
  },
})
