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

  // $FlowFixMe
  const enrollment = Object.keys(entities.enrollments)
    .map(id => entities.enrollments[id])
    .find(e => e.course_id === courseID && e.user_id === user.id)
  const currentScore = enrollment ? enrollment.grades.current_score : undefined

  if (!course) {
    return {
      assignmentGroups: [],
      pending: 0,
      gradingPeriods: [],
      courseColor: '',
      courseName: '',
      selectedRowID: '',
      screenTitle: i18n('Grades'),
      ListRow: GradesListRow,
      user,
      currentScore,
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

  return {
    pending,
    error,
    assignmentGroups,
    gradingPeriods,
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

const Refreshed = refresh(
  props => {
    props.refreshAssignmentList(props.courseID, undefined, true)
    props.refreshGradingPeriods(props.courseID)
    props.refreshUserEnrollments()
  },
  props => props.assignmentGroups.length === 0 || props.gradingPeriods.length === 0 || !props.currentScore,
  props => Boolean(props.pending),
)(AssignmentList)
const Connected = connect(mapStateToProps, { ...AssignmentListActions, ...CourseActions, ...EnrollmentActions })(Refreshed)
export default Connected
