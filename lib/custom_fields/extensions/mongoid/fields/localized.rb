# encoding: utf-8
module Mongoid #:nodoc:
  module Fields #:nodoc:
    # module Internal #:nodoc:

      # Defines the behaviour for localized string fields.
      class Localized

        attr_accessor :original_field_type

        def self.included(base)
          base.class_eval do
            alias_method :instantiate_without_localize, :instantiate
            alias_method :instantiate, :instantiate_with_localize
          end
        end

        def instantiate_with_localize(name, options = {})
          instantiate_without_localize(name, options).tap do |field|
            field.original_field_type = Mappings.for(options[:type], options[:identity]).instantiate(name, options)
          end
        end

        # Deserialize the object based on the current locale. Will look in the
        # hash for the current locale.
        #
        # @example Get the deserialized value.
        #   field.demongoize({ "en" => "testing" })
        #
        # @param [ Hash ] object The hash of translations.
        #
        # @return [ String ] The value for the current locale.
        #
        # @since 2.3.0
        def demongoize(object)
          return nil if object.nil?
          value = if !object.respond_to?(:keys) # if no translation hash is given, we return the object itself
            object
          elsif I18n.fallbacks?
            object[I18n.fallbacks[locale.to_sym].map(&:to_s).find { |loc| !object[loc].nil? }]
          else
            object[locale.to_s]
          end
          self.type.demongoize(value)
        end

        # Convert the provided string into a hash for the locale.
        #
        # @example Serialize the value.
        #   field.mongoize("testing")
        #
        # @param [ String ] object The string to convert.
        #
        # @return [ Hash ] The locale with string translation.
        #
        # @since 2.3.0
        def mongoize(object)
          value = self.type.mongoize(object)
          { locale.to_s => value }
        end

        protected

        def locale
          I18n.locale
        end

      end
    # end
  end
end
