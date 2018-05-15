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
import { statusProp, gradeProp } from '../../submissions/list/get-submissions-props'

const groupPropsForSubmissionsAndDueDate = (submissionsByGroupID: { [string]: SubmissionWithHistory }, dueDate: ?string) => (group: Group) => {
  const submission = submissionsByGroupID[group.id]
  return {
    // just a precaution... we're filtering out empty groups below
    userID: group.users && group.users.length > 0 ? group.users[0].id : 'none',
    groupID: group.id,
    name: group.name,
    status: statusProp(submission, dueDate),
    grade: gradeProp(submission),
    score: submission ? submission.score : null,
    submissionID: submission ? submission.id : null,
    submission,
    sectionID: null,
    allSectionIDs: null,
  }
}

export function getGroupSubmissionProps (entities: Entities, courseID: string, assignmentID: string) {
  const assignmentState = entities.assignments[assignmentID]
  const courseState = entities.courses[courseID]

  const groupRefs = courseState && courseState.groups
    ? courseState.groups.refs
    : []

  let groupCategoryID: ?string = null
  let dueDate: ?string = null
  if (assignmentState && assignmentState.data) {
    groupCategoryID = assignmentState.data.group_category_id
    dueDate = assignmentState.data.due_at
  }

  const gradedGroups = groupCategoryID
    ? groupRefs.map(ref => entities.groups[ref].group)
      .filter(group => group.users && group.users.length > 0 && group.group_category_id === groupCategoryID)
    : []

  const submissionRefs = assignmentState && assignmentState.submissions
    ? assignmentState.submissions.refs
    : []

  const submissionsByGroupID = submissionRefs
    .map(ref => entities.submissions[ref].submission)
    .reduce((byGroupID, submission) => (
      submission.group && submission.group.id
        ? { ...byGroupID, [submission.group.id]: submission }
        : byGroupID
    ), {})

  const submissions = gradedGroups.map(
    groupPropsForSubmissionsAndDueDate(submissionsByGroupID, dueDate)
  )

  const pending = courseState.groups.pending > 0 || assignmentState.submissions.pending > 0

  return {
    pending,
    submissions,
  }
}
