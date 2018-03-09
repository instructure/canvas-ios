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
        title='Push Notifications'
      >
        <ScrollView style={{ flex: 1, padding: 16 }}>
          <Heading1>Always on for:</Heading1>
          {exemptDomains.map(domain => <Text>{domain}</Text>)}
          {Object.keys(featureFlags).map(flagName => {
            return (
              <Row
                title={flagName}
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
