/* @flow */

function hasProp (object: any, key: string, value: any): boolean {
  if (object instanceof Object) {
    const props = object.props
    if (props && props instanceof Object) {
      for (var prop in props) {
        if (prop === key && props[prop] === value) {
          return true
        }
      }
    }
  }

  return false
}

function selectByProp (object: any, propKey: string, value: any): ?any {
  if (!(typeof object === 'object')) {
    return null
  }

  if (hasProp(object, propKey, value)) {
    return object
  }

  let result = null

  for (var key in object) {
    if (object[key] instanceof Array) {
      object[key].forEach((e) => {
        result = selectByProp(e, propKey, value)
        if (result) {
          return result
        }
      })
    }

    result = selectByProp(object[key], propKey, value)
    if (result) {
      return result
    }
  }

  return result
}

class ComponentExplorer {
  component: any

  constructor (component: any) {
    this.component = component
  }

  selectByProp (propKey: string, value: any): ?any {
    return selectByProp(this.component, propKey, value)
  }

  selectByID (id: string): ?any {
    return this.selectByProp('testID', id)
  }
}

export default function explore (component: any): ComponentExplorer {
  return new ComponentExplorer(component)
}
