module Rex
  module Java
    module Serialization
      module Model
        # This class provides a field description representation (fieldDesc). It's used for
        # both primitive descriptions (primitiveDesc) and object descriptions (objectDesc).
        class Field < Element

          PRIMITIVE_TYPE_CODES = {
            'B' => 'byte',
            'C' => 'char',
            'D' => 'double',
            'F' => 'float',
            'I' => 'integer',
            'J' => 'long',
            'S' => 'short',
            'Z' => 'boolean',
          }

          OBJECT_TYPE_CODES = {
            '[' => 'array',
            'L' => 'object'
          }

          TYPE_CODES = PRIMITIVE_TYPE_CODES.merge(OBJECT_TYPE_CODES)

          # @!attribute type
          #   @return [String] The type of the field.
          attr_accessor :type
          # @!attribute name
          #   @return [Java::Serialization::Model::Utf] The name of the field.
          attr_accessor :name
          # @!attribute field_type
          #   @return [Java::Serialization::Model::Utf] The type of the field on object types.
          attr_accessor :field_type

          # Unserializes a Java::Serialization::Field
          #
          # @param io [IO] the io to read from
          # @return [Java::Serialization::Model::Field] if deserialization is possible
          # @return [nil] if deserialization isn't possible
          def self.decode(io)
            elem = self.new

            elem.decode(io)
          end

          def initialize
            self.type = ''
            self.name = nil
            self.field_type = nil
          end

          # Unserializes a Java::Serialization::Model::Field
          #
          # @param io [IO] the io to read from
          # @return [self] if deserialization is possible
          # @return [nil] if deserialization isn't possible
          def decode(io)
            code = io.read(1)
            return nil unless code && is_valid?(code)
            self.type = TYPE_CODES[code]

            self.name = Utf.decode(io)
            return nil if name.nil?

            if is_object?
              self.field_type = decode_field_type(io)
              return nil if field_type.nil?
            end

            self
          end

          # Serializes the Java::Serialization::Model::Field
          #
          # @return [String] if serialization is possible
          # @return [nil] if serialization isn't possible
          def encode
            unless is_type_valid?
              return nil
            end

            encoded = ''
            encoded << TYPE_CODES.key(type)
            encoded << name.encode

            if is_object?
              encoded << encode_field_type
            end

            encoded
          end

          # Whether the field type is valid.
          #
          # @return [Boolean]
          def is_type_valid?
            if TYPE_CODES.values.include?(type)
              return true
            end

            false
          end

          # Whether the field type is a primitive one.
          #
          # @return [Boolean]
          def is_primitive?
            if PRIMITIVE_TYPE_CODES.values.include?(type)
              return true
            end

            false
          end

          # Whether the field type is an object one.
          #
          # @return [Boolean]
          def is_object?
            if OBJECT_TYPE_CODES.values.include?(type)
              return true
            end

            false
          end

          private

          # Whether the type opcode is a valid one.
          #
          # @param code [String] A type opcode
          # @return [Boolean]
          def is_valid?(code)
            if TYPE_CODES.keys.include?(code)
              return true
            end

            false
          end

          # Serializes the `field_type` attribute.
          #
          # @return [String]
          def encode_field_type
            encoded = [Java::Serialization::TC_STRING].pack('C')
            encoded << field_type.encode

            encoded
          end

          # Unserializes the `field_type` value.
          #
          # @param io [IO] the io to read from
          # @return [Java::Serialization::Model::Utf]
          def decode_field_type(io)
            opcode = io.read(1)
            return nil unless opcode && opcode == [Java::Serialization::TC_STRING].pack('C')
            type = Utf.decode(io)

            type
          end
        end
      end
    end
  end
end