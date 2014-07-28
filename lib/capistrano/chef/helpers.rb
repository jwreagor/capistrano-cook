module Capistrano
  module Chef
    module Helpers
      private

      def debug?
        !!ENV['DEBUG']
      end
    end
  end
end
