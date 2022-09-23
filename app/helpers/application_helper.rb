# frozen_string_literal: true

module ApplicationHelper
  require 'open-uri'
  require 'base64'

  def embed_remote_image(url, content_type)
    base64_image = File.open(url, 'rb') do |file|
      Base64.strict_encode64(file.read)
    end
    "data:#{content_type};base64,#{Rack::Utils.escape(base64_image)}"
  end

  def active_storage_to_base64_image(image)
    require 'base64'
    file = File.open(ActiveStorage::Blob.service.path_for(image.processed.key))
    base64 = Base64.encode64(file.read).gsub(/\s+/, '')
    file.close
    "data:image/jpeg;base64,#{Rack::Utils.escape(base64)}"
  end
end
