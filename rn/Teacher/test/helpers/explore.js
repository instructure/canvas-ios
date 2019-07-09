//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* @flow */

import { flatMap } from 'lodash'

function query (node: any, match: (any) => boolean): any[] {
  let result = []
  let notProcessed = [node]

  while (notProcessed.length) {
    result = [...result, ...notProcessed.filter(match)]
    notProcessed = flatMap(notProcessed, ({ children }) => children || [])
  }

  return result
}

class ComponentExplorer {
  component: any

  constructor (component: any) {
    this.component = component
  }

  selectByProp (propKey: string, value: any): Array<any> {
    return query(this.component, (item) => {
      return item.props && item.props[propKey] === value
    })
  }

  selectByID (id: string): ?any {
    const results = this.selectByProp('testID', id)
    return results.length > 0 ? results[0] : null
  }

  selectByType (type: string): any {
    return this.query(node => node.type === type)[0]
  }

  query (match: (any) => boolean): Array<any> {
    return query(this.component, match)
  }

  selectRightBarButton (id: string): ?any {
    return this._selectBarButton('right', id)
  }

  selectLeftBarButton (id: string): ?any {
    return this._selectBarButton('left', id)
  }

  _selectBarButton (side: string, id: string): ?any {
    const prop = side === 'right' ? 'rightBarButtons' : 'leftBarButtons'
    const buttons = this.query(({ type }) => type === 'Screen')[0].props[prop]
    if (!buttons) return null
    return buttons.find(({ testID }) => testID === id)
  }
}

export default function explore (component: any): ComponentExplorer {
  return new ComponentExplorer(component)
}
