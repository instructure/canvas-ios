//
// Copyright (C) 2017-present Instructure, Inc.
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
import { Text, Paragraph } from '../../common/text'
import Images from '../../images'
import Screen from '../../routing/Screen'
import colors from '../../common/colors'

export class NotAParent extends PureComponent<{}> {
  logout = () => {
    NativeModules.NativeLogin.logout()
  }

  canvasGuides = () => {
    Linking.openURL('https://community.canvaslms.com/docs/DOC-9919')
  }

  openStudent = () => {
    Linking.openURL('https://itunes.apple.com/us/app/canvas-by-instructure/id480883488?ls=1&mt=8')
  }

  openTeacher = () => {
    Linking.openURL('https://itunes.apple.com/us/app/canvas-teacher/id1257834464?ls=1&mt=8')
  }

  render () {
    let title = i18n('No Enrollments')
    let subtitleOne = i18n('You need at least one active observer enrollment to use Canvas Parent.')
    let subtitleTwo = i18n("If you're a student or teacher, try one of our other apps below.")

    return (
      <Screen navBarHidden>
        <View style={style.container}>
          <View style={style.subContainer}>
            <Text style={style.title} testID='no-parent.title'>{title}</Text>
            <Paragraph style={style.paragraph} testID='no-parent.subtitleOne'>{subtitleOne}</Paragraph>
            <View style={style.separator} />
            <Paragraph style={style.paragraph} testID='no-parent.subtitleTwo'>{subtitleTwo}</Paragraph>
          </View>
          <View style={style.subContainer}>
            <TouchableOpacity onPress={this.openStudent}
              testID='no-parent.open-student'
              accessibilityTraits="button"
              accessibilityLabel={i18n('Canvas Student App')}>
              <Image source={Images.noTeacher.student} />
            </TouchableOpacity>
            <TouchableOpacity style={{ marginTop: 36 }}
              onPress={this.openTeacher} testID='no-parent.open-teacher'
              accessibilityTraits="button"
              accessibilityLabel={i18n('Canvas Teacher App')}>
              <Image source={Images.noTeacher.teacher} />
            </TouchableOpacity>
          </View>
          <View style={[style.subContainer, { marginTop: 50 }]}>
            <Button title={i18n('Log In Again')} testID='no-parent.logout' onPress={this.logout} />
          </View>
          <View style={style.subContainer}>
            <Button title={i18n('Canvas Guides')} testID='no-parent.canvas-guides' onPress={this.canvasGuides} />
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
    margin: 8,
  },
  title: {
    fontSize: 30,
    textAlign: 'center',
  },
  paragraph: {
    fontSize: 16,
    textAlign: 'center',
    padding: 8,
    maxWidth: 320,
  },
  separator: {
    backgroundColor: colors.seperatorColor,
    height: StyleSheet.hairlineWidth,
    marginTop: 20,
    marginBottom: 20,
  },
})

export default (NotAParent: any)
