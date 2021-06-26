require "./token.cr"

module FayrantLang
  class Lexer
    @@regexes : Array(Tuple(Regex, TokenType)) = [
      {
        /^(func)\b/, TokenType::FUNC,
      }, {
        /^(class)\b/, TokenType::CLASS,
      }, {
        /^(constructor)\b/, TokenType::CONSTRUCTOR,
      }, {
        /^(if)\b/, TokenType::IF,
      }, {
        /^(else)\b/, TokenType::ELSE,
      }, {
        /^(while)\b/, TokenType::WHILE,
      }, {
        /^(for)\b/, TokenType::FOR,
      }, {
        /^(var)\b/, TokenType::VAR,
      }, {
        /^(return)\b/, TokenType::RETURN,
      }, {
        /^(break)\b/, TokenType::BREAK,
      }, {
        /^(continue)\b/, TokenType::CONTINUE,
      }, {
        /^(true)\b/, TokenType::TRUE,
      }, {
        /^(false)\b/, TokenType::FALSE,
      }, {
        /^(null)\b/, TokenType::NULL,
      }, {
        /^([a-zA-Z_][a-zA-Z0-9_]*)/, TokenType::IDENTIFIER,
      }, {
        /^(\{)/, TokenType::L_BRACE,
      }, {
        /^(\})/, TokenType::R_BRACE,
      }, {
        /^(\()/, TokenType::L_PAREN,
        # some weird thing going on with syntax highlightning, ignore this line )/
      }, {
        /^(\))/, TokenType::R_PAREN,
      }, {
        /^(\.)/, TokenType::DOT,
      }, {
        /^(,)/, TokenType::COMMA,
      }, {
        /^(;)/, TokenType::SEMICOLON,
      }, {
        /^(")/, TokenType::QUOTE,
      }, {
        /^(==)/, TokenType::OP_EQ,
        # must be before =
      }, {
        /^(=)/, TokenType::EQUAL,
      }, {
        /^(\+=)/, TokenType::EQUAL_PLUS,
      }, {
        /^(-=)/, TokenType::EQUAL_MINUS,
      }, {
        /^(\*=)/, TokenType::EQUAL_TIMES,
      }, {
        /^(\/=)/, TokenType::EQUAL_DIV,
      }, {
        /^(\\=)/, TokenType::EQUAL_DIV_INV,
      }, {
        /^(%=)/, TokenType::EQUAL_MOD,
      }, {
        /^(\^=)/, TokenType::EQUAL_EXPT,
      }, {
        /^(&=)/, TokenType::EQUAL_AND,
      }, {
        /^(\|=)/, TokenType::EQUAL_OR,
      }, {
        /^(\+\+=)/, TokenType::EQUAL_CONCAT,
      }, {
        /^(-)/, TokenType::OP_MINUS,
      }, {
        /^(!=)/, TokenType::OP_NEQ,
        # must be before !
      }, {
        /^(!)/, TokenType::OP_NEG,
      }, {
        /^(@)/, TokenType::OP_TO_STR,
      }, {
        /^(#)/, TokenType::OP_TO_NUM,
      }, {
        /^(\+\+)/, TokenType::OP_CONCAT,
        # must be before + token
      }, {
        /^(\+)/, TokenType::OP_PLUS,
      }, {
        /^(\*)/, TokenType::OP_TIMES,
      }, {
        /^(\/)/, TokenType::OP_DIV,
      }, {
        /^(\\)/, TokenType::OP_DIV_INV,
      }, {
        /^(%)/, TokenType::OP_MOD,
      }, {
        /^(\^)/, TokenType::OP_EXPT,
      }, {
        /^(&)/, TokenType::OP_AND,
      }, {
        /^(\|)/, TokenType::OP_OR,
      }, {
        /^(>=)/, TokenType::OP_GE,
        # must be before >
      }, {
        /^(<=)/, TokenType::OP_LE,
        # must be before <
      }, {
        /^(>)/, TokenType::OP_GT,
      }, {
        /^(<)/, TokenType::OP_LT,
      }, {
        /^(0b[01]+)/, TokenType::NUMBER,
      }, {
        /^(0x[0-9a-fA-F]+)/, TokenType::NUMBER,
      }, {
        /^(\d+(\.\d+)?)/, TokenType::NUMBER,
      },
    ]

    enum LexerContext
      InsideString
      InsideBrace
    end

    def initialize(@text : String)
      @index = 0
      @line = 1
      @char_in_line = 1
      @contextStack = [] of LexerContext
      @tokens = [] of Token
    end

    def match_str(regex : Regex, token_type : TokenType)
      if match = regex.match(@text[@index..-1])
        {match[0], token_type}
      end
    end

    def scan_tokens : Array(Token)
      while @index < @text.size
        if @contextStack.size == 0
          scan_tokens_default
        elsif @contextStack[-1] == LexerContext::InsideString
          scan_tokens_inside_string
        elsif @contextStack[-1] == LexerContext::InsideBrace
          scan_tokens_inside_brace
        end
      end

      return @tokens
    end

    def scan_tokens_default
      char = @text[@index]
      if char == ' ' || char == '\t'
        @index += 1
        @char_in_line += 1
      elsif char == '\n'
        @index += 1
        @line += 1
        @char_in_line = 1
      elsif char == '~'
        while char != '\n'
          @index += 1
          @char_in_line += 1
        end
        @index += 1
        @char_in_line += 1
      elsif found = @@regexes.map { |re, tt| match_str re, tt }.compact[0]?
        match = found[0]
        token_type = found[1]
        len = match.size

        loc = Location.new @line, @index, @index + len - 1
        token = Token.new token_type, match, loc
        @tokens << token

        if token_type == TokenType::QUOTE
          @contextStack << LexerContext::InsideString
        end

        @index += len
        @char_in_line += len
      else
        raise Exception.new "Unexpected token #{@text[@index]} in line #{@line} at position #{@char_in_line}!"
      end
    end

    def scan_tokens_inside_string
      line = @line
      str_start = @index
      str_end = @index
      str_frag = ""
      local_token : Token | Nil = nil

      while true
        if @index >= @text.size
          puts @tokens
          raise Exception.new "Unexpected end of string at index #{@index}"
        end
        char = @text[@index]

        if char == '"'
          @contextStack.pop
          loc = Location.new @line, @index, @index
          local_token = Token.new TokenType::QUOTE, "\"", loc
          break
        elsif char == '{'
          @contextStack << LexerContext::InsideBrace
          loc = Location.new @line, @index, @index
          local_token = Token.new TokenType::L_BRACE, "{", loc
          break
        elsif char == '\\'
          @index += 1
          if @index >= @text.size
            raise Exception.new "Unexpected end of string at #{@index} index!"
          end
          char2 = @text[@index]
          map = {
            'n'  => '\n',
            't'  => '\t',
            '"'  => '"',
            '\\' => '\\',
            '{'  => '{',
            '}'  => '}',
          }
          if char2 == 'u'
            @index += 1
            if @text[@index] != '{'
              raise Exception.new "Expected { after \\u at index #{@index}!"
            end
            buffer = ""
            loop do
              @index += 1
              char3 = @text[@index]
              break if char3 == '}'
              buffer += char3
            end
            case buffer[0..1]
              when "0x"
                str_frag += buffer[2..].to_i(16).chr
              when "0b"
                str_frag += buffer[2..].to_i(2).chr
              else
                str_frag += buffer.to_i.chr
            end
          elsif map.has_key? char2
            str_frag += map[char2]
          else
            raise Exception.new "Escaping #{char2} is not supported!"
          end
        elsif char == '}'
          raise Exception.new "Unexpected } at index #{@index}!"
        else
          if char == "\n"
            @line += 1
            @char_in_line = 1
          end
          str_frag += char
        end

        str_end = @index
        @index += 1
      end

      if str_end != str_start
        loc = Location.new line, str_start, str_end
        token = Token.new TokenType::STRING_FRAGMENT, str_frag, loc
        @tokens << token
      end
      if local_token
        @index += 1
        @tokens << local_token
      end
    end

    def scan_tokens_inside_brace
      char = @text[@index]
      if char == '{'
        @contextStack << LexerContext::InsideBrace
      elsif char == '}'
        @contextStack.pop
      end
      scan_tokens_default
    end

    def test_single_token(str : String) : TokenType | Nil
      res = @@regexes.find { |re, tt| re =~ str }
      if !res.is_a? Nil
        return res[1]
      end
    end
  end
end
