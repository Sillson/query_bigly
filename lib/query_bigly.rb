require "google/cloud/bigquery"
require "query_bigly/version"
require "query_bigly/format_helpers"
require "query_bigly/client"
require "query_bigly/stream_model"
require "query_bigly/bulk_insert_model"
require "query_bigly/loader"

module QueryBigly
  PROJECT_ID      = ENV.fetch('PROJECT_ID', 'Needs to be set').freeze
  KEYFILE         = ENV.fetch("KEYFILE", 'Needs to be set').freeze
  DEFAULT_DATASET = ENV.fetch("DEFAULT_DATASET", 'Needs to be set').freeze

  def self.project_id
    @project_id = PROJECT_ID
  end

  def self.keyfile
    @keyfile = KEYFILE
  end

  def self.default_dataset
    @default_dataset = DEFAULT_DATASET
  end
end
