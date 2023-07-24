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

/* @flow */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  Appearance,
  View,
  TouchableHighlight,
} from 'react-native'
import i18n from 'format-message'

import Actions from './actions'
import AssignmentSection from '../../assignment-details/components/AssignmentSection'
import AssignmentDates from '../../assignment-details/components/AssignmentDates'
import PublishedIcon from '../../assignment-details/components/PublishedIcon'
import { RefreshableScrollView } from '../../../common/components/RefreshableList'
import CoreWebView from '../../../common/components/CoreWebView'
import DescriptionDefaultView from '../../../common/components/DescriptionDefaultView'
import {
  Heading1,
  Text,
} from '../../../common/text'
import { createStyleSheet } from '../../../common/stylesheet'
import Images from '../../../images'
import refresh from '../../../utils/refresh'
import formatter from '../formatter'
import Screen from '../../../routing/Screen'
import Navigator from '../../../routing/Navigator'
import QuizSubmissionBreakdownGraphSection from '../submissions/components/QuizSubmissionBreakdownGraphSection'
import type { EventSubscription } from 'react-native/Libraries/vendor/emitter/EventEmitter'
import type { AppearancePreferences } from 'react-native/Libraries/Utilities/NativeAppearance'

type OwnProps = {
  quizID: string,
  courseID: string,
}

type State = {
  quiz: ?Quiz,
  assignmentGroup: ?AssignmentGroup,
  assignment: ?Assignment,
  courseName: string,
  showSubmissionSummary: boolean,
  courseColor: ?string,
}

export type Props = State & OwnProps & RefreshProps & typeof Actions & {
  navigator: Navigator,
}

export class QuizDetails extends Component<Props, any> {
  _appearanceChangeSubscription: ?EventSubscription

  componentDidMount () {
    this._appearanceChangeSubscription = Appearance.addChangeListener(
      (preferences: AppearancePreferences) => {
        this.props.refresh()
      },
    )
  }

  componentWillUnmount () {
    this._appearanceChangeSubscription?.remove()
  }

  previewQuiz = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/quizzes/${this.props.quizID}/preview`, { modal: true, modalPresentationStyle: 'fullscreen' })
  }

  viewAllSubmissions = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/quizzes/${this.props.quizID}/submissions`)
  }

  onSubmissionDialPress = (type: string) => {
    this.viewSubmissions(type)
  }

  viewSubmissions = (filterType: ?string) => {
    const { courseID, quizID } = this.props
    if (filterType) {
      this.props.navigator.show(`/courses/${courseID}/quizzes/${quizID}/submissions`, { modal: false }, { filterType })
    } else {
      this.props.navigator.show(`/courses/${courseID}/quizzes/${quizID}/submissions`)
    }
  }

  render () {
    const quiz = this.props.quiz
    let content
    if (quiz) {
      content = (
        <RefreshableScrollView
          refreshing={this.props.refreshing}
          onRefresh={this.props.refresh}>
          <AssignmentSection isFirstRow={true} style={style.topContainer}>
            <Heading1>{quiz.title}</Heading1>
            <View style={style.pointsContainer}>
              { Boolean(quiz.points_possible) &&
                // TODO: fix i18n here
                <Text style={style.points}>{`${quiz.points_possible || 0} ${i18n('pts')}`}</Text>
              }
              <PublishedIcon published={quiz.published} />
            </View>
          </AssignmentSection>

          <AssignmentSection
            title={i18n('Due')}
            accessibilityLabel={i18n('Due Dates, Double tap for details.')}
            image={Images.assignments.calendar}
            showDisclosureIndicator={Boolean(this.props.assignment)}
            onPress={this.props.assignment && this._viewDueDates}
            testID='quizzes.details.viewDueDatesButton'
          >
            <AssignmentDates
              // $FlowFixMe
              assignment={this.props.assignment || quiz}
            />
          </AssignmentSection>

          {this.props.showSubmissionSummary &&
            <AssignmentSection
              title={i18n('Submissions')}
              onPress={this.viewAllSubmissions}
              testID='quizzes.details.viewAllSubmissionsRow'
              showDisclosureIndicator>
              <QuizSubmissionBreakdownGraphSection
                onPress={this.onSubmissionDialPress}
                courseID={this.props.courseID}
                quizID={this.props.quizID}
                assignmentID={quiz.assignment_id} />
            </AssignmentSection>
          }

          <View style={style.section}>
            <Text style={style.header}>{i18n('Description')}</Text>
            {this.checkAssignmentDescription(quiz.description)}
          </View>

          {this._renderDetails()}
          <TouchableHighlight
            onPress={this.previewQuiz}
            style={style.previewQuizButton}
            accessible={true}
            accessibilityLabel={i18n('Preview Quiz')}
            accessibilityTraits='button'
            testID='quizzes.details.previewQuiz.btn'
          >
            <View style={style.previewQuizButtonContainer}>
              <Text style={style.previewQuizButtonTitle}>{i18n('Preview Quiz')}</Text>
            </View>
          </TouchableHighlight>
        </RefreshableScrollView>
      )
    } else {
      content = <View />
    }

    return (
      <Screen
        navBarColor={this.props.courseColor}
        navBarStyle='context'
        title={i18n('Quiz Details')}
        subtitle={this.props.courseName}
        rightBarButtons={[
          {
            title: i18n('Edit'),
            testID: 'quizzes.details.editButton',
            action: this._editQuiz,
          },
        ]}
      >
        {content}
      </Screen>
    )
  }

  _renderDetails () {
    const quiz = this.props.quiz
    if (!quiz) {
      return null
    }
    const readable = formatter(quiz)
    const details = [
      [i18n('Quiz Type'), readable.quizType],
      [i18n('Assignment Group'), this.props.assignmentGroup && this.props.assignmentGroup.name],
      [i18n('Shuffle Answers'), readable.shuffleAnswers],
      [i18n('Time Limit'), readable.timeLimit],
      [i18n('Allowed Attempts'), readable.allowedAttempts],
      [i18n('View Responses'), readable.viewResponses],
      [i18n('Show Correct Answers'), readable.showCorrectAnswers],
      [i18n('One Question at a Time'), readable.oneQuestionAtATime],
      [i18n('Lock Questions After Answering'), quiz.one_question_at_a_time && readable.cantGoBack],
      [i18n('Score to Keep'), readable.scoringPolicy],
      [i18n('Access Code'), quiz.access_code],
    ]
    return (
      <View style={style.detailsSection}>
        {
          details.filter(d => d[1]).map((detail, index) => {
            // $FlowFixMe
            const accessibilityLabel = `${detail[0]}, ${detail[1]}`
            return (
              <View
                key={`detail_section_${index}`}
                style={style.details}
                accessible={true}
                accessibilityLabel={accessibilityLabel}
              >
                <Text style={{ fontWeight: '600' }}>{`${detail[0]}:  `}</Text>
                <Text>{detail[1]}</Text>
              </View>
            )
          })
        }
      </View>
    )
  }

  _editQuiz = () => {
    if (this.props.quiz) {
      this.props.navigator.show(`/courses/${this.props.courseID}/quizzes/${this.props.quiz.id}/edit`, { modal: true, modalPresentationStyle: 'pagesheet' })
    }
  }

  _viewDueDates = () => {
    if (this.props.assignment && this.props.quiz) {
      const route = `/courses/${this.props.courseID}/assignments/${this.props.assignment.id}/due_dates`
      this.props.navigator.show(route, { modal: false }, { quizID: this.props.quiz.id })
    }
  }

  checkAssignmentDescription (description: ?string) {
    if (description) {
      return (<CoreWebView style={{ flex: 1 }} html={description} automaticallySetHeight navigator={this.props.navigator}/>)
    } else {
      // $FlowFixMe
      return (<DescriptionDefaultView />)
    }
  }
}

