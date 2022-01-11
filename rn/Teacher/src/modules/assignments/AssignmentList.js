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
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  ActionSheetIOS,
  SectionList,
  NativeModules,
  ActivityIndicator,
} from 'react-native'
import i18n from 'format-message'

import AssignmentListActions from './actions'
import CourseActions from '../courses/actions'
import { mapStateToProps, type AssignmentListProps } from './map-state-to-props'
import refresh from '../../utils/refresh'

import { isTeacher } from '../app'
import SectionHeader from '../../common/components/rows/SectionHeader'
import AssignmentListRowView from './components/AssignmentListRow'
import { LinkButton } from '../../common/buttons'
import { Heading1, Heading2, Text } from '../../common/text'
import Screen from '../../routing/Screen'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import ListEmptyComponent from '../../common/components/ListEmptyComponent'
import { getGradesForGradingPeriod } from '../../canvas-api'
import { logEvent } from '../../common/CanvasAnalytics'
import { createStyleSheet } from '../../common/stylesheet'

type State = {
  currentFilter: {
    index?: number,
    title: string,
  },
  filterApplied: boolean,
  currentScore: ?number,
  loadingGrade: boolean,
  gradeError: boolean,
  selectedRowID: ?string,
}

const { NativeAccessibility, SiriShortcutManager } = NativeModules

export class AssignmentList extends Component<AssignmentListProps, State> {
  state: State
  isRegularScreenDisplayMode: boolean
  data: any = []

  static defaultProps = {
    ListRow: AssignmentListRowView,
    getGradesForGradingPeriod,
  }

  state = {
    currentFilter: { title: i18n('All') },
    filterApplied: false,
    currentScore: this.props.currentScore,
    loadingGrade: false,
    gradeError: false,
    selectedRowID: null,
  }

  componentDidMount () {
    this.showCurrentPeriod()
  }

  componentDidUpdate (prevProps: AssignmentListProps) {
    if (
      prevProps.gradingPeriods.length !== this.props.gradingPeriods.length ||
      prevProps.currentGradingPeriodID !== this.props.currentGradingPeriodID
    ) {
      this.showCurrentPeriod() // can only updateFilter properly after props is updated
    }
  }

  showCurrentPeriod () {
    const index = this.props.gradingPeriods.findIndex(({ id }) =>
      id === this.props.currentGradingPeriodID
    )
    if (index >= 0) this.updateFilter(index)
  }

  UNSAFE_componentWillReceiveProps (nextProps: AssignmentListProps) {
    if (nextProps.assignmentGroups.length && nextProps.gradingPeriods.length) {
      NativeAccessibility.refresh()
    }

    if (nextProps.currentScore !== this.props.currentScore) {
      this.setState({ currentScore: nextProps.currentScore })
    }
  }

  componentWillUnmount () {
    const currentScore = this.state.currentScore || 0
    if (this.props.showTotalScore && currentScore > 90) {
      NativeModules.AppStoreReview.handleSuccessfulSubmit()
    }
  }

  prepareListData () {
    return this.props.assignmentGroups.map(group => {
      let gradingPeriodFilter
      if (this.state.currentFilter.index != null) {
        gradingPeriodFilter = this.props.gradingPeriods[this.state.currentFilter.index]
      }
      let assignments = this.state.filterApplied
        ? group.assignments.filter(({ id }) => gradingPeriodFilter.assignmentRefs.includes(id))
        : group.assignments

      if (assignments.length) {
        return {
          key: group.id,
          ...group,
          data: assignments.slice().sort((a, b) => a.position - b.position),
        }
      }
    }).filter(item => item)
  }

  renderRow = ({ item, index }: { item: Assignment, index: number }) => {
    let selected = this.isRegularScreenDisplayMode && this.state.selectedRowID === item.id
    let ListRow = this.props.ListRow
    return (
      <ListRow
        assignment={item}
        tintColor={this.props.courseColor}
        onPress={this.selectedAssignment}
        key={index}
        selected={selected}
        user={this.props.user}
      />
    )
  }

  renderSectionHeader = ({ section }: any) => {
    return <SectionHeader title={section.name} key={section.key} top={section.position === 1} />
  }

  selectedAssignment = (assignment: Assignment) => {
    logEvent('assignment_selected')
    this.props.updateCourseDetailsSelectedTabSelectedRow(assignment.id)
    this.setState({ selectedRowID: assignment.id })
    if (assignment.discussion_topic && isTeacher()) {
      this.props.navigator.show(`/courses/${assignment.course_id}/discussion_topics/${assignment.discussion_topic.id}`)
    } else {
      this.props.navigator.show(assignment.html_url)
    }
  }

  updateGradeForGradingPeriod = async (gradingPeriod: GradingPeriod) => {
    try {
      this.setState({ loadingGrade: true, gradeError: false })
      let grades = await this.props.getGradesForGradingPeriod(this.props.courseID, 'self', gradingPeriod.id)
      this.setState({ loadingGrade: false, currentScore: grades.current_score })
    } catch (err) {
      console.error('Error loading grade', err)
      this.setState({ loadingGrade: false, gradeError: true })
    }
  }

