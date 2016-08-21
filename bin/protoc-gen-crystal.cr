require "../src/protobuf"

def log(str)
  STDERR.puts(str)
end

$indentation = 0
def indent(n = 2)
  $indentation += n
  yield
  $indentation -= n
end

req = Protobuf::CodeGeneratorRequest.from_protobuf(STDIN)
res = Protobuf::Generator.compile(req)

STDOUT.print(res.to_protobuf.rewind.to_s)

# file = req.proto_file.not_nil!.map do |file|
#   CodeGeneratorResponse::File.new(
#     name: File.basename(file.name.not_nil!, ".proto") + ".pb.cr",
#     content: compile_file(file, ns)
#   )
# end
# res = CodeGeneratorResponse.new(file: file)

# def str_puts(str, to_put)
#   str.puts "#{" " * $indentation}#{to_put}"
# end

# def append_enum(str, et)
#   str_puts str, "enum #{et.name}"
#   if !et.value.nil?
#     indent 2 do
#       et.value.not_nil!.each do |ev|
#         str_puts str, "#{ev.name} = #{ev.number}"
#       end
#     end
#   end
#   str_puts str, "end"
# end

# def append_message(str, mt, pkg = "")
#   str_puts str, nil

#   # guard against recursive structs
#   structure = !mt.field.nil? && mt.field.not_nil!.any? { |f| f.type_name && f.type_name.not_nil!.split(".").last == mt.name } ? "class" : "struct"

#   str_puts str, "#{structure} #{mt.name}"

#   indent 2 do
#     str_puts str, "include Protobuf::Message"
#     mt.enum_type.not_nil!.each { |et| append_enum(str, et) } if !mt.enum_type.nil?
#     mt.nested_type.not_nil!.each {|mt| append_message(str, mt, pkg)} if !mt.nested_type.nil?
#     str_puts str, "contract do"
#     indent 2 do
#       mt.field.not_nil!.each {|f| append_field(str, f, pkg)} if !mt.field.nil?
#     end
#     str_puts str, "end"
#   end
#   str_puts str, "end"
# end

# def append_field(str, f, pkg = "")
#   met = case f.label
#   when CodeGeneratorRequest::FieldDescriptorProto::Label::LABEL_OPTIONAL
#     "optional"
#   when CodeGeneratorRequest::FieldDescriptorProto::Label::LABEL_REQUIRED
#     "required"
#   when CodeGeneratorRequest::FieldDescriptorProto::Label::LABEL_REPEATED
#     "repeated"
#   end
#   type_name = if !f.type_name.nil?
#     t = f.type_name.not_nil!
#     t = t.sub(pkg, "") if pkg
#     t = t.sub(/^\.*/, "")
#     t.split(".").map(&.camelcase).join("::")
#   else
#     # TODO
#     ":#{f.type.to_s.sub(/^TYPE_/, "").downcase}"
#   end
#   field_desc = "#{met} :#{f.name.not_nil!.underscore}, #{type_name}, #{f.number}"
#   unless f.default_value.nil?
#     def_value = f.type == CodeGeneratorRequest::FieldDescriptorProto::Type::TYPE_STRING ?
#       "\"#{f.default_value}\"" :
#       f.type_name.nil? ?
#         f.default_value :
#         "#{type_name}[#{f.default_value}]" # enum
#     field_desc += ", default: #{def_value}"
#   end
#   if !f.options.nil? && f.options.not_nil!.packed
#     field_desc += "packed: true"
#   end
#   str_puts str, field_desc
# end

# def compile_file(file, ns : String? = nil)
#   String.build do |str|
#     package_part = file.package ? "for #{file.package}" : ""
#     str_puts str, "## Generated from #{file.name} #{package_part}".strip
#     str_puts str, "require \"protobuf\""
#     str_puts str, nil

#     unless ns.nil?
#       str_puts str, "module #{ns}"
#       $indentation += 2
#     end

#     pkg_splitted = [] of String
#     unless file.package.nil?
#       pkg_splitted = file.package.not_nil!.split(".").map(&.camelcase)
#       pkg_splitted.each do |n|
#         str_puts str, "module #{n}"
#         $indentation += 2
#       end
#     end

#     if !file.enum_type.nil?
#       file.enum_type.not_nil!.each { |et| append_enum(str, et) }
#     end

#     if !file.message_type.nil?
#       file.message_type.not_nil!.each {|mt| append_message(str, mt, file.package)}
#     end

#     pkg_splitted.each do |n|
#       $indentation -= 2
#       str_puts str, "end"
#     end

#     unless ns.nil?
#       str_puts str, "end"
#       $indentation -= 2
#     end
#   end
# end

# proto = res.to_protobuf

# STDOUT.print(proto.rewind.to_s)