//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
