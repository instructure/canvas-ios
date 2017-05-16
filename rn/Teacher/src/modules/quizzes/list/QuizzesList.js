/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  SectionList,
} from 'react-native'
import i18n from 'format-message'

import Actions from './actions'
import refresh from '../../../utils/refresh'
import QuizRow from './QuizRow'
import { SectionHeader } from '../../../common/text'
import Screen from '../../../routing/Screen'

type OwnProps = {
  courseID: string,
}

type State = {
  quizzes: Quiz[],
  courseColor: ?string,
}

export type Props = State & typeof Actions & {
  navigator: Navigator,
}

const HEADERS = {
  'assignment': i18n('Assignments'),
  'practice_quiz': i18n('Practice Quiz'),
  'graded_survey': i18n('Graded Survey'),
  'survey': i18n('Survey'),
}

export class QuizzesList extends Component<any, Props, any> {

  renderRow = ({ item, index }: { item: Quiz, index: number }) => {
    return (
      <QuizRow
        quiz={item}
        index={index}
        tintColor={this.props.courseColor}
        onPress={this._selectedQuiz}
      />
    )
  }

  renderSectionHeader = ({ section }: any) => {
    return <SectionHeader>{HEADERS[section.key]}</SectionHeader>
  }

  _selectedQuiz = (quiz: Quiz) => {
    this.props.navigator.show(quiz.html_url)
  }

  _getData = () => {
    const sections = this.props.quizzes
      .reduce((data, quiz) => ({
        ...data,
        [quiz.quiz_type]: (data[quiz.quiz_type] || []).concat([quiz]),
      }), {})

    return Object.keys(sections).map((key) => {
      return {
        key,
        data: this._sortSectionByKey(sections[key], key),
      }
    })
  }

  _sortSectionByKey (section: Quiz[], key: string): Array<Quiz> {
    const sortBy = key === 'assignment' ? 'due_at' : 'lock_at'
    return section.sort((a, b) => {
      const tieBreaker = a.title.toLowerCase() < b.title.toLowerCase() ? -1 : 1
      if (!a[sortBy] && !b[sortBy]) {
        return tieBreaker
      }
      if (!a[sortBy]) {
        return 1
      }
      if (!b[sortBy]) {
        return -1
      }
      const x = new Date(a[sortBy]) < new Date(b[sortBy]) ? -1 : 1
      return x === 0 ? tieBreaker : x
    })
  }

  render (): React.Element<View> {
    return (
      <Screen
        navBarColor={this.props.courseColor}
        drawUnderNavBar={true}
        title={i18n({
          default: 'Quizzes',
          description: 'Title of the quizzes screen for a course',
        })}>
        <View style={styles.container}>
          <SectionList
            sections={this._getData()}
            renderSectionHeader={this.renderSectionHeader}
            renderItem={this.renderRow}
            refreshing={Boolean(this.props.pending)}
            onRefresh={this.props.refresh}
            keyExtractor={(item, index) => item.id}
            testID='quiz-list.list'
          />
        </View>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})

export function mapStateToProps ({ entities }: AppState, { courseID }: OwnProps): State {
  let quizzes = []
  let courseColor = null
  if (entities &&
    entities.courses &&
    entities.courses[courseID] &&
    entities.courses[courseID].quizzes &&
    entities.quizzes) {
    const course = entities.courses[courseID]
    const refs = course.quizzes.refs
    quizzes = refs
      .map(ref => entities.quizzes[ref].data)
    courseColor = course.color
  }

  return {
    quizzes,
    courseColor,
  }
}

const Refreshed = refresh(
  props => {
    props.refreshQuizzes(props.courseID)
  },
  props => props.quizzes.length === 0,
  props => Boolean(props.pending)
)(QuizzesList)
const Connected = connect(mapStateToProps, Actions)(Refreshed)
export default (Connected: Component<any, Props, any>)
