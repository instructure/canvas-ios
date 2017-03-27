// @flow

export type AssignmentGroupState = {
  +group: AssignmentGroup,
}

export type AssignmentGroupsState = {
  [assignmentGroupID: string]: AssignmentGroupState,
}
