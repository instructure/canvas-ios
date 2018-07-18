// @flow

import { featureFlagEnabled } from './feature-flags'

// Checks if quiz is anonymous according to the api
export function isQuizAnonymous (appState: AppState, quizID: string) {
  const quiz = appState.entities.quizzes[quizID]
  return Boolean(quiz && quiz.data && quiz.data.anonymous_submissions)
}

// Checks if assignment is anonymous according to the api
export function isAssignmentAnonymous (appState: AppState, courseID: string, assignmentID: string) {
  const { entities } = appState
  const { assignments, courses } = entities
  const assignment = assignments[assignmentID]
  if (assignment && assignment.data) {
    // Quizzes have their own flag
    if (assignment.data.quiz_id) {
      return isQuizAnonymous(appState, assignment.data.quiz_id)
    }

    if (featureFlagEnabled('assignmentLevelAnonymousGrading')) {
      // Check at assignment level
      return Boolean(assignment.data.anonymize_students)
    } else {
      // TODO: Remove this with assignmentLevelAnonymousGrading feature flag
      // Checks course level setting (DEPRECATED)
      let course = courses[courseID]
      if (course) {
        return course.enabledFeatures.includes('anonymous_marking')
      }
    }
  }

  return false
}
