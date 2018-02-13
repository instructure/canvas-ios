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

import { cloneDeep } from 'lodash'
import i18n from 'format-message'
import Navigator from '../../routing/Navigator'
import EnrollmentActions from '../enrollments/actions'
import SectionActions from './actions'
import { asyncChecker } from '../../redux/actions/async-tracker'

let { refreshGroupsForCategory, refreshSections } = SectionActions
let { refreshEnrollments } = EnrollmentActions
let actions = [refreshEnrollments, refreshGroupsForCategory, refreshSections]

export type AssigneeSearchProps = {
  courseID: string,
  assignmentID: string,
  assignment: Assignment,
  sections: Section[],
  enrollments: Enrollment[],
  groups: Group[],
  onSelection: Function,
  navigator: Navigator,
  refreshSections: Function,
  refreshEnrollments: Function,
  refreshGroupsForCategory: Function,
  pending: boolean,
}

function studentEnrollmentsForCourseID (courseID: string, state: AppState): any {
  return Object.values(state.entities.enrollments).filter((item) => {
    // $FlowFixMe
    if (item.course_id !== courseID) return false
    // $FlowFixMe
    if (item.type !== 'StudentEnrollment') return false
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

  const assignment = state.entities.assignments[ownProps.assignmentID].data
  const groups = Object.values(state.entities.groups).filter((groupState) => {
    // $FlowFixMe
    if (!groupState.group) return false
    return groupState.group.group_category_id === assignment.group_category_id
    // $FlowFixMe
  }).map((groupState) => groupState.group)

  return {
    sections,
    enrollments,
    assignment,
    groups,
    pending: asyncChecker(state, actions),
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
  assignmentID: string,
  assignees: Assignee[],
  navigator: Navigator,
  callback?: Function, // Called when finished picking assignees. Will send the new list of assignees as the first parameter
  refreshSections: Function,
  refreshUsers: Function,
  refreshGroup: Function,
}

export function pickerMapStateToProps (state: AppState, ownProps: AssigneePickerProps): any {
  let assignees = ownProps.assignees

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
        const user = state.entities.users[assignee.dataId]
        if (user && user.data) {
          newAssignee.name = user.data.name
          newAssignee.imageURL = user.data.avatar_url
        }
        break
      case 'section':
        const section = state.entities.sections[assignee.dataId]
        if (section) {
          newAssignee.name = section.name
        }
        break
      case 'group':
        const groupState = state.entities.groups[assignee.dataId]
        if (groupState) {
          newAssignee.name = groupState.group.name
        }
        break
    }

    return newAssignee
  })

  return { assignees }
}
