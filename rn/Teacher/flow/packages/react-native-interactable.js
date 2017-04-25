// @flow
import React from 'react'

export type SnapToOptions = {
  index: number,
}

export type InteractableView = React.Element<*> & {
  snapTo: (SnapToOptions) => void,
}
