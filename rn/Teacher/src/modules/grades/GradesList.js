//
// Copyright (C) 2018-present Instructure, Inc.
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

import { connect } from 'react-redux'
import refresh from '../../utils/refresh'
import { AssignmentList } from '../assignments/AssignmentList'
import localeSort from '../../utils/locale-sort'
import AssignmentListActions from '../assignments/actions'
import CourseActions from '../courses/actions'
import EnrollmentActions from '../enrollments/actions'
import { type RoutingProps, type AssignmentListDataProps } from '../assignments/map-state-to-props'
import i18n from 'format-message'
import GradesListRow from './GradesListRow'
import { getSession } from '../../canvas-api'

export function mapStateToProps ({ entities }: AppState, { courseID, navigator }: RoutingProps): AssignmentListDataProps {
  const course = entities.courses[courseID]
  let { user } = getSession()

  if (!course) {
    return {
      assignmentGroups: [],
      pending: 0,
      gradingPeriods: [],
      currentGradingPeriodID: null,
      courseColor: '',
      courseName: '',
      selectedRowID: '',
      screenTitle: i18n('Grades'),
      ListRow: GradesListRow,
      user,
      currentScore: undefined,
      showTotalScore: true,
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
    const assignmentRefs = groupState.assignmentRefs || []
    groupWithAssignments.assignments = assignmentRefs
      .map((id) => entities.assignments[id].data)
      .filter(({ grading_type, submission_types }) => grading_type !== 'not_graded' && !(submission_types.length === 1 && submission_types[0] === 'not_graded'))
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
  let currentScore
  const enrollment = course.course.enrollments.find(e => e.type === 'student')
  if (enrollment) {
    if (enrollment.current_grading_period_id) {
      currentGradingPeriodID = enrollment.current_grading_period_id
    }
    const hideTotalGrade = course.course.hide_final_grades ||
      (enrollment.has_grading_periods && enrollment.totals_for_all_grading_periods_option === false)
    currentScore = hideTotalGrade ? null : enrollment.computed_current_score
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
    screenTitle: i18n('Grades'),
    ListRow: GradesListRow,
    user,
    currentScore,
    showTotalScore: true,
  }
}

export const Refreshed = refresh(
  props => {
    props.refreshAssignmentList(props.courseID, undefined, true)
    props.refreshGradingPeriods(props.courseID)
    props.refreshUserEnrollments()
    // Refresh course to get the current score (when there are no grading periods)
    props.refreshCourse(props.courseID)
  },
  props => props.assignmentGroups.length === 0 || props.gradingPeriods.length === 0 || !props.currentScore,
  props => Boolean(props.pending),
)(AssignmentList)
const Connected = connect(mapStateToProps, { ...AssignmentListActions, ...CourseActions, ...EnrollmentActions })(Refreshed)
export default Connected
