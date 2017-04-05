// @flow

type HydrateAction = {
  type: string,
  payload: ?Payload,
}

type Payload = {
  expires: Date,
  state: AppState,
}

export const HYDRATE_ACTION: string = 'teacher.hydrate'

export default (state?: Payload): HydrateAction => ({ type: HYDRATE_ACTION, payload: state })
