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
import gql from 'graphql-tag'

export default gql`query StudentContextCard($courseID: ID!, $userID: ID!, $limit: Int) {
  course: legacyNode(type: Course, _id: $courseID) {
    ... on Course {
      id: _id
      name
      permissions {
        becomeUser
        manageGrades
        sendMessages
        viewAllGrades
        viewAnalytics
      }
      users: usersConnection(userIds: [$userID]) {
        edges {
          user: node {
            id: _id
            name
            short_name: shortName
            avatar_url: avatarUrl
            enrollments(courseId: $courseID) {
              last_activity_at: lastActivityAt
              type
              section {
                name
              }
              grades {
                current_grade: currentGrade
                current_score: currentScore
              }
            }
            analytics: summaryAnalytics(courseId: $courseID) {
              pageViews {
                total
                max
                level
              }
              participations {
                total
                max
                level
              }
              tardinessBreakdown {
                late
                missing
                onTime
              }
            }
          }
        }
      }
      submissions: submissionsConnection(
        orderBy: [{field: gradedAt, direction: descending}]
        studentIds: [$userID]
        first: $limit
      ) {
        edges {
          submission: node {
            id
            score
            grade
            excused
            submission_status: submissionStatus
            grading_status: gradingStatus
            user {
              id: _id
            }
            assignment {
              id: _id
              name
              html_url: htmlUrl
              points_possible: pointsPossible
              state
            }
          }
        }
        pageInfo {
          hasNextPage
        }
      }
    }
  }
}`
