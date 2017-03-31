// @flow

export type GradingPeriod = {
  id: number,
  title: string,
  start_date: string,
  end_date: string,
  close_date: string,
  weight: number,
}

export type GradingPeriodResponse = {
  grading_periods: Array<GradingPeriod>,
}
