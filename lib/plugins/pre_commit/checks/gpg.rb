=begin
Copyright 2014 Michal Papis <mpapis@gmail.com>

See the file LICENSE for copying permission.
=end

require 'pre-commit/checks/shell'
require 'pre-commit/error_list'

# :nodoc:
module PreCommit
  # :nodoc:
  module Checks

    #
    # pre-commit gem plugin to verify GPG signatures
    # when either the file or signature changes
    #
    class Gpg < Shell

      #
      # description of the plugin
      #
      def self.description
        "Finds GPG verification problems"
      end

      #
      # Finds files with signature and verifies them
      #
      # @param staged_files [Array<String>] list of files to check
      #
      # @return [nil|Array<PreCommit::ErrorList>] nil when no errors,
      #                                           list of errors otherwise
      def call(staged_files)
        signature_files = staged_files.map { |file| get_signature(file) }.compact.uniq
        return if signature_files.empty?

        errors = signature_files.map { |file| run_check(file) }.compact
        return if errors.empty?

        errors
      end

    private

      #
      # Checks if the given file is a signature or has one
      #
      # @param file [String] the file to check
      #
      # @return [nil|String] signature file when found, nil otherwise
      #
      def get_signature(file)
        if
          File.exist?(file + ".asc")
        then
          file + ".asc"
        elsif
          File.extname(file) == ".asc" &&
          File.exist?(file.sub(/.asc$/, ""))
        then
          file
        end
      end

      #
      # Verify given file GPG signature
      #
      # @param file [String] path to file to verify
      #
      # @return [nil|PreCommit::ErrorList] nil when file verified,
      #                                    ErrorList when no GPG found to verify
      #                                    ErrorList when verification failed
      #
      def run_check(file)
        if
          gpg_program
        then
          parse_error( execute(gpg_program, "--verify", file), file )
        else
          PreCommit::ErrorList.new(PreCommit::Line.new("No GPG program found to run verification", file))
        end
      end

      #
      # convert verification failure string into ErrorList
      #
      # @param errors [String] Output of failed GPG verification to parse
      # @param file   [String] File that versification failed
      #
      # @return [nil|PreCommit::ErrorList] nil when file verified,
      #                                    ErrorList when verification failed
      #
      def parse_error(errors, file)
        return if errors.nil?
        PreCommit::ErrorList.new(
          errors.split(/\n/).map do |error|
            PreCommit::Line.new(error, file)
          end
        )
      end

      #
      # @return [nil|String] path to the GPG binary or +nil+
      #
      def gpg_program
        @gpg_program ||= find_binary(:gpg2) || find_binary(:gpg)
      end

      #
      # @param binary [String] the name of binary to find on +PATH+
      #
      # @return [nil|String] path to the searched binary or +nil+
      #
      def find_binary(binary)
        result = execute_raw(
          "which #{binary}",
          :success_status => false
        ) and result.strip
      end

    end # class Gpg < Shell

  end
end
