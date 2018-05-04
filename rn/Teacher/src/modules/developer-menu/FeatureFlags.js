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

import React, { Component } from 'react'
import {
  ScrollView,
} from 'react-native'

import Screen from '../../routing/Screen'
import Row from '../../common/components/rows/Row'
import { featureFlags, exemptDomains, featureFlagEnabled } from '../../common/feature-flags'
import { Heading1, Text } from '../../common/text'

export default class FeatureFlags extends Component<any, any> {
  render () {
    return (
      <Screen
        title='Feature Flags'
      >
        <ScrollView style={{ flex: 1, padding: 16 }}>
          <Heading1>Always on for:</Heading1>
          {exemptDomains.map(domain => <Text>{domain}</Text>)}
          {Object.keys(featureFlags).map(flagName => {
            return (
              <Row
                title={flagName}
                key={flagName}
                subtitle={`On for: \n${featureFlags[flagName].exempt.join('\n')}`}
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
