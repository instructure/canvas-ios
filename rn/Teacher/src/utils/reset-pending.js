// @flow

export default function resetPending (obj: Object): Object {
  if (!obj) return obj

  let newObj = Object.keys(obj).reduce((current, key) => {
    if (typeof obj[key] === 'object' && !Array.isArray(obj[key])) {
      current[key] = resetPending(obj[key])
    } else if (key === 'pending') {
      current.pending = 0
    } else {
      current[key] = obj[key]
    }
    return current
  }, {})
  return newObj
}
