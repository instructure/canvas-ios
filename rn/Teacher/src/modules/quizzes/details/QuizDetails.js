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
import PublishedIcon from '../../assignment-details/components/PublishedIcon'
import { RefreshableScrollView } from '../../../common/components/RefreshableList'
import WebContainer from '../../../common/components/WebContainer'
import {
  Heading1,
  Text,
} from '../../../common/text'
import colors from '../../../common/colors'
import refresh from '../../../utils/refresh'
import formatter from '../formatter'
import Screen from '../../../routing/Screen'
import Navigator from '../../../routing/Navigator'

type OwnProps = {
  quizID: string,
  courseID: string,
}

type State = {
  quiz: ?Quiz,
}

export type Props = State & RefreshProps & Actions & {
  navigator: Navigator,
}

export class QuizDetails extends Component<any, Props, any> {

  previewQuiz = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/quizzes/${this.props.quizID}/preview`, { modal: true })
  }

  render () {
    const quiz = this.props.quiz
    let content
    if (!quiz) {
      content = <View />
    } else {
      content = <RefreshableScrollView
                  refreshing={this.props.refreshing}
                  onRefresh={this.props.refresh}>
                  <AssignmentSection isFirstRow={true} style={style.topContainer}>
                    <Heading1>{quiz.title}</Heading1>
                    <View style={style.pointsContainer}>
                      { Boolean(quiz.points_possible) &&
                        <Text style={style.points}>{`${quiz.points_possible} ${i18n('pts')}`}</Text>
                      }
                      <PublishedIcon published={true} />
                  </View>
                  </AssignmentSection>

                  <AssignmentSection title={i18n('Description')}>
                    { Boolean(quiz.description) &&
                        <WebContainer style={{ flex: 1 }} html={quiz.description} />
                    }
                    { !quiz.description &&
                      <Text>{i18n('No description')}</Text>
                    }
                  </AssignmentSection>

                  <AssignmentSection>
                    {this._renderDetails()}
                  </AssignmentSection>
                  <AssignmentSection>
                    <TouchableHighlight onPress={this.previewQuiz} style={{ borderRadius: 4 }}>
                      <View style={style.previewQuizButton}>
                        <Text style={style.previewQuizButtonTitle}>{i18n('Preview Quiz')}</Text>
                      </View>
                    </TouchableHighlight>
                  </AssignmentSection>
                </RefreshableScrollView>
    }

    return (
      <Screen
        title={i18n('Quiz Details')}>
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
      [i18n('Shuffle Answers'), readable.shuffleAnswers],
      [i18n('Time Limit'), readable.timeLimit],
      [i18n('Allowed Attempts'), readable.allowedAttempts],
      [i18n('View Responses'), readable.viewResponses],
      [i18n('Show Correct Answers'), readable.showCorrectAnswers],
      [i18n('One Question at a Time'), readable.oneQuestionAtATime],
      [i18n('Score to Keep'), readable.scoringPolicy],
    ]
    return (
      <View>
        {
          details.filter(d => d[1]).map((detail) => {
            return (
              <View style={style.details}>
                <Text style={{ fontWeight: '600' }}>{`${detail[0]}:  `}</Text>
                <Text>{detail[1]}</Text>
              </View>
            )
          })
        }
      </View>
    )
  }
}

const style = StyleSheet.create({
  topContainer: {
    paddingTop: 2,
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
  },
  previewQuizButtonTitle: {
    color: 'white',
    fontWeight: '600',
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID, quizID }: OwnProps): State {
  let quiz: ?Quiz
  let pending = 0
  let error = null

  if (entities.quizzes &&
    entities.quizzes[quizID] &&
    entities.quizzes[quizID].data) {
    const state = entities.quizzes[quizID]
    quiz = state.data
    pending = state.pending
    error = state.error
  }

  return {
    quiz,
    pending,
    error,
  }
}

let Refreshed = refresh(
  props => props.refreshQuiz(props.courseID, props.quizID),
  props => !props.quiz,
  props => Boolean(props.pending)
)(QuizDetails)
let Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<any, Props, any>)
