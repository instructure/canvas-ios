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
import { View, Image } from 'react-native'
import { Text } from '../../common/text'
import { createStyleSheet } from '../../common/stylesheet'
import images from '../../images'
import i18n from 'format-message'

export default class EmptyAttachments extends PureComponent<{}> {
  render () {
    return (
      <View style={styles.container}>
        <Image style={styles.image} source={images.attachment80} />
        <Text style={styles.title}>{i18n('No Attachments')}</Text>
        <Text style={styles.text}>
          {i18n('Add an attachment by tapping the plus at the top right.')}
        </Text>
      </View>
    )
  }
}

const styles = createStyleSheet(colors => ({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 50,
    height: 400,
  },
  image: {
    marginBottom: 36,
  },
  title: {
    fontSize: 24,
    fontWeight: '600',
    textAlign: 'center',
    marginBottom: 4,
  },
  text: {
    color: colors.textDark,
    fontSize: 16,
    textAlign: 'center',
  },
}))
