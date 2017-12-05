require 'dotenv/load'
require "google/cloud/bigquery"

require "query_bigly/version"
require "query_bigly/helpers"
require "query_bigly/client"
require "query_bigly/stream_model"

module QueryBigly
  PROJECT_ID = ENV.fetch('PROJECT_ID', 'Needs to be set').freeze
  KEYFILE    = ENV.fetch("KEYFILE", 'Needs to be set').freeze

  def self.project_id
    @project_id = PROJECT_ID
  end

  def self.keyfile
    @keyfile = KEYFILE
  end
end
