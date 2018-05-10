//= require_self
//= require_tree .

(() => {

  class App extends EventEmitter {
    constructor() {
      super()
      this.pages = {}
    }

    visit(url) {
      if (window.Turbolinks) {
        Turbolinks.visit(url)
      } else {
        location.href = url
      }
    }

    refresh() {
      if (window.Turbolinks) {
        this.visit(document.location.href)
      } else {
        location.reload()
      }
    }
  }

  var app = window.app = new App

  if (window.Turbolinks) {
    document.addEventListener('turbolinks:load', function() {
      app.emit('render', $('body'))
    })
  } else {
    $(() => {
      app.emit('render', $('body'))
    })
  }
  if (Rails.ajax) {
    var oldAjax = Rails.ajax
    Rails.ajax = (options) => {
      if (options.dataType === 'script') {
        var oldComplete = () => {}
        if ('complete' in options) {
          oldComplete = options.complete
        }
        options.complete = (xhr) => {
          oldComplete.call(options, xhr)
          setTimeout(function() {
            app.emit('render', $('body'))
          })
        }
      }
      oldAjax.call(Rails, options)
    }
    $.rails = Rails
  }

})()
