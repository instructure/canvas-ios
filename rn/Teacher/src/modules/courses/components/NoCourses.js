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

// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import { Text, SEMI_BOLD_FONT } from '../../../common/text'
import { Button } from '../../../common/buttons'
import colors from '../../../common/colors'

type Props = {
  onAddCoursePressed: () => void,
  style?: any,
}

export class NoCourses extends Component<Props> {
  render () {
    return (
      <View style={[styles.container, this.props.style]}>
        <Text style={styles.welcome} testID='Dashboard.emptyTitleLabel'>{i18n('Welcome!')}</Text>
        <Text style={styles.paragraph} testID='Dashboard.emptyBodyLabel'>
          {i18n('Add a few of your favorite courses to make this place your home.')}
        </Text>
        <Button
          testID='Dashboard.addCoursesButton'
          onPress={this.props.onAddCoursePressed}
          style={styles.button}
          containerStyle={styles.buttonContainer}
        >
          {i18n('Add Courses')}
        </Button>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 40,
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
  },
  welcome: {
    fontSize: 30,
    lineHeight: 36,
    color: colors.darkText,
    marginBottom: 8,
  },
  paragraph: {
    textAlign: 'center',
    color: colors.grey4,
    fontSize: 16,
    lineHeight: 19,
    paddingHorizontal: 10,
    marginBottom: 40,
  },
  button: {
    fontSize: 16,
    fontFamily: SEMI_BOLD_FONT,
  },
  buttonContainer: {
    borderRadius: 4,
    paddingHorizontal: 24,
    paddingVertical: 16,
  },
})

export default NoCourses
