#NOTE: all descriptors defined here are derived from
# https://github.com/google/protobuf/blob/master/src/google/protobuf/compiler/plugin.proto
#
# The protoc binary will pass a CodeGeneratorRequest in binary format to plugins
# via STDIN and expect an encoded CodeGeneratorResponse on STDOUT

module Protobuf
  struct CodeGeneratorRequest
    include Protobuf::Message

    struct FieldDescriptorProto
      include Protobuf::Message

      enum Type
        ## 0 is reserved for errors.
        ## Order is weird for historical reasons.
        TYPE_DOUBLE         = 1
        TYPE_FLOAT          = 2
        TYPE_INT64          = 3   ## Not ZigZag encoded.  Negative numbers
        ## take 10 bytes.  Use TYPE_SINT64 if negative
        ## values are likely.
        TYPE_UINT64         = 4
        TYPE_INT32          = 5   ## Not ZigZag encoded.  Negative numbers
        ## take 10 bytes.  Use TYPE_SINT32 if negative
        ## values are likely.
        TYPE_FIXED64        = 6
        TYPE_FIXED32        = 7
        TYPE_BOOL           = 8
        TYPE_STRING         = 9
        TYPE_GROUP          = 10 ## Tag-delimited aggregate.
        TYPE_MESSAGE        = 11 ## Length-delimited aggregate.

        ## New in version 2.
        TYPE_BYTES          = 12
        TYPE_UINT32         = 13
        TYPE_ENUM           = 14
        TYPE_SFIXED32       = 15
        TYPE_SFIXED64       = 16
        TYPE_SINT32         = 17 ## Uses ZigZag encoding.
        TYPE_SINT64         = 18 ## Uses ZigZag encoding.
      end

      enum Label
        LABEL_OPTIONAL      = 1
        LABEL_REQUIRED      = 2
        LABEL_REPEATED      = 3
      end

      contract do
        optional :name,   :string, 1
        optional :number, :int32,  3
        optional :label,  CodeGeneratorRequest::FieldDescriptorProto::Label,  4

        ## If type_name is set, this need not be set.  If both this and type_name
        ## are set, this must be either TYPE_ENUM or TYPE_MESSAGE.
        optional :type, CodeGeneratorRequest::FieldDescriptorProto::Type, 5

        ## For message and enum types, this is the name of the type.  If the name
        ## starts with a '.', it is fully-qualified.  Otherwise, C++-like scoping
        ## rules are used to find the type (i.e. first the nested types within this
        ## message are searched, then within the parent, on up to the root
        ## namespace).
        optional :type_name, :string, 6

        ## For extensions, this is the name of the type being extended.  It is
        ## resolved in the same manner as type_name.
        optional :extended, :string, 2

        ## For numeric types, contains the original text representation of the value.
        ## For booleans, "true" or "false".
        ## For strings, contains the default text contents (not escaped in any way).
        ## For bytes, contains the C escaped value.  All bytes >= 128 are escaped.
        optional :default_value, :string, 7

        optional :options, FieldOptions, 8
      end
    end

    struct FieldOptions
      include Protobuf::Message

      contract do
        optional :packed, :bool, 2
      end
    end

    struct EnumValueDescriptorProto
      include Protobuf::Message

      contract do
        optional :name,   :string, 1
        optional :number, :int32,  2
        # optional EnumValueOptions options = 3;
      end
    end

    struct EnumDescriptorProto
      include Protobuf::Message

      contract do
        optional :name, :string, 1
        repeated :value, CodeGeneratorRequest::EnumValueDescriptorProto, 2
        # optional :options, EnumOptions, 3
      end
    end

    struct ServiceDescriptorProto
      include Protobuf::Message

      contract do
        optional :name, :string, 1
        repeated :method, MethodDescriptorProto, 2
        optional :options, ServiceOptions, 3
      end
    end

    struct MethodDescriptorProto
      include Protobuf::Message

      contract do
        optional :name, :string, 1
        optional :input_type, :string, 2
        optional :output_type, :string, 3
        optional :options, MethodOptions, 4
        optional :client_streaming, :bool, 5, default: false
        optional :server_streaming, :bool, 6, default: false
      end
    end

    struct ServiceOptions
      include Protobuf::Message

      contract do
        optional :deprecated, :bool, 33, default: false
        repeated :uninterpreted_option, UninterpretedOption, 999
      end
    end

    struct MethodOptions
      include Protobuf::Message
      enum IdempotencyLevel
        IDEMPOTENCYUNKNOWN = 0
        NOSIDEEFFECTS = 1
        IDEMPOTENT = 2
      end

      contract do
        optional :deprecated, :bool, 33, default: false
        optional :idempotency_level, MethodOptions::IdempotencyLevel, 34, default: MethodOptions::IdempotencyLevel::IDEMPOTENCYUNKNOWN
        repeated :uninterpreted_option, UninterpretedOption, 999
      end
    end

    struct UninterpretedOption
      include Protobuf::Message

      struct NamePart
        include Protobuf::Message

        contract do
          required :name_part, :string, 1
          required :is_extension, :bool, 2
        end
      end

      contract do
        repeated :name, UninterpretedOption::NamePart, 2
        optional :identifier_value, :string, 3
        optional :positive_int_value, :uint64, 4
        optional :negative_int_value, :int64, 5
        optional :double_value, :double, 6
        optional :string_value, :bytes, 7
        optional :aggregate_value, :string, 8
      end
    end

    struct DescriptorProto
      include Protobuf::Message

      contract do
        optional :name, :string, 1

        repeated :field,       CodeGeneratorRequest::FieldDescriptorProto, 2
        repeated :extended,    CodeGeneratorRequest::FieldDescriptorProto, 6
        repeated :nested_type, CodeGeneratorRequest::DescriptorProto,      3
        repeated :enum_type,   CodeGeneratorRequest::EnumDescriptorProto,  4
      end
    end


    struct FileDescriptorProto
      include Protobuf::Message

      contract do
        optional :name, :string, 1       # file name, relative to root of source tree
        optional :package, :string, 2    # e.g. "foo", "foo.bar", etc.
        repeated :dependency, :string, 3

        repeated :message_type, CodeGeneratorRequest::DescriptorProto,        4
        repeated :enum_type,    CodeGeneratorRequest::EnumDescriptorProto,    5
        repeated :service,      CodeGeneratorRequest::ServiceDescriptorProto, 6

        optional :syntax, :string, 12    # proto2 or proto3
      end

      def crystal_ns
        to_strip = ENV.fetch("STRIP_FROM_PACKAGE", "")
        unless package.nil?
          stripped = package.not_nil!.gsub(to_strip, "")
          stripped.sub(/^\.*/, "").split(".").reject(&.empty?).map(&.camelcase)
        else
          [] of String
        end
      end
    end

    contract do
      repeated :file_to_generate, :string, 1
      optional :parameter, :string, 2

      repeated :proto_file, CodeGeneratorRequest::FileDescriptorProto, 15

    end
  end

  struct CodeGeneratorResponse
    include Protobuf::Message

    struct File
      include Protobuf::Message

      contract do
        optional :name,    :string, 1
        optional :content, :string, 15
      end
    end

    contract do
      repeated :file, CodeGeneratorResponse::File, 15
    end
  end
