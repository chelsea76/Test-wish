loadingHTML = "<div class='loading'>Loading...</div>"
errorHTML = "<div class='loading'>D'oh, we couldn't find that.</div>"
namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

class myWish

  openURLInPanel: (urlOrPath) ->
    window.location.hash = "#!#{urlOrPath}"
    $('.secondary-content').html loadingHTML
    $('.secondary-content').addClass 'sliding-in'
    $.ajax(urlOrPath).success((data) ->
      $('.whiteout').show()
      $('.secondary-content').html data.responseText
    ).error((data) ->
      $('.whiteout').show()
      $('.secondary-content').html errorHTML
    ).complete((data) ->
      $('.whiteout').show()
      $('.secondary-content').html data.responseText
    )

  hidePanel: ->
    window.location.hash = ''
    $('.secondary-content').html loadingHTML
    $('.whiteout').hide()
    $('.secondary-content').removeClass 'sliding-in'

  showPost: ->
    $('.url > a,a[data-secondary]').click (e) ->
      e.preventDefault()
      Wish.wish.openURLInPanel $(this).attr('href')
    $('.view-discussion > a,a[data-secondary]').click (e) ->
      e.preventDefault()
      Wish.wish.openURLInPanel $(this).attr('href')

  textInputCharsLeft: (ele) ->
    $(ele).keyup ->
      value = $(this).val()
      maxlength = $(this).data('maxlength')
      compare = maxlength - (value.length)
      if compare >= 0
        compare = '<span style="color:red">*</span>' + compare
        $('#inputcounter').html compare + 'characters left'
      return

  shareWishOnTwitter: ->
    $('span a.tweet_wish').click (e) ->
      e.preventDefault()
      loc = $(this).attr('href')
      title = encodeURIComponent($(this).data('title'))
      window.open 'http://twitter.com/share?url=' + loc + '&text=' + title + '&', 'twitterwindow', 'height=250, width=550, top=' + $(window).height() / 2 - 225 + ', left=' + $(window).width() / 2 + ', toolbar=0, location=0, menubar=0, directories=0, scrollbars=0'
      return

namespace "Wish", (exports) ->
  exports.wish = new myWish

$ ->
  myWish = new myWish
  myWish.showPost()
  $('.secondary-content').html loadingHTML

  $('ul.profile_tab li a').click ->
    url = $(this).data('href');
    $('ul.profile_tab li a').removeClass('active')
    $(this).addClass('active')
    $.ajax(url).success((data) ->
      $('#tab_content').html data
      myWish.showPost()
    )
    return false;

  if document.location.hash.substr(0,2) == '#!'
    myWish.openURLInPanel document.location.hash.substr(2)

  $('.whiteout').click myWish.hidePanel