  clearFilter = () => {
    this.setState({
      currentFilter: { title: i18n('All') },
      filterApplied: false,
      currentScore: this.props.currentScore,
    })
  }

  applyFilter = () => {
    let buttons = this.props.gradingPeriods.map(({ title }) => title).concat(i18n('Cancel'))
    ActionSheetIOS.showActionSheetWithOptions({
      options: buttons,
      cancelButtonIndex: buttons.length - 1,
      title: i18n('Filter by:'),
    }, this.updateFilter)
  }

  updateFilter = (index: number) => {
    // don't do anything if the user hits cancel
    if (index === this.props.gradingPeriods.length) return

    // always get assignment info for grading period, since it might be shared
    this.props.refreshAssignmentList(this.props.courseID, this.props.gradingPeriods[index].id, true)

    // get the grade for the current grading period
    if (this.props.showTotalScore) {
      this.updateGradeForGradingPeriod(this.props.gradingPeriods[index])
    }

    this.setState({
      currentFilter: {
        title: this.props.gradingPeriods[index].title,
        index,
      },
      filterApplied: true,
    })
  }

  toggleFilter = () => {
    if (this.state.filterApplied) {
      this.clearFilter()
    } else {
      this.applyFilter()
    }
  }

  render () {
    if (this.props.pending && !this.props.refreshing) {
      return <ActivityIndicatorView />
    }
    if (this.data.length === 0) {
      this.data = this.prepareListData()
    } else {
      this.data = this.prepareListData()
    }

    if (this.props.showGrades) {
      SiriShortcutManager.donateSiriShortcut({ 'identifier': 'com.instructure.siri.shortcut.getgrades', 'url': `/courses/${this.props.courseID}/grades`, 'name': this.props.courseCode })
    }

    return (
      <Screen
        title={this.props.screenTitle}
        subtitle={this.props.courseName}
        navBarColor={this.props.courseColor}
        navBarStyle='context'
        testID='assignment-list'
      >
        <View style={styles.container} testID='assignment-list.container-view'>
          <View style={styles.header}>
            <View style={styles.gradingPeriodHeader} testID='assignment-list.filter-header-view'>
              <Heading1 style={styles.headerTitle} testID='assignment-list.filter-title-lbl'>{this.state.currentFilter.title}</Heading1>
              {this.props.gradingPeriods.length > 0 &&
                <LinkButton testID='assignment-list.filter' onPress={this.toggleFilter} style={styles.filterButton}>
                  {this.state.filterApplied
                    ? i18n('Clear filter')
                    : i18n('Filter')}
                </LinkButton>
              }
            </View>
            {this.props.showTotalScore &&
              <View style={styles.gradeHeader} testID='assignment-list.total-grade'>
                <Heading2>{i18n('Total Grade:')}</Heading2>
                {this.state.loadingGrade
                  ? <ActivityIndicator />
                  : this.state.currentScore
                    ? <Text>{i18n.number(this.state.currentScore / 100, 'percent')}</Text>
                    : <Text>{i18n('N/A')}</Text>
                }
              </View>
            }
          </View>
          <SectionList
            testID='assignment-list.list'
            sections={this.data}
            renderItem={this.renderRow}
            renderSectionHeader={this.renderSectionHeader}
            refreshing={this.props.refreshing}
            onRefresh={this.refresh}
            keyExtractor={(item, index) => item.id}
            ListEmptyComponent={
              <ListEmptyComponent title={i18n('There are no assignments to display.')} />
            }
          />
        </View>
      </Screen>
    )
  }

  refresh = () => {
    if (this.state.currentFilter.index != null) {
      // Refresh total for selected grading period
      const gradingPeriod = this.props.gradingPeriods[this.state.currentFilter.index]
      this.updateGradeForGradingPeriod(gradingPeriod)
    }

    this.props.refresh()
  }
}

const styles = createStyleSheet((colors, vars) => ({
  container: {
    flex: 1,
  },
  header: {
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
    paddingTop: vars.padding,
    paddingBottom: vars.padding / 2,
    paddingHorizontal: vars.padding,
  },
  gradingPeriodHeader: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
  },
  headerTitle: {
    flex: 1,
  },
  filterButton: {
    marginBottom: 1,
  },
  gradeHeader: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
  },
}))

const Refreshed = refresh(
  props => {
    props.refreshCourse(props.courseID)
    props.refreshAssignmentList(props.courseID)
    props.refreshGradingPeriods(props.courseID)
  },
  props => props.assignmentGroups.length === 0 || props.gradingPeriods.length === 0,
  props => Boolean(props.pending),
)(AssignmentList)
const Connected = connect(mapStateToProps, { ...AssignmentListActions, ...CourseActions })(Refreshed)
export default (Connected: Component<AssignmentListProps, State>)
