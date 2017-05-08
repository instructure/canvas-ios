/* @flow */

export type Quiz = {
  id: string,
  title: string,
  html_url: string,
  description: string,
  due_at: ?string,
  lock_at: ?string,
  points_possible: ?number,
  question_count: number,
  published: boolean,
  quiz_type: 'practice_quiz' | 'assignment' | 'graded_survey' | 'survey',
}
