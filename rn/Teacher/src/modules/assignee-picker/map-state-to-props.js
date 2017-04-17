// @flow

import { cloneDeep } from 'lodash'
import i18n from 'format-message'

export type AssigneeSearchProps = {
  courseID: string,
  sections: Section[],
  enrollments: Enrollment[],
  onSelection: Function,
  navigator: ReactNavigator,
  refreshSections: Function,
  refreshEnrollments: Function,
}

function studentEnrollmentsForCourseID (courseID: string, state: AppState): any {
  return Object.values(state.entities.enrollments).filter((item) => {
    // $FlowFixMe
    if (item.course_id !== courseID) return false
    // $FlowFixMe
    if (item.type !== 'StudentEnrollment') return false
    // $FlowFixMe
    if (item.enrollment_state !== 'active') return false
    return true
  })
}

export function searchMapStateToProps (state: AppState, ownProps: AssigneeSearchProps): any {
  const courseID = ownProps.courseID
  const enrollments = studentEnrollmentsForCourseID(courseID, state)

  const sections = Object.values(state.entities.sections).filter((item) => {
    // $FlowFixMe
    return item.course_id === courseID
  })

  return {
    sections,
    enrollments,
  }
}

export type Assignee = {
  id: string, // A combindation of dataId and type, so `student-2343` or `everyone`
  dataId: string, // the id from the actual data, which could collide across types
  type: 'student' | 'section' | 'everyone' | 'group',
  name: string,
  info?: string, // Generally used as the subtitle in the AssigneeRow
  imageURL?: ?string,
}

export type AssigneePickerProps = {
  courseID: string,
  assignees: Assignee[],
  navigator: ReactNavigator,
  callback?: Function, // Called when finished picking assignees. Will send the new list of assignees as the first parameter
  refreshSections: Function,
  refreshUsers: Function,
}

export function pickerMapStateToProps (state: AppState, ownProps: AssigneePickerProps): any {
  let assignees = ownProps.assignees || []

  // Makes sure that we have all the right information on assignees, such as the name and image
  assignees = assignees.map((assignee) => {
    const newAssignee = cloneDeep(assignee)
    switch (newAssignee.type) {
      case 'everyone':
        if (assignees.length > 1) {
          newAssignee.name = i18n('Everyone else')
        } else {
          newAssignee.name = i18n('Everyone')
        }
        break
      case 'student':
        console.log(assignee)
        const user = state.entities.users[assignee.dataId]
        console.log(state.entities.users)
        console.log(user)
        if (user) {
          newAssignee.name = user.name
          newAssignee.imageURL = user.avatar_url
        }
        break
      case 'section':
        const section = state.entities.sections[assignee.dataId]
        if (section) {
          newAssignee.name = section.name
        }
        break
        // TODO groups
    }

    return newAssignee
  })

  return { assignees }
}
