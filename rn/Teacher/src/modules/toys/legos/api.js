/* this obviously won't be in the same module when we actually do API stuff */

export function buyLegoSet (legoSet: LegoSet): Promise<LegoSet> {
  return new Promise((resolve, reject) => {
    let action = () => {
      if (Math.random() < 0.3) {
        reject()
      } else {
        resolve(legoSet)
      }
    }
    setTimeout(action, 1000)
  })
}

export function sellAllLegos (): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, 1000))
}
