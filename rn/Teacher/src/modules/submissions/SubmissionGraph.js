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

/**
 * @flow
 */

import i18n from 'format-message'
import React, { Component } from 'react'
import { colors, createStyleSheet } from '../../common/stylesheet'
import * as Progress from 'react-native-progress'
import { Text } from '../../common/text'
import {
  Text as RNText,
  View,
  ActivityIndicator,
} from 'react-native'
import RNCounter from 'react-native-counter'

// localized counting
class Counter extends RNCounter {
  render () {
    const { style } = this.props
    const { value } = this.state
    return (
      <RNText style={style}>{i18n.number(value, 'integer')}</RNText>
    )
  }
}

export type SubmissionGraphProps = {
  total: number,
  current: number,
  label: string,
  testID?: string,
  pending: boolean,
}

export default class SubmissionGraph extends Component<SubmissionGraphProps, any> {
  countInterval: number

  constructor (props: SubmissionGraphProps) {
    super(props)

    this.state = {
      progress: 0,
      current: 0,
    }
  }

  UNSAFE_componentWillReceiveProps (nextProps: SubmissionGraphProps) {
    if (!nextProps.pending) {
      this.setState({
        current: nextProps.current,
        progress: nextProps.total && nextProps.total > 0 ? nextProps.current / nextProps.total : 0,
      })
    }
  }

  render () {
    const testID = this.props.testID || 'submissions.submissionGraph.undefined'

    return (
      <View style={submissionsGraphStyle.container}>
        <View style={submissionsGraphStyle.circleContainer}>
          <Progress.Circle size={submissionCircles.size}
            animated={true}
            thickness={submissionCircles.thickness}
            progress={this.state.progress}
            borderWidth={0}
            unfilledColor={colors.backgroundLight}
            color={colors.primary}
            borderColor={colors.primary}
            showsText={false}
            testID={`submissions.submission-graph.${testID}-progress-view`} />
        </View>
        <Text
          style={submissionsGraphStyle.label}
          testID={`submissions.submission-graph.${testID}-title-lbl`}
        >
          {this.props.label}
        </Text>
        { !this.props.pending &&
          <View style={submissionsGraphStyle.center}>
            <Counter
              start={0}
              end={this.state.current}
              time={500}
              easing='circInOut'
              style={submissionsGraphStyle.innerText}
            />
          </View>
        }
        { this.props.pending &&
          <View style={submissionsGraphStyle.center}>
            <ActivityIndicator />
          </View>
        }
      </View>
    )
  }
}

const submissionCircles = {
  size: 70,
  thickness: 7,
  borderWidth: 1,
}

const submissionsGraphStyle = createStyleSheet(colors => ({
  container: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'center',
  },
  label: {
    flex: 1,
    textAlign: 'center',
    fontSize: 12,
    marginTop: 8,
    fontWeight: '500',
  },
  circleContainer: {
    flex: 1,
  },
  innerText: {
    color: colors.textDarkest,
    fontWeight: '500',
    fontSize: 16,
  },
  center: {
    flex: 1,
    position: 'absolute',
    top: 25.5,
  },
}))
