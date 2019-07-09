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

// @flow

import React, { Component } from 'react'
import {
  ScrollView,
} from 'react-native'

import Screen from '../../routing/Screen'
import Row from '../../common/components/rows/Row'
import { featureFlags, featureFlagEnabled, type FeatureFlagName } from '../../common/feature-flags'
import { Text } from '../../common/text'

function subtitle (flagName: FeatureFlagName) {
  const flag = featureFlags[flagName]
  const domains = (flag.exempt && flag.exempt.domains) || []
  const apps = (flag.exempt && flag.exempt.apps) || []
  return `On for: \n${domains.concat(apps).join('\n')}`
}

export default class FeatureFlags extends Component<any, any> {
  render () {
    return (
      <Screen
        title='Feature Flags'
      >
        <ScrollView style={{ flex: 1, padding: 16 }}>
          {Object.keys(featureFlags).map(flagName => {
            return (
              <Row
                title={flagName}
                key={flagName}
                subtitle={subtitle(flagName)}
                border='bottom'
                accessories={<Text>{featureFlagEnabled(flagName) ? 'On' : 'Off'}</Text>}
              />
            )
          })}
        </ScrollView>
      </Screen>
    )
  }
}
