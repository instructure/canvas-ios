/**
 * @flow
 */

import React, { Component } from 'react'
import color from '../../common/colors'
import * as Progress from 'react-native-progress'
import { Text, MEDIUM_FONT } from '../../common/text'
import {
  View,
  StyleSheet,
  ActivityIndicator,
} from 'react-native'
import Counter from 'react-native-counter'

export type SubmissionGraphProps = {
  total: number,
  current: number,
  label: string,
  testID?: string,
  pending: boolean,
}

export default class SubmissionGraph extends Component<any, SubmissionGraphProps, any> {
  countInterval: number

  constructor (props: SubmissionGraphProps) {
    super(props)

    this.state = {
      progress: 0,
      current: 0,
    }
  }

  componentWillReceiveProps (nextProps: SubmissionGraphProps) {
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
                           unfilledColor={submissionCircles.backgroundColor}
                           color={color.primaryBrandColor}
                           borderColor={color.primaryBrandColor}
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

const submissionCircles: { [key: string]: any } = {
  size: 70,
  thickness: 7,
  backgroundColor: '#F5F5F5',
  borderWidth: 1,
}

const submissionsGraphStyle = StyleSheet.create({
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
    color: color.darkText,
    fontFamily: MEDIUM_FONT,
    fontSize: 16,
  },
  center: {
    flex: 1,
    position: 'absolute',
    top: 25.5,
  },
})
