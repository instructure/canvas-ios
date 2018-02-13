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

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import { Button } from '../../../common/buttons'
import colors from '../../../common/colors'

type Props = {
  onAddCoursePressed: () => void,
  style?: any,
}

export class NoCourses extends Component<Props> {
  props: Props

  render () {
    let welcome = i18n('Welcome!')

    let bodyText = i18n('Add a few of your favorite courses to make this place your home.')

    let buttonText = i18n('Add Courses')

    return (
      <View style={[styles.container, this.props.style]}>
        <Text style={styles.welcome} testID='no-courses.welcome-lbl'>{welcome}</Text>
        <Text
          style={styles.paragraph} testID='no-courses.description-lbl'>{bodyText}</Text>
        <Button
          accessibilityLabel={buttonText}
          testID='no-courses.add-courses-btn'
          onPress={this.props.onAddCoursePressed}
          style={styles.button}
          containerStyle={styles.buttonContainer}
        >
          {buttonText}
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
    lineHeight: 19,
  },
  buttonContainer: {
    borderRadius: 4,
    paddingHorizontal: 24,
    paddingVertical: 16,
  },
})

export default (NoCourses: any)
