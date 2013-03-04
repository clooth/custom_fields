require 'mongoid'

Mongoid.configure do |config|
  name = 'custom_fields_test'
  config.connect_to(name)
end

module Mongoid
  def self.reload_document(doc)
    if doc.embedded?
      parent = doc.class._parent

      parent = parent.class.find(parent._id)

      parent.send(doc.metadata.name).find(doc._id)
    else
      doc.class.find(doc._id)
    end
  end
end