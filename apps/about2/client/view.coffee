_ = require 'underscore'
Backbone = require 'backbone'
imagesLoaded = require 'imagesloaded'

module.exports = class AboutView extends Backbone.View
  events:
    'click .about2-nav-link': 'intercept'

  initialize: ->
    @$window = $(window)
    @$window.on 'keyup', @toggleGrid
    @setupHeroUnits()
    @setupTracks()
    @setupStickyNav()
    @setupSectionNavHighlighting()

  intercept: (e) ->
    e.preventDefault()
    Backbone.history.navigate $(e.currentTarget).attr('href'), trigger: true

  setupStickyNav: ->
    (@$nav = @$('.about2-section-nav'))
      .waypoint 'sticky'

  setupSectionNavHighlighting: ->
    $nav = @$nav
    $sections = @$sections = @$('.about2-section')
    activateNavLink = (el) ->
      $sections.removeClass 'is-active'
      $section = $(el).addClass 'is-active'
      $nav.find('a').removeClass 'is-active'
      href = $section.data('href')
      Backbone.history.navigate href, trigger: false, replace: true
      $nav.find("a[href='#{href}']").addClass 'is-active'
    @$sections
      .waypoint((direction) ->
        activateNavLink(this) if direction is 'down'
      ).waypoint (direction) ->
        activateNavLink(this) if direction is 'up'
      , offset: -> -$(this).height()

  setupHeroUnits: ->
    @currentHeroUnit = 0
    @heroUnitPauseInterval = 5000
    @$units = @$('.about2-hero-unit-bg')
    setInterval @stepHeroUnit, @heroUnitPauseInterval
    # Set a waypoint for the very top section
    @$('.a2huc-bottom').waypoint (direction) ->
      Backbone.history.navigate '/about2', trigger: false, replace: true
    , offset: -> -($(this).height() - 1)

  stepHeroUnit: =>
    $(@$units.removeClass('is-active').get @currentHeroUnit).addClass('is-active')
    @currentHeroUnit = if (@currentHeroUnit + 1 < @$units.length) then @currentHeroUnit + 1 else 0

  toggleGrid: (e) =>
    @$('#about2-grid').toggle() if e.which is 71 # "g" key

  setGenomeWorkHeights: =>
    imagesLoaded '#about2-section3-genome-works', =>
      @$('.about2-section3-genome-artwork').each ->
        $(this).parent('li').height $(this).children('img').height()

  setupTracks: ->
    (@$tracks = @$('.about2-section3-genome-artwork-track'))
      .waypoint(@onTrackWaypoint)
      .imagesLoaded =>
        for el, i in @$tracks.toArray()
          next = @$tracks[i + 1]
          continue unless next
          bottom = $(next).offset().top + $(next).height()
          $(el).height bottom - $(el).offset().top

  onTrackWaypoint: (dir) ->
    tracks = $('.about2-section3-genome-artwork-track').toArray()
    for el, i in tracks
      if el is this
        index = i
        break
    if dir is 'down'
      $(this).addClass('is-fixed') unless this is _.last tracks
      $(tracks[i - 1])?.removeClass('is-fixed').addClass('is-docked')
    else if dir is 'up'
      $(this).removeClass('is-fixed is-docked')
      $(tracks[i - 1])?.addClass('is-fixed').removeClass('is-docked')
