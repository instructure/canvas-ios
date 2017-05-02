// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  ActivityIndicator,
} from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'
import { Heading1, Text } from '../../../common/text'
import RubricItem from './RubricItem'
import { route } from '../../../routing'
import { LinkButton } from '../../../common/buttons'
import SpeedGraderActions from '../actions'

export class RubricDetails extends Component {
  props: RubricProps
  state: RubricState

  constructor (props: RubricProps) {
    super(props)

    this.state = {
      ratings: props.rubricAssessment || {},
      hasChanges: false,
    }
  }

  showDescriptionModal = (rubricID: string) => {
    let { courseID, assignmentID } = this.props
    this.props.showModal(route(`/courses/${courseID}/assignments/${assignmentID}/rubrics/${rubricID}/description`))
  }

  updateScore = (id: string, value: number) => {
    this.setState({
      ratings: {
        ...this.state.ratings,
        [id]: {
          points: value,
        },
      },
      hasChanges: true,
    })
  }

  getCurrentScore = () => {
    return Object.keys(this.state.ratings)
      .reduce((sum, key) => sum + (this.state.ratings[key].points || 0), 0)
  }

  saveRubricAssessment = () => {
    this.setState({ hasChanges: false })
    this.props.gradeSubmissionWithRubric(this.props.courseID, this.props.assignmentID, this.props.userID, this.props.submissionID, this.state.ratings)
  }

  render () {
    let settings = this.props.rubricSettings
    let items = this.props.rubricItems
    if (settings && items) {
      return (
        <View style={styles.rubricContainer}>
          <View style={styles.rubricHeader}>
            <View>
              <Heading1>{i18n('Rubric')}</Heading1>
              <Text style={styles.pointsText}>
                {
                  i18n('{points, number} out of {totalPoints, number}', {
                    points: this.getCurrentScore(),
                    totalPoints: settings.points_possible,
                  })
                }
              </Text>
            </View>
            { this.props.rubricGradePending &&
              <ActivityIndicator />
            }
            { this.state.hasChanges &&
              <LinkButton testID='rubric-details.save' style={styles.saveStyles} onPress={this.saveRubricAssessment}>
                {i18n('Save')}
              </LinkButton>
            }
          </View>
          {items.map((rubricItem: Rubric) => (
            <RubricItem
              key={rubricItem.id}
              rubricItem={rubricItem}
              showDescription={this.showDescriptionModal}
              changeRating={this.updateScore}
              grade={this.state.ratings[rubricItem.id]}
            />
          ))}
        </View>
      )
    }
    return null
  }
}

const styles = StyleSheet.create({
  rubricContainer: {
    paddingVertical: 16,
  },
  rubricHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  saveStyles: {
    fontSize: 18,
    fontWeight: '600',
  },
  pointsText: {
    color: '#8B969E',
    fontSize: 14,
  },
})

export function mapStateToProps (state: AppState, ownProps: RubricOwnProps): RubricDataProps {
  let assignment = state.entities.assignments[ownProps.assignmentID].data
  let submission = state.entities.submissions[ownProps.submissionID]
  let assessments = null
  let rubricGradePending = false

  if (submission) {
    assessments = submission.submission.rubric_assessment
    rubricGradePending = submission.rubricGradePending
  }

  return {
    rubricItems: assignment.rubric,
    rubricSettings: assignment.rubric_settings,
    rubricAssessment: assessments,
    rubricGradePending,
  }
}

const Connected = connect(mapStateToProps, SpeedGraderActions)(RubricDetails)
export default (Connected: any)

type RubricOwnProps = {
  courseID: string,
  assignmentID: string,
  submissionID: string,
  userID: string,
  showModal: Function,
}

type RubricDataProps = {
  rubricItems: ?Array<Rubric>,
  rubricSettings: ?RubricSettings,
  rubricAssessment: ?{ [string]: RubricAssessment },
  rubricGradePending: boolean,
}

type RubricActionProps = {
  gradeSubmissionWithRubric: Function,
}

type RubricProps = RubricOwnProps & RubricDataProps & RubricActionProps
type RubricState = {
  ratings: { [string]: RubricAssessment },
  hasChanges: boolean,
}
