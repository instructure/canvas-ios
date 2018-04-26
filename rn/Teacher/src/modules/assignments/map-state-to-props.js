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
import { Component } from 'react'
import localeSort from '../../utils/locale-sort'
import Navigator from '../../routing/Navigator'
import AssignmentListActions from './actions'
import i18n from 'format-message'

export type AssignmentListDataProps = {
  pending: number,
  error?: ?string,
  courseColor: string,
  courseName: string,
  assignmentGroups: AssignmentGroup[],
  gradingPeriods: Array<GradingPeriod & { assignmentRefs: [string] }>,
  currentGradingPeriodID: ?string,
  selectedRowID: string,
  screenTitle: string,
  ListRow?: Class<Component<*, *>>,
  user?: SessionUser,
  currentScore?: number,
  showTotalScore: boolean,
}

export type AssignmentListProps = AssignmentListDataProps
  & RoutingProps
  & typeof AssignmentListActions
  & RefreshProps

export type RoutingProps = {
  courseID: string,
  navigator: Navigator,
}

export function mapStateToProps ({ entities }: AppState, { courseID, navigator }: RoutingProps): AssignmentListDataProps {
  const course = entities.courses[courseID]

  if (!course) {
    return {
      assignmentGroups: [],
      pending: 0,
      gradingPeriods: [],
      currentGradingPeriodID: null,
      courseColor: '',
      courseName: '',
      selectedRowID: '',
      screenTitle: i18n('Assignments'),
      showTotalScore: false,
    }
  }

  const courseColor = course.color
  const courseName = course.course.name
  const { refs, pending, error } = course.assignmentGroups
  const groupsByID: AssignmentGroupsState = entities.assignmentGroups
  const assignmentGroupsState = refs
    .map((ref) => groupsByID[ref])
    .sort((a, b) => a.group.position - b.group.position)

  const assignmentGroups: AssignmentGroup[] = assignmentGroupsState.map((groupState) => {
    const groupWithAssignments = Object.assign({}, groupState.group)
    groupWithAssignments.assignments = (groupState.assignmentRefs || []).map((id) => entities.assignments[id].data)
    return groupWithAssignments
  })

  let gradingPeriods = []
  if (course.gradingPeriods && course.gradingPeriods.refs) {
    gradingPeriods = course.gradingPeriods.refs
      .filter(r => entities.gradingPeriods[r])
      .map((ref) => ({
        ...entities.gradingPeriods[ref].gradingPeriod,
        assignmentRefs: entities.gradingPeriods[ref].assignmentRefs,
      }))
      .sort((gp1, gp2) => localeSort(gp1.title, gp2.title))
  }

  let selectedRowID = entities.courseDetailsTabSelectedRow.rowID || ''
  let currentGradingPeriodID
  for (const enroll of course.course.enrollments) {
    if (enroll.type === 'student' && enroll.current_grading_period_id) {
      currentGradingPeriodID = enroll.current_grading_period_id
      break
    }
  }

  return {
    pending,
    error,
    assignmentGroups,
    gradingPeriods,
    currentGradingPeriodID,
    courseColor,
    courseName,
    selectedRowID,
    screenTitle: i18n('Assignments'),
    showTotalScore: false,
  }
}
