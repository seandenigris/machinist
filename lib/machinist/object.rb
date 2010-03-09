require 'machinist'
require 'machinist/blueprints'

module Machinist
  
  module ObjectExtensions
    def self.included(base)
      base.extend(ClassMethods)
    end
  
    module ClassMethods
      def make(*args, &block)
        arguments_for_new = Arguments.new(*args).extract_arguments_for_new!
        lathe = Lathe.run(Machinist::ObjectAdapter, new_object(arguments_for_new), *args)
        lathe.object(&block)
      end

    private
      class Arguments
        def initialize(*args)
          @arguments = args
        end

        def extract_arguments_for_new!
          if attributes && attributes_contain_arguments_for_new?
            attributes.delete(:new) || attributes.delete("new")
          end
        end

      private
        def attributes
          @attributes ||= @arguments.detect { |arg| arg.class == Hash }
        end

        def attributes_contain_arguments_for_new?
          attributes.has_key?("new") || attributes.has_key?(:new)
        end
      end

      def new_object(arguments_for_new)
        if arguments_for_new
          object = self.new(*arguments_for_new)
        else
          object = self.new
        end
      end
    end
  end

  class ObjectAdapter
    def self.has_association?(object, attribute)
      false
    end
  end

end

class Object
  include Machinist::Blueprints
  include Machinist::ObjectExtensions
end