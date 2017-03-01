// @flow

export type ActionFiguresProps = {
  +actionFigures: ActionFigure[],
}

export interface AppState {
  toys: { actionFigures: ActionFigure[] },
}

export function stateToProps (state: AppState): ActionFiguresProps {
  const actionFigures: ActionFigure[] = state.toys.actionFigures
  return { actionFigures }
}
