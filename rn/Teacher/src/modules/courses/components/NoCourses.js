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
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import { Button } from '../../../common/buttons'
import { createStyleSheet } from '../../../common/stylesheet'

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

const styles = createStyleSheet(colors => ({
  container: {
    paddingHorizontal: 40,
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
  },
  welcome: {
    fontSize: 30,
    lineHeight: 36,
    color: colors.textDarkest,
    marginBottom: 8,
  },
  paragraph: {
    textAlign: 'center',
    color: colors.textDark,
    fontSize: 16,
    lineHeight: 19,
    paddingHorizontal: 10,
    marginBottom: 40,
  },
  button: {
    fontSize: 16,
    fontWeight: '600',
  },
  buttonContainer: {
    borderRadius: 4,
    paddingHorizontal: 24,
    paddingVertical: 16,
  },
}))

export default NoCourses
