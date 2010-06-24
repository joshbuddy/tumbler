module Bundler
  class Dsl
    unless method_defined?(:gemspec)
      def gemspec(opts = nil)
        path              = opts && opts[:path] || '.'
        name              = opts && opts[:name] || '*'
        development_group = opts && opts[:development_group] || :development
        gemspecs = Dir[File.join(path, "#{name}.gemspec")]
        case gemspecs.size
        when 1
          spec = Gem::Specification.load(gemspecs.first)
          spec.runtime_dependencies.each do |dep|
            gem dep.name, dep.requirement.to_s
          end
          group(development_group) do
            spec.development_dependencies.each do |dep|
              gem dep.name, dep.requirement.to_s
            end
          end
        when 0
          raise InvalidOption, "There are no gemspecs at #{path}."
        else
          raise InvalidOption, "There are multiple gemspecs at #{path}. Please use the :name option to specify which one."
        end
      end
    end
  end
end