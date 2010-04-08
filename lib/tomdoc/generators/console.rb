module TomDoc
  module Generators
    class Console < Generator
      def highlight(text)
        pygments(text, '-l', 'ruby')
      end

      def write_scope_header(scope, prefix = '')
        return if scope.tomdoc.to_s.empty?

        prefix = "#{prefix}#{scope.name}"
        bars   = 80 - (prefix.size + 4)

        write ('-' * bars) + ' <= ' + prefix
        write format_comment(scope.tomdoc)
      end

      def write_method(method, prefix = '')
        write '-' * 80
        write "#{prefix}#{method.name}#{args(method)}".bold, ''
        write format_comment(method.tomdoc)
      end

      def args(method)
        if method.args.any?
          '(' + method.args.join(', ') + ')'
        else
          ''
        end
      end

      def format_comment(comment)
        comment = comment.to_s

        # Strip leading comments
        comment.gsub!(/^# ?/, '')

        # Example code
        comment.gsub!(/(\s*Examples\s*(.+?)\s*Returns)/m) do
          $1.sub($2, highlight($2))
        end

        # Param list
        comment.gsub!(/^(\s*(\w+) +- )/) do
          param = $2
          $1.sub(param, param.green)
        end

        # true/false/nil
        comment.gsub!(/(true|false|nil)/, '\1'.magenta)

        # Strings
        comment.gsub!(/('.+?')/, '\1'.yellow)
        comment.gsub!(/(".+?")/, '\1'.yellow)

        # Symbols
        comment.gsub!(/(\s+:\w+)/, '\1'.red)

        # Constants
        comment.gsub!(/(([A-Z]\w+(::)?)+)/) do
          if constant?($1.strip)
            $1.split('::').map { |part| part.cyan }.join('::')
          else
            $1
          end
        end

        comment
      end
    end
  end
end
