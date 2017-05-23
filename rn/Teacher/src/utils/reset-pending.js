// @flow

export default function resetPending (obj: ?Object): Object {
  const object = obj || { pending: 0 }

  let newObj = Object.keys(object).reduce((current, key) => {
    if (typeof object[key] === 'object' && !Array.isArray(object[key])) {
      current[key] = resetPending(object[key])
    } else if (key === 'pending') {
      current.pending = 0
    } else {
      current[key] = object[key]
    }
    return current
  }, {})
  return newObj
}
