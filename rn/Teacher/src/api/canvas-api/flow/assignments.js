// @flow

export type AssignmentGroup = {
  id: number,
  name: string,
  position: number,
  group_weight: number,
  sis_source_id: string,
  integration_data: any,
  assignments: Assignment[],
  rules?: any,
}

export type Assignment = {
  id: string,
  name: string,
  description: string,
  created_at: string,
  updated_at: string,
  due_at: string,
  lock_at?: string,
  unlock_at?: string,
  has_overrides: boolean,
  course_id: number,
  published: true,
  unpublishable: false,
  points_possible: number,
  needs_grading_count: number,
  submission_types: string[],
}
