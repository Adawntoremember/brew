# frozen_string_literal: true

module Language
  module Java
    def self.find_openjdk_formula(version = nil)
      can_be_newer = version&.end_with?("+")
      version = version.to_i

      openjdk = Formula["openjdk"]
      [openjdk, openjdk.versioned_formulae].flatten.find do |f|
        next false unless f.any_version_installed?

        if version != 0
          major = f.version.to_s[/\d+/].to_i
          next false unless major >= version
          next false unless major == version || can_be_newer
        end

        true
      end
    rescue FormulaUnavailableError
      nil
    end
    private_class_method :find_openjdk_formula

    def self.java_home(version = nil)
      f = find_openjdk_formula(version)
      return f.opt_libexec if f

      req = JavaRequirement.new [*version]
      raise UnsatisfiedRequirements, req.message unless req.satisfied?

      req.java_home
    end

    # @private
    def self.java_home_shell(version = nil)
      java_home(version).to_s
    end

    def self.java_home_env(version = nil)
      { JAVA_HOME: java_home_shell(version) }
    end

    def self.overridable_java_home_env(version = nil)
      { JAVA_HOME: "${JAVA_HOME:-#{java_home_shell(version)}}" }
    end
  end
end

require "extend/os/language/java"
