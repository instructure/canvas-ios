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

  query (match: (any) => boolean): Array<any> {
    return query(this.component, match)
  }
}

export default function explore (component: any): ComponentExplorer {
  return new ComponentExplorer(component)
}
