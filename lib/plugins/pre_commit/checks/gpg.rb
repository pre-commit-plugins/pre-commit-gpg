require 'pre-commit/checks/shell'
require 'pre-commit/error_list'

module PreCommit
  module Checks
    class Gpg < Shell

      # description of the plugin
      def self.description
        "Finds GPG verification problems"
      end

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

      # Checks if the given file is a signature or has one
      # @param file [String] the file to check
      # @return [nil|String] signature file when found, nil otherwise
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
      def run_check(file)
        if
          gpg_program
        then
          parse_error( execute(gpg_program, "--verify", file), file )
        else
          PreCommit::ErrorList.new(PreCommit::Line.new("No GPG program found to run verification", file))
        end
      end

      def parse_error(errors, file)
        return if errors.nil?
        PreCommit::ErrorList.new(
          errors.split(/\n/).map do |error|
            PreCommit::Line.new(error, file)
          end
        )
      end

      def gpg_program
        @gpg_program ||= find_binary(:gpg2) || find_binary(:gpg)
      end

      def find_binary(binary)
        result = execute_raw(
          "which #{binary}",
          :success_status => false
        ) and result.strip
      end

    end
  end
end