const style = createStyleSheet((colors, vars) => ({
  topContainer: {
    paddingTop: 14,
    paddingLeft: vars.padding,
    paddingRight: vars.padding,
    paddingBottom: 17,
  },
  pointsContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 2,
  },
  points: {
    fontWeight: '500',
    color: colors.textDark,
    marginRight: 14,
  },
  details: {
    flex: 1,
    flexDirection: 'row',
    marginBottom: 8,
  },
  previewQuizButton: {
    flex: 1,
    backgroundColor: colors.buttonPrimaryBackground,
    height: 51,
    borderRadius: 4,
    marginTop: vars.padding,
    marginBottom: vars.padding,
    marginLeft: vars.padding,
    marginRight: vars.padding,
  },
  previewQuizButtonContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 4,
    backgroundColor: colors.buttonPrimaryBackground,
  },
  previewQuizButtonTitle: {
    color: colors.buttonPrimaryText,
    fontWeight: '600',
  },
  detailsSection: {
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
    paddingTop: vars.padding,
    paddingBottom: vars.padding,
    paddingLeft: vars.padding,
    paddingRight: vars.padding,
  },
  header: {
    color: colors.textDark,
    fontWeight: '500',
    fontSize: 16,
    marginBottom: 4,
  },
  section: {
    flex: 1,
    paddingTop: vars.padding,
    paddingRight: vars.padding,
    paddingBottom: vars.padding,
    paddingLeft: vars.padding,
    backgroundColor: colors.backgroundLightest,
    borderTopWidth: vars.hairlineWidth,
    borderTopColor: colors.borderMedium,
  },
}))

export function mapStateToProps ({ entities }: AppState, { courseID, quizID }: OwnProps): State {
  let quiz: ?Quiz
  let pending = 0
  let error = null
  let assignmentGroup = null
  let assignment = null
  let courseName = ''
  let courseColor = null

  if (entities.quizzes &&
    entities.quizzes[quizID] &&
    entities.quizzes[quizID].data) {
    const state = entities.quizzes[quizID]
    quiz = state.data
    pending = state.pending
    error = state.error

    if (entities &&
      entities.courses &&
      entities.courses[courseID] &&
      entities.courses[courseID].course) {
      courseName = entities.courses[courseID].course.name
      courseColor = entities.courses[courseID].color
    }

    if (quiz.assignment_group_id &&
      entities.assignmentGroups &&
      entities.assignmentGroups[quiz.assignment_group_id]) {
      assignmentGroup = entities.assignmentGroups[quiz.assignment_group_id].group
    }

    if (quiz.assignment_id &&
      entities.assignments &&
      entities.assignments[quiz.assignment_id]) {
      assignment = entities.assignments[quiz.assignment_id].data
    }
  }

  return {
    quiz,
    pending,
    error,
    courseID,
    courseName,
    courseColor,
    quizID,
    assignmentGroup,
    assignment,
    // Assignment details no longer fetches courses so we'll show submission summary for designers until quiz details is re-implemented in native
    // showSubmissionSummary: enrollment && enrollment.type !== 'designer',
    showSubmissionSummary: true,
  }
}

let Refreshed = refresh(
  props => props.refreshQuiz(props.courseID, props.quizID),
  props => !props.quiz || !props.assignmentGroup || !props.assignment,
  props => Boolean(props.pending)
)(QuizDetails)
let Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<Props, any>)
