// Post message when Quizzes Next 'Return' button is pressed.
var checkQuizzesNext = setInterval(function() {
  var buttons = document.querySelectorAll('header a[data-automation="sdk-return-button"]')
  if (buttons.length) {
    clearInterval(checkQuizzesNext)
  }
  buttons.forEach(a => {
     a.onclick = function (e) {
         e.preventDefault()
         window.webkit.messageHandlers.dismiss.postMessage(true)
     }
  })
}, 100)
