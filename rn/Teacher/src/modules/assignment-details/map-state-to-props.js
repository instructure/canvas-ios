// @flow

import Navigator from '../../routing/Navigator'

export type AssignmentDetailsState = {
  +assignmentDetails: Assignment,
  +courseColor: string,
  +pending: number,
  +error?: ?string,
}

export type AssignmentDetailsProps = {
  assignmentDetails: Assignment,
  navigator: Navigator,
  courseID: string,
  courseColor?: string,
  courseName?: string,
  assignmentID: string,
  error?: any,
  pending?: number,
  updateAssignment: Function,
  refreshAssignment: (courseID: string, assignmentID: string) => Promise<Assignment>,
  cancelAssignmentUpdate: (originalAssignment: Assignment) => void,
  getSessionlessLaunchURL: Function,
} & RefreshProps

export function mapStateToProps (state: AppState, ownProps: AssignmentDetailsProps): AssignmentDetailsState {
  const assignment = state.entities.assignments[ownProps.assignmentID].data
  const course = state.entities.courses[ownProps.courseID]
  let courseName = ''

  if (course.course) {
    courseName = course.course.name
  }

  return {
    assignmentDetails: assignment,
    courseColor: course.color,
    courseName,
    pending: state.entities.courses[ownProps.courseID].assignmentGroups.pending,
  }
}

export function updateMapStateToProps (state: AppState, ownProps: AssignmentDetailsProps): AssignmentDetailsState {
  const assignment = state.entities.assignments[ownProps.assignmentID].data
  const course = state.entities.courses[ownProps.courseID]

  return {
    assignmentDetails: assignment,
    courseColor: course.color,
    pending: state.entities.assignments[ownProps.assignmentID].pending,
    error: state.entities.assignments[ownProps.assignmentID].error,
  }
}
