# frozen_string_literal: true

# :nodoc:
class Class
  # :nodoc:
  def class_attribute(*attrs)
    options       = attrs.extract_options!
    default_value = options.fetch(:default, nil)

    attrs.each do |name|
      singleton_class.silence_redefinition_of_method(name)
      define_singleton_method(name) { nil }

      singleton_class.silence_redefinition_of_method("#{name}?")
      define_singleton_method("#{name}?") { !!public_send(name) }

      ivar = "@#{name}"

      singleton_class.silence_redefinition_of_method("#{name}=")
      define_singleton_method("#{name}=") do |val|
        singleton_class.class_eval do
          redefine_method(name) { val }
        end

        if singleton_class?
          class_eval do
            redefine_method(name) do
              if instance_variable_defined? ivar
                instance_variable_get ivar
              else
                singleton_class.send name
              end
            end
          end
        end
        val
      end

      redefine_method(name) do
        if instance_variable_defined?(ivar)
          instance_variable_get ivar
        else
          self.class.public_send name
        end
      end

      redefine_method("#{name}?") { !!public_send(name) }

      redefine_method("#{name}=") do |val|
        instance_variable_set ivar, val
      end

      unless default_value.nil?
        self.send("#{name}=", default_value)
      end
    end
  end unless method_defined?(:class_attribute)
end
