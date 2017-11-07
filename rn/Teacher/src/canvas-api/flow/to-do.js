// @flow

export type ToDoItem = {
  type: 'grading' | 'submitting',
  assignment?: Assignment,
  quiz?: Quiz,
  ignore: string,
  ignore_permanently: string,
  html_url: string,
  needs_grading_count?: number,
  context_type: 'course' | 'group',
  course_id: ?string,
  group_id: ?string,
}
