export default function template<T> (defaults: any): (overrides: any) => T {
  return (overrides) => {
    return {
      ...defaults,
      ...overrides,
    }
  }
}
