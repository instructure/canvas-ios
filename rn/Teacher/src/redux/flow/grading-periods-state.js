// @flow

export type GradingPeriodsState = {
  [string]: {
    gradingPeriod: GradingPeriod,
    assignmentRefs: Array<string>,
  },
}
