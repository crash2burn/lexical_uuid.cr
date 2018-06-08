require "../src/lexical_uuid"

uuid = LexicalUUID::UUID.new
puts uuid.to_guid

from_bytes = LexicalUUID::UUID.new(uuid.to_bytes)
puts from_bytes.to_guid

from_guid = LexicalUUID::UUID.new(uuid.to_guid)
puts from_guid.to_guid
