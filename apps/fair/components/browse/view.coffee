_ = require 'underscore'
sd = require('sharify').data
_.mixin require 'underscore.string'
Backbone = require 'backbone'
BoothsView = require '../booths/view.coffee'
FilterArtworksView = require '../../../../components/filter/artworks/view.coffee'
{ ARTSY_URL, SECTION } = require('sharify').data

module.exports = class FairBrowseView extends Backbone.View

  el: '#fair-browse'

  initialize: (options) ->
    _.extend @, options
    @filterArtworksView = new FilterArtworksView
      el: $ '.fair-page-content'
      artworksUrl : "#{ARTSY_URL}/api/v1/search/filtered/fair/#{@fair.get 'id'}"
      countsUrl: "#{ARTSY_URL}/api/v1/search/filtered/fair/#{@fair.get 'id'}/suggest"
      urlRoot: "#{@profile.id}/browse"
    @artworkParams = @filterArtworksView.params
    @counts = @filterArtworksView.counts
    @boothsView = new BoothsView
      el: $ '.fair-page-content'
      fair: @fair
      profile: @profile
      router: @router
    @boothParams = @boothsView.params
    @boothParams.on 'change reset', @boothsSection
    @boothParams.on 'change reset', @updateBoothPageTitle
    @artworkParams.on 'change reset', @artworksSection
    @artworkParams.on 'change reset', @renderArtworksHeader
    @artworkParams.on 'change reset', @updateFilterPageTitle
    @counts.fetch()
    @highlightHome()

  updateFilterPageTitle: =>
    @updatePageTitle "Browse #{@counts.get('total')} Artworks"

  updateBoothPageTitle: =>
    @updatePageTitle(
      if @boothParams.get('section')
        "Exhibitors at #{@boothParams.get('section')}"
      else
        "Browse #{sd.EXHIBITORS_COUNT} Exhibitors"
    )

  updatePageTitle: (context) ->
    return unless SECTION is 'browse'
    document.title = _.compact([
      (if @profile.displayName() then "#{@profile.displayName()}" else "Profile")
      context
      "Artsy"
    ]).join(" | ")

  boothsSection: =>
    @$('.filter-artworks-nav .is-active, #fair-filter-all-artists').removeClass('is-active')
    @$el.attr 'data-section', 'booths'

  artworksSection: =>
    @$('#fair-booths-filter-nav .is-active, #fair-filter-all-artists').removeClass('is-active')
    @$el.attr 'data-section', 'artworks'

  renderArtworksHeader: =>
    @$('#fair-browse-artworks-header').text(
      if @artworkParams.get 'related_gene'
        geneName = _.titleize _.humanize @artworkParams.get('related_gene').replace(/[0-9]/g, '')
      else
        ''
    )

  highlightHome: ->
    return unless SECTION is 'browse'
    $('.garamond-tab:eq(1)')
      .removeClass('is-inactive')
      .addClass('is-active')

  events:
    'click #fair-filter-all-artists' : 'artistsAZ'
    'click #fair-booths-az-as-list'  : 'exhibitorsAZ'
    'click #fair-booths-as-grid'     : 'exhibitorsGrid'
    'click'                          : 'triggerReflow'

  artistsAZ: ->
    @router.navigate "#{@profile.get 'id'}/browse/artists"
    @$('.filter-fixed-header-nav .is-active').removeClass('is-active')
    @$('#fair-filter-all-artists').addClass('is-active')
    @$el.attr 'data-section', 'artists-a-to-z'
    @updatePageTitle 'See A-Z List of All Artists'

  exhibitorsAZ: ->
    @router.navigate "#{@profile.get 'id'}/browse/exhibitors"
    @$('.filter-fixed-header-nav .is-active').removeClass('is-active')
    @$('#fair-filter-all-exhibitors').addClass('is-active')
    @$el.attr 'data-section', 'exhibitors-a-to-z'
    @updatePageTitle 'See A-Z List of All Exhibitors'

  exhibitorsGrid: ->
    @boothParams.trigger 'reset'

  # Safari does not re-render when a data attribute on an element has changed so we manually trigger a reflow
  triggerReflow: =>
    @$el.css display: 'none'
    # no need to store this anywhere, the reference is enough to trigger a reflow
    @$el.offset().height
    @$el.css display: 'block'
