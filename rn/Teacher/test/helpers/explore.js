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
    return this.query(({ type }) => type === 'Screen')[0].props[prop]
      .find(({ testID }) => testID === id)
  }
}

export default function explore (component: any): ComponentExplorer {
  return new ComponentExplorer(component)
}
