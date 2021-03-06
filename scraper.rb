#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'
require 'wikidata_ids_decorator'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class MembersPage < Scraped::HTML
  decorator WikidataIdsDecorator::Links

  field :members do
    noko.xpath('//h3[span[@id="Current"]]/following-sibling::ul[1]/li').map do |li|
      fragment(li => MemberRow).to_h
    end
  end
end

class MemberRow < Scraped::HTML
  field :id do
    noko.css('a/@wikidata').map(&:text).first
  end

  field :name do
    noko.at_css('a').text.tidy
  end

  field :honorific_prefix do
    'Cardinal'
  end

  field :wikiname do
    noko.at_xpath('.//a[not(@class="new")][1]/@title').text
  end

  field :party_id do
    '_ind'
  end

  field :party do
    'n/a'
  end

  field :term do
    2016
  end
end

url = 'https://en.wikipedia.org/wiki/Pontifical_Commission_for_Vatican_City_State'
Scraped::Scraper.new(url => MembersPage).store(:members, index: %i[name term])
