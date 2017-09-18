class Searching
  ENHANCED_FIELDS = %w(
    document_collections
    specialist_sectors
    policies
    taxons
    mainstream_browse_pages
  ).freeze
  HEAD_FIELDS = %w(
    popularity
    is_historic
  ).freeze
  SECONDARY_HEAD_FIELDS = %w(
    people
    organisations
  ).freeze
  OTHER_FIELDS = %w(
    description
    format
    link
    public_timestamp
    title
    content_id
  ).freeze

  FIELDS = OTHER_FIELDS + ENHANCED_FIELDS + HEAD_FIELDS + SECONDARY_HEAD_FIELDS
  OPTION_FIELDS = ENHANCED_FIELDS + HEAD_FIELDS + SECONDARY_HEAD_FIELDS + %w(content_id).freeze

  HOSTS = {
    "production" => "http://rummager.dev.gov.uk",
    "staging" => "https://www-origin.staging.publishing.service.gov.uk"
  }.freeze

  require 'gds_api/rummager'
  attr_reader :params
  def initialize(params)
    @params = params
  end

  def count
    return 10 if params["count"].blank? || params["count"].to_i.negative?
    return 100 if params["count"].to_i > 100 && [params["host-a"], params["host-b"]].include?("staging")
    return 1000 if params["count"].to_i > 1000
    params["count"]
  end

  def call
    rummager_a = GdsApi::Rummager.new(HOSTS[params["host-a"]])
    rummager_b = GdsApi::Rummager.new(HOSTS[params["host-b"]])

    findings_new_left = rummager_a.search(
      q: params["search_term"],
      fields: FIELDS,
      count: count.to_s,
      ab_tests: "#{params['which_test']}:A",
      c: Time.now.getutc.to_s
      )
    findings_new_right = rummager_b.search(
      q: params["search_term"],
      fields: FIELDS,
      count: count.to_s,
      ab_tests: "#{params['which_test']}:B",
      c: Time.now.getutc.to_s
      )
    Results.new(findings_new_left, findings_new_right)
  end
end
