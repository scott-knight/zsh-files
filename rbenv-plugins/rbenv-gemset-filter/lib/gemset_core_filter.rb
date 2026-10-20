# When a project gemset is active (GEM_HOME set by rbenv-gemset) AND a
# Gemfile.lock is present, hide non-default gems that live in the Ruby *core*
# gemdir — unless that gem is named in Gemfile.lock.
#
# Effect:
#   - Core default gems stay available
#   - Lockfile deps that still live in core stay available (no delete needed)
#   - Junk / conflicting gems installed into core stay on disk but are invisible
#   - Everything in the project gemset stays visible
#
# No Gemfile.lock → no filtering (non-Bundler tooling unchanged).
# .ruby-gemset / active GEM_HOME is the only on/off switch (see exec hook).

return if defined?(GemsetCoreFilter::LOADED)

module GemsetCoreFilter
  LOADED = true

  module_function

  def core_dir
    @core_dir ||= Gem.default_dir
  end

  def gem_home
    ENV["GEM_HOME"].to_s
  end

  def active?
    home = gem_home
    !home.empty? && File.expand_path(home) != File.expand_path(core_dir)
  end

  def lockfile
    @lockfile ||= find_lockfile
  end

  def find_lockfile
    dir = Dir.pwd
    while dir && dir != "/"
      candidate = File.join(dir, "Gemfile.lock")
      return candidate if File.file?(candidate)
      parent = File.dirname(dir)
      break if parent == dir

      dir = parent
    end
    nil
  end

  def lockfile_names
    @lockfile_names ||= parse_lockfile_names(lockfile)
  end

  def parse_lockfile_names(path)
    return nil unless path

    names = {}
    in_specs = false
    File.foreach(path) do |line|
      if line.start_with?("GEM")
        in_specs = true
        next
      end
      if in_specs && (line.start_with?("PLATFORMS") || line.start_with?("DEPENDENCIES") ||
                      line.start_with?("BUNDLED WITH") || line.start_with?("CHECKSUMS"))
        break
      end
      next unless in_specs

      # Top-level SPEC lines only: "    debug (1.11.1)"
      if line =~ /^\s{4}([A-Za-z0-9_-]+) \(/
        names[Regexp.last_match(1)] = true
      end
    end
    names
  end

  def allow?(spec)
    base = spec.respond_to?(:base_dir) ? spec.base_dir.to_s : ""
    return true if base.empty?
    return true unless File.expand_path(base) == File.expand_path(core_dir)
    return true if spec.default_gem?

    names = lockfile_names
    return true if names.nil? # no lockfile → don't filter

    names.key?(spec.name)
  end

  def install!
    return unless active?
    return unless lockfile
    return if Gem::Specification.respond_to?(:gemset_core_filter_installed)

    class << Gem::Specification
      attr_accessor :gemset_core_filter_installed

      alias_method :gemset_core_filter_stubs_without_filter, :stubs

      def stubs
        gemset_core_filter_stubs_without_filter.select { |s| GemsetCoreFilter.allow?(s) }
      end

      if method_defined?(:stubs_for) || private_method_defined?(:stubs_for)
        alias_method :gemset_core_filter_stubs_for_without_filter, :stubs_for

        def stubs_for(name)
          gemset_core_filter_stubs_for_without_filter(name).select { |s| GemsetCoreFilter.allow?(s) }
        end
      end
    end

    Gem::Specification.gemset_core_filter_installed = true
    Gem::Specification.reset
  end
end

GemsetCoreFilter.install!
