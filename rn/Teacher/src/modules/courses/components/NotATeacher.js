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

/**
 * @flow
 */

import React, { PureComponent } from 'react'
import {
  View,
  StyleSheet,
  Button,
  Image,
  TouchableOpacity,
  NativeModules,
  Linking,
} from 'react-native'
import i18n from 'format-message'
import { Text, Paragraph } from '../../../common/text'
import Images from '../../../images'
import Screen from '../../../routing/Screen'

export class NotATeacher extends PureComponent<{}> {
  logout = () => {
    NativeModules.NativeLogin.logout()
  }

  openStudent = () => {
    Linking.openURL('https://itunes.apple.com/us/app/canvas-by-instructure/id480883488?ls=1&mt=8')
  }

  openParent = () => {
    Linking.openURL('https://itunes.apple.com/us/app/canvas-parent/id1097996698?ls=1&mt=8')
  }

  render () {
    let title = i18n('Not a teacher?')
    let subtitle = i18n('One of our other apps might be a better fit. Tap one to visit the App Store.')
    let buttonText = i18n('Try logging in again')

    return (
      <Screen navBarHidden>
        <View style={style.container}>
          <View style={style.subContainer}>
            <Text style={{ fontSize: 30 }} testID='no-teacher.title'>{title}</Text>
            <Paragraph style={style.paragraph} testID='no-teacher.title'>{subtitle}</Paragraph>
          </View>
          <View style={style.subContainer}>
            <TouchableOpacity onPress={this.openStudent}
              testID='no-teacher.open-student'
              accessibilityTraits="button"
              accessibilityLabel={i18n('Canvas Student App')}>
              <Image source={Images.noTeacher.student} />
            </TouchableOpacity>
            <TouchableOpacity style={{ marginTop: 36 }}
              onPress={this.openParent} testID='no-teacher.open-parent'
              accessibilityTraits="button"
              accessibilityLabel={i18n('Canvas Parent App')}>
              <Image source={Images.noTeacher.parent} />
            </TouchableOpacity>
          </View>
          <View style={style.subContainer}>
            <Button title={buttonText} testID='no-teacher.logout' onPress={this.logout} />
          </View>
        </View>
      </Screen>
    )
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    padding: 10,
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
  },
  subContainer: {
    alignItems: 'center',
    margin: 8,
  },
  paragraph: {
    fontSize: 16,
    textAlign: 'center',
    padding: 8,
    maxWidth: 320,
  },
})

export default (NotATeacher: any)