end

module Protobuf
  class Generator
    def self.compile(req)
      raise Error.new("no files to generate") if req.proto_file.nil?
      package_map = {} of String => String
      req.proto_file.not_nil!.each do |file|
        if !file.package.nil?
          package_map[file.package.not_nil!] = file.crystal_ns.join("::")
        end
      end
      files = req.proto_file.not_nil!.map do |file|
        generator = new(file, package_map)
        CodeGeneratorResponse::File.new(
          name: File.basename(file.name.not_nil!, ".proto") + ".pb.cr",
          content: generator.compile
        )
      end
      CodeGeneratorResponse.new(file: files)
    end

    @package_name : String?
    @ns : Array(String)

    def initialize(@file : CodeGeneratorRequest::FileDescriptorProto, @package_map : Hash(String, String))
      @ns = ENV.fetch("PROTOBUF_NS", "").split("::").reject(&.empty?).concat(@file.crystal_ns)
      @str = String::Builder.new
      @indentation = 0
    end

    def compile
      String.build do |str|
        @str = str
        package_part = package_name ? "for #{package_name}" : ""
        puts "## Generated from #{@file.name} #{package_part}".strip
        puts "require \"protobuf\""
        puts nil

        unless @file.dependency.nil?
          @file.dependency.not_nil!.each { |dp| puts "require \"./#{File.basename(dp.not_nil!, ".proto") + ".pb.cr"}\"" }
          puts nil
        end

        ns! do
          if enum_type = @file.enum_type
            enum_type.each { |et| enum!(et) }
          end
          if message_type = @file.message_type
            message_type.each { |mt| message!(mt) }
          end
        end
      end
    end

    def enum!(enum_type)
      puts "enum #{enum_type.name}"
      unless enum_type.value.nil?
        indent do
          enum_type.not_nil!.value.not_nil!.each do |ev|
            # Issue 9 - enum constants must start with Capital letter
            puts "#{ev.name.not_nil!.camelcase} = #{ev.number}"
          end
        end
      end
      puts "end"
    end

    def package_name
      @package_name ||= @file.package
    end

    def message!(message_type)
      puts nil

      # guard against recursive structs
      structure = !message_type.field.nil? && message_type.field.not_nil!.any? { |f| f.type_name && f.type_name.not_nil!.split(".").last == message_type.name } ? "class" : "struct"

      puts "#{structure} #{message_type.name}"

      indent do
        puts "include Protobuf::Message"
        message_type.enum_type.not_nil!.each { |et| enum!(et) } unless message_type.enum_type.nil?
        message_type.nested_type.not_nil!.each { |mt| message!(mt) } unless message_type.nested_type.nil?
        puts nil

        # use contract3() macro for proto3, otherwise use contract() macro

        syntax = @file.syntax.nil? ? "proto2" : @file.syntax

        unless message_type.field.nil?
          puts "contract_of \"#{syntax}\" do"
          indent do
            message_type.field.not_nil!.each { |f| field!(f, syntax) } unless message_type.field.nil?
          end
          puts "end"
        end
      end
      puts "end"
    end

    def field!(field, syntax)
      met = case field.label
      when CodeGeneratorRequest::FieldDescriptorProto::Label::LABEL_OPTIONAL
        "optional"
      when CodeGeneratorRequest::FieldDescriptorProto::Label::LABEL_REQUIRED
        "required"
      when CodeGeneratorRequest::FieldDescriptorProto::Label::LABEL_REPEATED
        "repeated"
      end

      type_name = unless field.type_name.nil?
        t = field.type_name.not_nil!
        t = t.gsub(/^\.{0,}#{package_name.not_nil!}\.*/, "") unless package_name.nil?
        to_strip = @package_map.find do |k,v|
          t.match(/\.{0,}#{k}/)
        end
        t = t.gsub(/^\.{0,}#{to_strip[0]}/, "#{to_strip[1]}") if to_strip
        t.gsub(/^\.*/, "").split(".").map(&.camelcase).join("::")
      else
        ":#{field.type.to_s.sub(/^TYPE_/, "").downcase}"
      end

      field_desc = "#{met} :#{field.name.not_nil!.underscore}, #{type_name}, #{field.number}"
      unless field.default_value.nil?
        def_value = field.type == CodeGeneratorRequest::FieldDescriptorProto::Type::TYPE_STRING ?
          "\"#{field.default_value}\"" :
          field.type_name.nil? ?
            field.default_value :
            field.type == CodeGeneratorRequest::FieldDescriptorProto::Type::TYPE_ENUM ?
              "#{type_name}::#{field.default_value.not_nil!.camelcase}" : # enum
              raise Error.new("can't use a default value for non-native / enum types")
        case field.type
        when CodeGeneratorRequest::FieldDescriptorProto::Type::TYPE_DOUBLE
          def_value += "_f64" if def_value
        when CodeGeneratorRequest::FieldDescriptorProto::Type::TYPE_FLOAT
          def_value += "_f32" if def_value
        when CodeGeneratorRequest::FieldDescriptorProto::Type::TYPE_INT64
          def_value += "_i64" if def_value
        when CodeGeneratorRequest::FieldDescriptorProto::Type::TYPE_UINT64
          def_value += "_u64" if def_value
        when CodeGeneratorRequest::FieldDescriptorProto::Type::TYPE_UINT32
          def_value += "_u32" if def_value
        end

        # no default values in proto3

        if syntax == "proto2"
          field_desc += ", default: #{def_value}"
        end
      end
      unless field.options.nil?
        # all repeating fields use packed encoding in V3
        if syntax == "proto2"
          field_desc += ", packed: true" if field.options.not_nil!.packed
        end
      end
      puts field_desc
    end

    def indent
      @indentation += 1
      yield
      @indentation -= 1
    end

    def ns!
      return yield if @ns.empty?
      @ns.each do |ns|
        puts "module #{ns}"
        @indentation += 1
      end
      yield
      @ns.each do |ns|
        puts "end"
        @indentation -= 1
      end
    end

    def puts(text)
      @str.puts "#{"  " * @indentation}#{text}"
    end
  end
end
#     def indent(&blk)
#       @n += 1
#       blk.call
#       @n -= 1
#     end

#     def indent!(n)
#       @n = n
#     end

#     def define!(mt)
#       puts
#       puts "class #{mt.name}"

#       indent do
#         puts "include Beefcake::Message"

#         ## Enum Types
#         Array(mt.enum_type).each do |et|
#           enum!(et)
#         end

#         ## Nested Types
#         Array(mt.nested_type).each do |nt|
#           define!(nt)
#         end
#       end
#       puts "end"
#     end

#     def message!(pkg, mt)
#       puts
#       puts "class #{mt.name}"

#       indent do
#         ## Generate Types
#         Array(mt.nested_type).each do |nt|
#           message!(pkg, nt)
#         end

#         ## Generate Fields
#         Array(mt.field).each do |f|
#           field!(pkg, f)
#         end
#       end

#       puts "end"
#     end

#     def enum!(et)
#       puts
#       puts "module #{et.name}"
#       indent do
#         et.value.each do |v|
#           puts "%s = %d" % [v.name, v.number]
#         end
#       end
#       puts "end"
#     end

#     def field!(pkg, f)
#       # Turn the label into Ruby
#       label = name_for(f, L, f.label)

#       # Turn the name into a Ruby
#       name = ":#{f.name}"

#       # Determine the type-name and convert to Ruby
#       type = if f.type_name
#         # We have a type_name so we will use it after converting to a
#         # Ruby friendly version
#         t = f.type_name
#         if pkg
#           t = t.gsub(pkg, "") # Remove the leading package name
#         end
#         t = t.gsub(/^\.*/, "")       # Remove leading `.`s

#         t.gsub(".", "::")  # Convert to Ruby namespacing syntax
#       else
#         ":#{name_for(f, T, f.type)}"
#       end

#       # Finally, generate the declaration
#       out = "%s %s, %s, %d" % [label, name, type, f.number]

#       if f.default_value
#         v = case f.type
#         when T::TYPE_ENUM
#           "%s::%s" % [type, f.default_value]
#         when T::TYPE_STRING, T::TYPE_BYTES
#           '"%s"' % [f.default_value.gsub('"', '\"')]
#         else
#           f.default_value
#         end

#         out += ", :default => #{v}"
#       end

#       puts out
#     end

#     # Determines the name for a
#     def name_for(b, mod, val)
#       b.name_for(mod, val).to_s.gsub(/.*_/, "").downcase
#     end

#     def compile(ns, file)
#       package_part = file.package ? "for #{file.package}" : ''
#       puts "## Generated from #{file.name} #{package_part}".strip
#       puts "require \"beefcake\""
#       puts

#       ns!(ns) do
#         Array(file.enum_type).each do |et|
#           enum!(et)
#         end

#         file.message_type.each do |mt|
#           define! mt
#         end

#         file.message_type.each do |mt|
#           message!(file.package, mt)
#         end
#       end
#     end

#     def ns!(modules, &blk)
#       if modules.empty?
#         blk.call
#       else
#         puts "module #{modules.first}"
#         indent do
#           ns!(modules[1..-1], &blk)
#         end
#         puts "end"
#       end
#     end

#     def puts(msg=nil)
#       if msg
#         c.puts(("  " * @n) + msg)
#       else
#         c.puts
#       end
#     end

#   end
# end
