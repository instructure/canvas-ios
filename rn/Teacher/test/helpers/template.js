export default function template<T> (defaults: any): (any) => T {
  return (overrides) => {
    return {
      ...defaults,
      ...overrides,
    }
  }
}
