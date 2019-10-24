module Protobuf
  module Message

    macro contract_of (syntax, &blk)
      FIELDS = {} of Int32 => HashLiteral(Symbol, ASTNode)
      {{yield}}
      _generate_decoder {{syntax}}
      _generate_encoder {{syntax}}
      _generate_getters_setters
      _generate_hash_getters
    end

    macro contract(&blk)
      contract_of "proto2" {{blk}}
    end

    macro _add_field(tag, name, pb_type, options = {} of Symbol => Bool)
      {%
        t = Protobuf::PB_TYPE_MAP[pb_type] || pb_type
        FIELDS[tag] = {
          name:         name,
          pb_type:      pb_type,
          crystal_type: t,
          cast_type:    options[:repeated] ? "Array(#{t})?".id : options[:optional] ? "#{t}?".id : t.id,
          native:       !!Protobuf::PB_TYPE_MAP[pb_type],
          optional:     !!options[:optional] || !!options[:repeated],
          repeated:     !!options[:repeated],
          default:      options[:default],
          packed:       !!options[:packed],
        }
      %}
    end

    macro optional(name, type, tag, default = nil, repeated = false, packed = false)
      _add_field({{tag.id}}, {{name}}, {{type}}, {optional: true, default: {{default}}, repeated: {{repeated}}, packed: {{packed}}})
    end

    macro required(name, type, tag, default = nil)
      _add_field({{tag.id}}, {{name}}, {{type}}, {default: {{default}}})
    end

    macro repeated(name, type, tag, packed = false)
      optional({{name}}, {{type}}, {{tag}}, nil, true, {{packed}})
    end

    macro extensions(range)
      # puts "extensions: {{range.id}}"
    end

    macro _generate_decoder (pbVer)
      def self.from_protobuf(io)
        new(Protobuf::Buffer.new(io))
      end

      def initialize(buf : Protobuf::Buffer)
        {% for tag, field in FIELDS %}
          %var{tag} = nil
          %found{tag} = false
        {% end %}
        loop do
          tag_id, wire = buf.read_info
          case tag_id
          {% for tag, field in FIELDS %}
          when {{tag}}
            %found{tag} = true
            {%
              pb_type = Protobuf::PB_TYPE_MAP[field[:pb_type]]
              reader = !!pb_type ? "buf.read_#{field[:pb_type].id}" : "#{field[:crystal_type]}.new(buf)"
            %}
            {% if field[:repeated] %}\
              %var{tag} ||= [] of {{field[:crystal_type]}}
              {% if (pbVer != "proto2" && pb_type) || field[:packed] %}
                packed_buf_{{tag}} = buf.new_from_length.not_nil!
                loop do
                  %packed_var{tag} = {{(!!pb_type ? "packed_buf_#{tag}.read_#{field[:pb_type].id}" : "#{field[:crystal_type]}.new(packed_buf_#{tag})").id}}
                  break if %packed_var{tag}.nil?
                  %var{tag} << %packed_var{tag}
                end
              {% else %}
                {% if !field[:native] %}
                  if wire == 2
                    %embed_buf{tag} = buf.new_from_length.not_nil!
                    %value{tag} = {{field[:crystal_type]}}.new(%embed_buf{tag})
                  else
                    %value{tag} = {{reader.id}}
                  end
                {% else %}
                  %value{tag} = {{reader.id}}
                {% end %}
                break if %value{tag}.nil?
                %var{tag} << %value{tag}
              {% end %}
            {% else %}\
              {% if !field[:native] %}
                if wire == 2
                  %embed_buf{tag} = buf.new_from_length.not_nil!
                  %value{tag} = {{field[:crystal_type]}}.new(%embed_buf{tag})
                else
                  %value{tag} = {{reader.id}}
                end
              {% else %}
                %value{tag} = {{reader.id}}
              {% end %}
              break if %value{tag}.nil?
              %var{tag} = %value{tag}
            {% end %}\
          {% end %}
          when nil
            break
          else
            buf.skip(wire)
            next
          end
        end

        {% for tag, field in FIELDS %}
          {% if field[:optional] %}
            {% if field[:default] != nil %}
              @{{field[:name].id}} = %found{tag} ? (%var{tag}).as({{field[:cast_type]}}) : {{field[:default]}}
            {% else %}
              @{{field[:name].id}} = (%var{tag}).as({{field[:cast_type]}})
            {% end %}
          {% elsif field[:default] != nil %}
            @{{field[:name].id}} = %var{tag}.is_a?(Nil) ? {{field[:default]}} : (%var{tag}).as({{field[:cast_type]}})
          {% else %}
            @{{field[:name].id}} = (%var{tag}).as({{field[:cast_type]}})
          {% end %}
        {% end %}
      end

      def initialize(
        {% for tag, field in FIELDS %}
          {% unless field[:optional] %}
            @{{field[:name].id}} : {{field[:cast_type].id}},
          {% end %}
        {% end %}
        {% for tag, field in FIELDS %}
          {% if field[:optional] %}
            @{{field[:name].id}} : {{field[:cast_type].id}} = {{field[:default]}}{% unless field[:default] == nil %}.as({{field[:crystal_type]}}){% end %},
          {% end %}
        {% end %}
      )
      end
    end

    macro _generate_encoder(pbVer)
      def to_protobuf
        io = IO::Memory.new
        to_protobuf(io)
        io.rewind
      end

      def to_protobuf(io : IO, embedded = false)
        buf = Protobuf::Buffer.new(io)
        {% for tag, field in FIELDS %}
          %val{tag} = @{{field[:name].id}}
          %is_enum{tag} = %val{tag}.is_a?(Enum) || %val{tag}.is_a?(Array) && %val{tag}.first?.is_a?(Enum)
          %wire{tag} = Protobuf::WIRE_TYPES.fetch({{field[:pb_type]}}, %is_enum{tag} ? 0 : 2)
          {%
            pb_type = Protobuf::PB_TYPE_MAP[field[:pb_type]]
            writer = !!pb_type ? "buf.write_#{field[:pb_type].id}(@#{field[:name].id}.not_nil!)" : "buf.write_message(@#{field[:name].id}.not_nil!)"
          %}
          {% if field[:optional] %}
            if !@{{field[:name].id}}.nil?
              {% if field[:repeated] %}
                {% if (pbVer != "proto2" && pb_type) || field[:packed] %}
                  buf.write_info({{tag}}, 2)
                  buf.write_packed(@{{field[:name].id}}, {{field[:pb_type]}})
                {% else %}
                  @{{field[:name].id}}.not_nil!.each do |item|
                    buf.write_info({{tag}}, %wire{tag})
                    {%
                      writer = !!pb_type ? "buf.write_#{field[:pb_type].id}(item)" : "buf.write_message(item)"
                    %}
                    {{writer.id}}
                  end
                {% end %}
              {% else %}
                buf.write_info({{tag}}, %wire{tag})
                {{writer.id}}
              {% end %}
            end
          {% else %}
            buf.write_info({{tag}}, %wire{tag})
            {{writer.id}}
          {% end %}
        {% end %}
        io
      end
    end

    macro _generate_getters_setters
      {% for tag, field in FIELDS %}
        property {{field[:name].id}} : {{field[:cast_type]}}
      {% end %}
    end

    macro _generate_hash_getters
      def [](key : String)
        {% for tag, field in FIELDS %}
          return self.{{field[:name].id}} if {{field[:name].id.stringify}} == key
        {% end %}

        raise Protobuf::Error.new("Field not found: `#{key}`")
      end
    end

    def ==(other : Protobuf::Message)
      self.class == other.class &&
        to_protobuf.to_slice == other.to_protobuf.to_slice
    end
  end
end
