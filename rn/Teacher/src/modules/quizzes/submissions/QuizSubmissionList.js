// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import Actions from './actions'
import EnrollmentActions from '../../enrollments/actions'
import {
  View,
  StyleSheet,
  FlatList,
} from 'react-native'

import find from 'lodash/find'
import refresh from '../../../utils/refresh'
import Screen from '../../../routing/Screen'
import SubmissionsHeader, { type SubmissionFilterOption, type SelectedSubmissionFilter } from '../../submissions/SubmissionsHeader'
import SubmissionRow, { type SubmissionRowDataProps } from '../../submissions/list/SubmissionRow'
import mapStateToProps from './map-state-to-props'
import Images from '../../../images'
import i18n from 'format-message'

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
}

export type QuizSubmissionListProps = QuizSubmissionListDataProps & QuizSubmissionListNavProps

export class QuizSubmissionList extends Component<any, QuizSubmissionListProps, any> {

  filterOptions: SubmissionFilterOption[]
  selectedFilter: ?SelectedSubmissionFilter

  constructor (props: any) {
    super(props)

    this.filterOptions = this.filterOptions = SubmissionsHeader.defaultFilterOptions()
    this.state = {
      rows: props.rows || [],
    }
  }

  navigateToSubmission = (userID: string) => {
    if (!global.V04) { return }
    const { quiz, courseID } = this.props
    if (!quiz.data.assignment_id) return
    const path = `/courses/${courseID}/assignments/${quiz.data.assignment_id}/submissions/${userID}`

    this.props.navigator.show(
      path,
      { modal: true },
      { selectedFilter: this.selectedFilter }
    )
  }

  componentWillMount = () => {
    const type = this.props.filterType
    if (type) {
      const filter = find(this.filterOptions, { type })
      if (filter) {
        this.selectedFilter = { filter }
      }
      this.updateRows(this.props.rows)
    }
  }

  componentWillReceiveProps = (newProps: QuizSubmissionListProps) => {
    this.updateRows(newProps.rows)
  }

  updateFilter = (filter: SelectedSubmissionFilter) => {
    this.selectedFilter = filter
    this.updateRows(this.props.rows)
  }

  clearFilter = () => {
    this.selectedFilter = null
    this.updateRows(this.props.rows)
  }

  updateRows = (rows: SubmissionRowDataProps[]) => {
    const selected = this.selectedFilter
    let filtered = rows
    if (selected && selected.filter && selected.filter.filterFunc) {
      filtered = selected.filter.filterFunc(rows, selected.metadata)
    }

    this.setState({
      rows: filtered,
    })
  }

  renderRow = ({ item }: { item: SubmissionRowDataProps }) => {
    let disclosure = true
    if (this.props.quiz) {
      disclosure = !!this.props.quiz.data.assignment_id
    }
    return <SubmissionRow {...item} onPress={this.navigateToSubmission} disclosure={disclosure} anonymous={this.props.anonymous} />
  }

  keyExtractor = (item: any) => {
    return item.userID
  }

  openSubmissionSettings = () => {
    this.props.navigator.show(
      `/courses/${this.props.courseID}/assignments/${this.props.quiz.data.assignment_id}/submission_settings`,
      { modal: true }
    )
  }

  render () {
    let rightBarButtons = []
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
        rightBarButtons={rightBarButtons}
      >
        <View style={styles.container}>
          <SubmissionsHeader
            filterOptions={this.filterOptions}
            selectedFilter={this.selectedFilter}
            onClearFilter={this.clearFilter}
            onSelectFilter={this.updateFilter}
            pointsPossible={this.props.pointsPossible}
            anonymous={this.props.anonymous}
            muted={this.props.muted} />
          <FlatList
            data={this.state.rows}
            keyExtractor={this.keyExtractor}
            testID='quiz-submission-list'
            renderItem={this.renderRow}
            refreshing={Boolean(this.props.pending)}
            onRefresh={this.props.refresh}
            />
        </View>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginBottom: global.tabBarHeight,
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
  props.refreshQuizSubmissions(courseID, quizID)
  props.refreshEnrollments(courseID)
}

let Refreshed = refresh(
  props => refreshQuizSubmissionData(props),
  props => true,
  props => Boolean(props.pending)
)(QuizSubmissionList)
let Connected = connect(mapStateToProps, { ...Actions, ...EnrollmentActions })(Refreshed)
export default (Connected: Component<any, QuizSubmissionListProps, any>)
