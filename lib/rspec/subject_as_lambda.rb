# frozen_string_literal: true

require "rspec/core"

module RSpec
  #
  # SubjectAsLambda provides a convenient way of turning a regular subject into a proc
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  module SubjectAsLambda
    # Creates a nested example group named by the submitted `attribute`,
    # and then generates an example using the submitted block.
    #
    # @example
    #
    #   # This ...
    #   describe Array do
    #     its(:size) { should eq(0) }
    #   end
    #
    #   # ... generates the same runtime structure as this:
    #   describe Array do
    #     describe "size" do
    #       it "should eq(0)" do
    #         subject.size.should eq(0)
    #       end
    #     end
    #   end
    #
    # The attribute can be a `Symbol` or a `String`. Given a `String`
    # with dots, the result is as though you concatenated that `String`
    # onto the subject in an expression.
    #
    # @example
    #
    #   describe Person do
    #     subject do
    #       Person.new.tap do |person|
    #         person.phone_numbers << "555-1212"
    #       end
    #     end
    #
    #     its("phone_numbers.first") { should eq("555-1212") }
    #   end
    #
    # When the subject is a `Hash`, you can refer to the Hash keys by
    # specifying a `Symbol` or `String` in an array.
    #
    # @example
    #
    #   describe "a configuration Hash" do
    #     subject do
    #       { :max_users => 3,
    #         'admin' => :all_permissions.
    #         'john_doe' => {:permissions => [:read, :write]}}
    #     end
    #
    #     its([:max_users]) { should eq(3) }
    #     its(['admin']) { should eq(:all_permissions) }
    #     its(['john_doe', :permissions]) { should eq([:read, :write]) }
    #
    #     # You can still access its regular methods this way:
    #     its(:keys) { should include(:max_users) }
    #     its(:count) { should eq(2) }
    #   end
    #
    # With an implicit subject, `is_expected` can be used as an alternative
    # to `should` (e.g. for one-liner use). An `are_expected` alias is also
    # supplied.
    #
    # @example
    #
    #   describe Array do
    #     its(:size) { is_expected.to eq(0) }
    #   end
    #
    # You can pass more than one argument on the `its` block to add
    # some metadata to the generated example
    #
    # @example
    #
    #   # This ...
    #   describe Array do
    #     its(:size, :focus) { should eq(0) }
    #   end
    #
    #   # ... generates the same runtime structure as this:
    #   describe Array do
    #     describe "size" do
    #       it "should eq(0)", :focus do
    #         subject.size.should eq(0)
    #       end
    #     end
    #   end
    #
    # Note that this method does not modify `subject` in any way, so if you
    # refer to `subject` in `let` or `before` blocks, you're still
    # referring to the outer subject.
    #
    # @example
    #
    #   describe Person do
    #     subject { Person.new }
    #     before { subject.age = 25 }
    #     its(:age) { should eq(25) }
    #   end
    #
    def it!(*options, &block)
      it_lambda_caller = caller.reject { |file_line| file_line =~ %r{/rspec/subject_as_lambda} }
      describe(nil, caller: it_lambda_caller) do
        let(:__it_lambda_subject) do
          subject
        end

        def is_expected # rubocop:disable Lint/NestedMethodDefinition, Naming/PredicateName
          expect { __it_lambda_subject }
        end
        alias_method :are_expected, :is_expected

        options << {} unless options.last.is_a?(Hash)
        options.last[:caller] = it_lambda_caller

        example(nil, *options, &block)
      end
    end

    alias specify! it!
  end
end

RSpec.configure do |rspec|
  rspec.extend RSpec::SubjectAsLambda
  rspec.backtrace_exclusion_patterns << %r{/lib/rspec/subject_as_lambda}
end

RSpec::SharedContext.send(:include, RSpec::SubjectAsLambda)
