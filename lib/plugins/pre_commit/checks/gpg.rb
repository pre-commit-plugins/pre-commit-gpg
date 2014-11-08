require 'pre-commit/checks/shell'

module PreCommit
  module Checks
    class Gpg < Shell

      def self.description
        "Finds GPG verification problems"
      end

      def call(staged_files)
        signature_files = staged_files.map { |file| get_signature(file) }.compact.uniq
        return if signature_files.empty?

        errors = signature_files.map { |file| run_check(file) }.compact
        return if errors.empty?

        errors.join("\n")
      end

    private

      def get_signature(file)
        if
          File.exist?(file + ".asc")
        then
          file + ".asc"
        elsif
          File.extname(file) == ".asc" &&
          File.exist(file.sub(/.asc$/, ""))
        then
          file
        end
      end

      def run_check(file)
        if
          gpg_program
        then
          execute(gpg_program, "--verify", file)
        else
          warn "No GPG program found, skipping verification of #{file}"
        end
      end

      def gpg_program
        @gpg_program ||=
          execute_strip("which gpg2", :success_status => false) ||
          execute_strip("which gpg",  :success_status => false)
      end

      def execute_strip(command, options = {})
        result = execute_raw(command, options) and result.strip
      end

    end
  end
end
