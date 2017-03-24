// @flow

export type StateProps = {
  course: Course,
  color: string,
}

export default function stateToProps (state: any, ownProps: {courseID: string}): StateProps {
  return state.entities.courses[ownProps.courseID]
}
