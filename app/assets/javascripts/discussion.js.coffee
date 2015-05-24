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
      Wish.wish.upvoteWish()
    ).error((data) ->
      $('.whiteout').show()
      $('.secondary-content').html errorHTML
    ).complete((data) ->
      $('.whiteout').show()
      $('.secondary-content').html data.responseText
      Wish.wish.upvoteWish()
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

  upvoteWish: ->
    $('.upvote_link').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      url = this.href
      voted = $(this).attr('data-voted')
      post_id = $(this).data('post-id')
      url = url + '?voted=' + voted
      upvote_icon = '.upvote_icon_' + post_id
      upvote_count = '.upvote_count_' + post_id
      $.ajax(url: url, method: 'Post').success((data) ->
        if data.voted
          $(upvote_count).css('color', 'green')
          $(upvote_icon).css('color', 'green')
        else
          $(upvote_count).css('color', 'grey')
          $(upvote_icon).css('color', 'grey')

        $(upvote_count).text(data.vote_count)
        $('.upvote_count_slide').text(data.vote_count)
        $('#upvote_'+ post_id).attr('data-voted', data.voted)
      )

namespace "Wish", (exports) ->
  exports.wish = new myWish

$ ->
  myWish = new myWish
  myWish.showPost()
  myWish.upvoteWish()
  $('.secondary-content').html loadingHTML

  $('ul.profile_tab li a').click ->
    url = $(this).data('href');
    $('ul.profile_tab li a').removeClass('active')
    $(this).addClass('active')
    $.ajax(url).success((data) ->
      $('#tab_content').html data
      myWish.showPost()
      myWish.upvoteWish()
    )
    return false;

  if document.location.hash.substr(0,2) == '#!'
    myWish.openURLInPanel document.location.hash.substr(2)

  $('.whiteout').click myWish.hidePanel
