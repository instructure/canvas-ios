// @flow

import { createAction } from 'redux-actions'

import * as api from './api'

import type { LegoSetsActionProps } from './props'

export let LegoActions = (api) => ({
  buyLegoSet: createAction('legos.buyMoar', api.buyLegoSet),
  sellAllLegos: createAction('legos.sellAll', api.sellAllLegos),
}: LegoSetsActionProps)

export default LegoActions(api)
