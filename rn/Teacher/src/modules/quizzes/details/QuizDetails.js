/* @flow */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  TouchableHighlight,
} from 'react-native'
import i18n from 'format-message'

import Actions from './actions'
import AssignmentSection from '../../assignment-details/components/AssignmentSection'
import AssignmentDates from '../../assignment-details/components/AssignmentDates'
import PublishedIcon from '../../assignment-details/components/PublishedIcon'
import { RefreshableScrollView } from '../../../common/components/RefreshableList'
import WebContainer from '../../../common/components/WebContainer'
import DescriptionDefaultView from '../../../common/components/DescriptionDefaultView'
import {
  Heading1,
  Text,
} from '../../../common/text'
import colors from '../../../common/colors'
import Images from '../../../images'
import refresh from '../../../utils/refresh'
import formatter from '../formatter'
import Screen from '../../../routing/Screen'
import Navigator from '../../../routing/Navigator'
import QuizSubmissionBreakdownGraphSection from '../submissions/components/QuizSubmissionBreakdownGraphSection'

type OwnProps = {
  quizID: string,
  courseID: string,
}

type State = {
  quiz: ?Quiz,
  assignmentGroup: ?AssignmentGroup,
  assignment: ?Assignment,
}

export type Props = State & OwnProps & RefreshProps & Actions & {
  navigator: Navigator,
}

export class QuizDetails extends Component<any, Props, any> {

  previewQuiz = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/quizzes/${this.props.quizID}/preview`, { modal: true })
  }

  viewAllSubmissions = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/quizzes/${this.props.quizID}/submissions`)
  }

  onSubmissionDialPress = (type: string) => {
    this.viewSubmissions(type)
  }

  viewSubmissions = (filterType: ?string) => {
    if (global.V02) {
      const { courseID, quizID } = this.props
      if (filterType) {
        this.props.navigator.show(`/courses/${courseID}/quizzes/${quizID}/submissions`, { modal: false }, { filterType })
      } else {
        this.props.navigator.show(`/courses/${courseID}/quizzes/${quizID}/submissions`)
      }
    }
  }

  render () {
    const quiz = this.props.quiz
    let content
    if (!quiz) {
      content = <View />
    } else {
      content = (
        <RefreshableScrollView
          refreshing={this.props.refreshing}
          onRefresh={this.props.refresh}>
          <AssignmentSection isFirstRow={true} style={style.topContainer}>
            <Heading1>{quiz.title}</Heading1>
            <View style={style.pointsContainer}>
              { Boolean(quiz.points_possible) &&
                <Text style={style.points}>{`${quiz.points_possible} ${i18n('pts')}`}</Text>
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
            <AssignmentDates assignment={this.props.assignment || quiz} />
          </AssignmentSection>

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

          <View style={style.section}>
            <Text style={style.header}>{i18n('Description')}</Text>
            {this.checkAssignmentDescription(quiz.description)}
          </View>

          {this._renderDetails()}
          <TouchableHighlight
            onPress={this.previewQuiz}
            style={{ borderRadius: 4 }}
            accessible={true}
            accessibilityLabel={i18n('Preview Quiz')}
            accessibilityTraits='button'
            testID='quizzes.details.previewQuiz.btn'
          >
            <View style={style.previewQuizButton}>
              <Text style={style.previewQuizButtonTitle}>{i18n('Preview Quiz')}</Text>
            </View>
          </TouchableHighlight>
        </RefreshableScrollView>
      )
    }

    return (
      <Screen
        navBarStyle='dark'
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
          details.filter(d => d[1]).map((detail) => {
            // $FlowFixMe
            const accessibilityLabel = `${detail[0]}, ${detail[1]}`
            return (
              <View
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
    this.props.navigator.show(`/courses/${this.props.courseID}/quizzes/${this.props.quiz.id}/edit`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  _viewDueDates = () => {
    if (this.props.assignment) {
      const route = `/courses/${this.props.courseID}/assignments/${this.props.assignment.id}/due_dates`
      this.props.navigator.show(route, { modal: false }, { onEditPressed: this._editQuiz })
    }
  }

  checkAssignmentDescription (description: ?string) {
    if (description) {
      return (<WebContainer style={{ flex: 1 }} html={description}/>)
    } else {
      return (<DescriptionDefaultView />)
    }
  }
}

const style = StyleSheet.create({
  topContainer: {
    paddingTop: 14,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
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
    color: colors.grey4,
    marginRight: 14,
  },
  details: {
    flex: 1,
    flexDirection: 'row',
    marginBottom: 8,
  },
  previewQuizButton: {
    flex: 1,
    backgroundColor: '#008EE2',
    height: 51,
    borderRadius: 4,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: global.style.defaultPadding,
    marginBottom: global.style.defaultPadding,
    marginLeft: global.style.defaultPadding,
    marginRight: global.style.defaultPadding,
  },
  previewQuizButtonTitle: {
    color: 'white',
    fontWeight: '600',
  },
  detailsSection: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.grey2,
    paddingTop: global.style.defaultPadding,
    paddingBottom: global.style.defaultPadding,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
  },
  header: {
    color: colors.grey4,
    fontWeight: '500',
    fontSize: 16,
    marginBottom: 4,
  },
  section: {
    flex: 1,
    paddingTop: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
    paddingBottom: global.style.defaultPadding,
    paddingLeft: global.style.defaultPadding,
    backgroundColor: 'white',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.grey2,
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID, quizID }: OwnProps): State {
  let quiz: ?Quiz
  let pending = 0
  let error = null
  let assignmentGroup = null
  let assignment = null
  let courseName = ''

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
    quizID,
    assignmentGroup,
    assignment,
  }
}

let Refreshed = refresh(
  props => props.refreshQuiz(props.courseID, props.quizID),
  props => !props.quiz || !props.assignmentGroup || !props.assignment,
  props => Boolean(props.pending)
)(QuizDetails)
let Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<any, Props, any>)
