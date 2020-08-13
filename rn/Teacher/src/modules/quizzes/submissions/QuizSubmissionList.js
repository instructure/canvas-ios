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

// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import Actions from './actions'
import SectionActions from '../../assignee-picker/actions'
import EnrollmentActions from '../../enrollments/actions'
import CoursesActions from '../../courses/actions'
import {
  View,
  Animated,
  Text,
  FlatList,
} from 'react-native'

import refresh from '../../../utils/refresh'
import Screen from '../../../routing/Screen'
import SubmissionsHeader from '../../submissions/SubmissionsHeader'
import OldSubmissionRow, { type OldSubmissionRowDataProps } from '../../submissions/list/OldSubmissionRow'
import mapStateToProps from './map-state-to-props'
import Images from '../../../images'
import i18n from 'format-message'
import ActivityIndicatorView from '../../../common/components/ActivityIndicatorView'
import RowSeparator from '../../../common/components/rows/RowSeparator'
import ListEmptyComponent from '../../../common/components/ListEmptyComponent'
import defaultFilterOptions, { type SubmissionFilterOption, oldCreateFilter as createFilter, joinTitles } from '../../filter/filter-options'
import { createStyleSheet } from '../../../common/stylesheet'

export type QuizSubmissionListNavProps = {
  courseID: string,
  quizID: string,
  filterType: ?string,
  refresh: Function,
  navigator: Navigator,
}

export type QuizSubmissionListDataProps = {
  rows: OldSubmissionRowDataProps[],
  quiz: QuizState,
  pending: boolean,
  error: ?string,
  pointsPossible: number,
  anonymous: boolean,
  sections: Array<Section>,
}

export type QuizSubmissionListProps = QuizSubmissionListDataProps & QuizSubmissionListNavProps

export type QuizSubmissionListState = {
  filterOptions: Array<SubmissionFilterOption>,
}

export class QuizSubmissionList extends Component<QuizSubmissionListProps, any> {
  filterOptions: SubmissionFilterOption[]
  selectedFilter: ?Function

  constructor (props: any) {
    super(props)

    let filterOptions = [ ...defaultFilterOptions(this.props.filterType), ...this.props.sections.map(createFilterFromSection) ]
    let filter = createFilter(filterOptions)

    this.state = {
      filterOptions,
      filter,
      practiceQuizTranslate: new Animated.Value(100),
    }
  }

  navigateToSubmission = (index: number) => (userID: string) => {
    const { quiz, courseID } = this.props
    if (!quiz.data.assignment_id) return
    const path = `/courses/${courseID}/assignments/${quiz.data.assignment_id}/submissions/${userID}`

    this.props.navigator.show(
      path,
      { modal: true, modalPresentationStyle: 'fullscreen' },
      { filter: this.state.filter, studentIndex: index }
    )
  }

  showSnackbar = () => {
    Animated.sequence([
      Animated.timing(
        this.state.practiceQuizTranslate,
        {
          toValue: 0,
          duration: 500,
          useNativeDriver: true,
        }
      ),
      Animated.delay(2000),
      Animated.timing(
        this.state.practiceQuizTranslate,
        {
          toValue: 100,
          duration: 500,
          useNativeDriver: true,
        }
      ),
    ]).start()
  }

  componentWillReceiveProps = (newProps: QuizSubmissionListProps) => {
    if (this.props.sections.length !== newProps.sections.length) {
      let filterOptions = [ ...this.state.filterOptions, ...newProps.sections.map(createFilterFromSection) ]
      let filter = createFilter(filterOptions)
      this.setState({
        filterOptions,
        filter,
      })
    }
  }

  applyFilter = (filterOptions: Array<SubmissionFilterOption>): void => {
    this.setState({
      filterOptions,
      filter: createFilter(filterOptions),
    })
  }

  renderRow = ({ item, index }: { item: OldSubmissionRowDataProps, index: number }) => {
    let onPress = this.props.quiz?.data.assignment_id == null
      ? this.showSnackbar
      : this.navigateToSubmission(index)

    return <OldSubmissionRow
      {...item}
      onPress={onPress}
      anonymous={this.props.anonymous}
      disabled={this.props.quiz?.data.assignment_id == null}
    />
  }

  keyExtractor = (item: OldSubmissionRowDataProps) => {
    return item.userID
  }

