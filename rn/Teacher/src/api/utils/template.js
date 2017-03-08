// @flow

export default function template<T> (defaults: any): Template<T> {
  return (overrides) => {
    return {
      ...defaults,
      ...overrides,
    }
  }
}
