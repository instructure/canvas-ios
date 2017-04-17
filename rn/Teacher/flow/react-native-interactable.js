// @flow
import React from 'react'

export type snapToOptions = {
  index: number,
}

export type InteractableView = React.Element<*> & {
  snapTo: (snapToOptions) => void,
}
