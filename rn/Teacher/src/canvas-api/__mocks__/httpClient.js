let client = {
  get: jest.fn(() => Promise.resolve()),
  post: jest.fn(() => Promise.resolve()),
}

export default () => client
