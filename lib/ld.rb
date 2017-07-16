require "ld/version"

module Ld
  def self.get_ip request
    request.env['HTTP_X_FORWARDED_FOR'].present? ? request.env['HTTP_X_FORWARDED_FOR'] : request.remote_ip
  end
end

require "ld/file/file"
require "ld/file/dir"
require "ld/file/files"

require "ld/project/project"
require "ld/project/routes"
require "ld/project/tables"
require "ld/project/models"
require "ld/project/controllers"
require "ld/project/views"

require "ld/excel/excel"
require "ld/excel/sheet"

require "ld/print/print"

require "ld/document/document"