  openSubmissionSettings = () => {
    this.props.navigator.show(
      `/courses/${this.props.courseID}/assignments/${this.props.quiz.data.assignment_id}/submission_settings`,
      { modal: true }
    )
  }

  messageStudentsWho = () => {
    var subject = ''
    let jointTitles = joinTitles(this.state.filterOptions)
    if (jointTitles) {
      subject = `${jointTitles} - ${this.props.quiz.title}`
    }
    const recipients = this.state.filter(this.props.rows).map(row => {
      return { id: row.userID, name: row.name, avatar_url: row.avatarURL }
    })

    this.props.navigator.show('/conversations/compose', { modal: true }, {
      recipients,
      subject,
      contextName: this.props.courseName,
      contextCode: this.props.courseID ? `course_${this.props.courseID}` : null,
      canAddRecipients: false,
      onlySendIndividualMessages: true,
    })
  }

  render () {
    let rightBarButtons = [{
      accessibilityLabel: i18n('Message students who'),
      image: Images.smallMail,
      testID: 'submission-list.message-who-btn',
      action: this.messageStudentsWho,
    }]
    if (this.props.quiz && this.props.quiz.data.assignment_id) {
      rightBarButtons.push({
        accessibilityLabel: i18n('Submission Settings'),
        image: Images.course.settings,
        testID: 'quiz-submissions.settings',
        action: this.openSubmissionSettings,
      })
    }

    return (
      <Screen
        title={i18n('Submissions')}
        subtitle={this.props.courseName}
        navBarColor={this.props.courseColor}
        navBarStyle='context'
        rightBarButtons={rightBarButtons}
      >
        {this.props.pending && !this.props.refreshing
          ? <ActivityIndicatorView />
          : <View style={styles.container}>
            <SubmissionsHeader
              filterOptions={this.state.filterOptions}
              applyFilter={this.applyFilter}
              initialFilterType={this.props.filterType}
              filterPromptMessage={i18n('Out of {points, number}', { points: this.props.pointsPossible })}
              navigator={this.props.navigator}
              pointsPossible={this.props.pointsPossible}
              anonymous={this.props.anonymous}
            />
            <FlatList
              data={this.state.filter(this.props.rows)}
              keyExtractor={this.keyExtractor}
              testID='quiz-submission-list'
              renderItem={this.renderRow}
              refreshing={this.props.refreshing}
              onRefresh={this.props.refresh}
              ItemSeparatorComponent={RowSeparator}
              ListEmptyComponent={
                <ListEmptyComponent title={i18n('No results')} />
              }
            />
            <Animated.View
              style={{
                ...styles.practiceQuiz,
                transform: [{ translateY: this.state.practiceQuizTranslate }],
              }}
            >
              <Text style={styles.practiceQuizText}>{i18n('Practice quizzes & surveys do not have detail views.')}</Text>
            </Animated.View>
          </View>
        }
      </Screen>
    )
  }
}

const styles = createStyleSheet((colors, vars) => ({
  container: {
    flex: 1,
  },
  header: {
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    paddingTop: 16,
    paddingBottom: 12,
    paddingHorizontal: 16,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: colors.textDarkest,
  },
  filterButton: {
    marginBottom: 1,
  },
  practiceQuiz: {
    backgroundColor: colors.textDarkest,
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    paddingVertical: 16,
    paddingHorizontal: 16,
  },
  practiceQuizText: {
    color: colors.textLightest,
    fontSize: 14,
    fontWeight: '400',
  },
}))

export function refreshQuizSubmissionData (props: any): void {
  const { courseID, quizID } = props
  props.refreshSections(courseID)
  props.refreshQuizSubmissions(courseID, quizID)
  props.refreshEnrollments(courseID)
  props.getCourseEnabledFeatures(courseID)
}

let Refreshed = refresh(
  refreshQuizSubmissionData,
  props => true,
  props => Boolean(props.pending)
)(QuizSubmissionList)
let Connected = connect(mapStateToProps, { ...Actions, ...EnrollmentActions, ...SectionActions, ...CoursesActions })(Refreshed)
export default (Connected: Component<QuizSubmissionListProps, any>)

function createFilterFromSection (section) {
  return {
    type: `section.${section.id}`,
    title: () => section.name,
    disabled: false,
    selected: false,
    exclusive: false,
    filterFunc: (submission) => {
      return submission.allSectionIDs.includes(section.id)
    },
  }
}
