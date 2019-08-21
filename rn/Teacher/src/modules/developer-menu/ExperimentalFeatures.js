//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

/* eslint-disable flowtype/require-valid-file-annotation */

import React, { Component } from 'react'
import {
  ScrollView,
} from 'react-native'

import Screen from '../../routing/Screen'
import Row from '../../common/components/rows/Row'
import ExperimentalFeature from '../../common/ExperimentalFeature'
import { Text } from '../../common/text'

function subtitle (name) {
  const state = ExperimentalFeature[name]
  if (state === true) {
    return 'enabled'
  } else if (state === 'beta') {
    return 'enabled in beta'
  } else if (Array.isArray(state)) {
    return `enabled for:\n${state.join('\n')}`
  }
  return 'disabled'
}

export default class ExperimentalFeatures extends Component {
  render () {
    return (
      <Screen
        title='Experimental Features'
      >
        <ScrollView style={{ flex: 1 }}>
          {Object.keys(ExperimentalFeature).map(name => {
            return (
              <Row
                title={name}
                key={name}
                subtitle={subtitle(name)}
                border='bottom'
                accessories={<Text>{ExperimentalFeature[name].isEnabled ? 'On' : 'Off'}</Text>}
              />
            )
          })}
        </ScrollView>
      </Screen>
    )
  }
}
