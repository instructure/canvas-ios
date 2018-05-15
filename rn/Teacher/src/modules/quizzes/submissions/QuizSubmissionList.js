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
import { connect } from 'react-redux'
import Actions from './actions'
import SectionActions from '../../assignee-picker/actions'
import EnrollmentActions from '../../enrollments/actions'
import CoursesActions from '../../courses/actions'
import {
  View,
  StyleSheet,
  FlatList,
} from 'react-native'

import refresh from '../../../utils/refresh'
import Screen from '../../../routing/Screen'
import SubmissionsHeader from '../../submissions/SubmissionsHeader'
import SubmissionRow, { type SubmissionRowDataProps } from '../../submissions/list/SubmissionRow'
import mapStateToProps from './map-state-to-props'
import Images from '../../../images'
import i18n from 'format-message'
import ActivityIndicatorView from '../../../common/components/ActivityIndicatorView'
import RowSeparator from '../../../common/components/rows/RowSeparator'
import ListEmptyComponent from '../../../common/components/ListEmptyComponent'
import defaultFilterOptions, { type SubmissionFilterOption, createFilter, joinTitles } from '../../filter/filter-options'

export type QuizSubmissionListNavProps = {
  courseID: string,
  quizID: string,
  filterType: ?string,
  refresh: Function,
  navigator: Navigator,
}

export type QuizSubmissionListDataProps = {
  rows: SubmissionRowDataProps[],
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

  renderRow = ({ item, index }: { item: SubmissionRowDataProps, index: number }) => {
    let disclosure = true
    if (this.props.quiz) {
      disclosure = !!this.props.quiz.data.assignment_id
    }
    return <SubmissionRow
      {...item}
      onPress={this.navigateToSubmission(index)}
      disclosure={disclosure}
      anonymous={this.props.anonymous}
      disabled={!this.props.quiz.data.assignment_id}
    />
  }

  keyExtractor = (item: SubmissionRowDataProps) => {
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
        navBarStyle='dark'
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
              muted={this.props.muted} />
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
          </View>
        }
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
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
    color: '#2d3b44',
  },
  filterButton: {
    marginBottom: 1,
  },
})

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
