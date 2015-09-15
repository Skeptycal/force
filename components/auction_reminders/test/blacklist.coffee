sinon = require 'sinon'
blacklist = require '../blacklist'

urls =
  good: [
    '/show/cool-show'
    '/artwork/cool-artwork'
    '/auctions'
    '/sales'
    '/terms'
    '/'
    '/user/cool-user'
  ]

  bad: [
    '/auction/some-auction'
    '/personalize'
    '/personalize/categories'
    '/user/edit'
    '/sale/cool-sale'
  ]

describe 'blacklist', ->
  afterEach ->
    delete global['location']

  it 'blacklists routes that are forbidden', ->
    allTrue = urls.bad.map (pathname) ->
      global['location'] = pathname: pathname
      [pathname, blacklist.check()]

    allTrue.should.eql [
      ['/auction/some-auction', true]
      ['/personalize', true]
      ['/personalize/categories', true]
      ['/user/edit', true]
      ['/sale/cool-sale', true]
    ]

  it 'does not blacklist routes that are ok', ->
    allFalse = urls.good.map (pathname) ->
      global['location'] = pathname: pathname
      [pathname, blacklist.check()]

    allFalse.should.eql [
      ['/show/cool-show', false]
      ['/artwork/cool-artwork', false]
      ['/auctions', false]
      ['/sales', false]
      ['/terms', false]
      ['/', false]
      ['/user/cool-user', false]
    ]
