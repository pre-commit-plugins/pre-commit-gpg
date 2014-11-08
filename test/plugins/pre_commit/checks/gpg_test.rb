require 'minitest_helper'
require 'plugins/pre_commit/checks/gpg'

describe PreCommit::Checks::Gpg do
  let(:check){ PreCommit::Checks::Gpg.new(nil, nil, []) }

  describe "private methods" do

    it "finds binaries" do
      check.send(:find_binary, "rake").must_match(/rake$/)
    end

    it "finds GPG" do
      check.send(:gpg_program).must_match(/gpg(2)?$/)
    end

    it "ignores non signed files" do
      Dir.chdir(project_dir) do
        check.send(:get_signature, "file").must_equal(nil)
      end
    end

    it "detects signatures" do
      Dir.chdir(project_dir) do
        check.send(:get_signature, "file.good.asc").must_equal("file.good.asc")
      end
    end

    it "detects signatures by files" do
      Dir.chdir(project_dir) do
        check.send(:get_signature, "file.wrong").must_equal("file.wrong.asc")
      end
    end

    it "errors when no GPG found" do
      check.stubs(:gpg_program).returns(nil)
      check.send(:run_check, "file.asc").to_s.must_equal("No GPG program found to run verification\nfile.asc\n\n")
    end

    it "verifies good signature" do
      Dir.chdir(project_dir) do
        check.send(:run_check, "file.good.asc").must_equal(nil)
      end
    end

    it "errors on wrong signature" do
      Dir.chdir(project_dir) do
        errors =
        check.send(
          :run_check,
          "file.wrong.asc"
        ).errors
        errors.size.must_equal(2)
        errors.map(&:file).must_equal(["file.wrong.asc", "file.wrong.asc"])
        errors[0].message.must_match(/\Agpg: Signature made .* using RSA key ID BF04FF17\Z/)
        errors[1].message.must_match(/\Agpg: BAD signature from "Michal Papis \(RVM signing\) <mpapis@gmail.com>".*\Z/)
      end
    end

  end # private methods


  describe "plugin methods" do

    it "has text description" do
      check.class.description.must_be_kind_of String
    end

    it "succeeds if nothing changed" do
      check.call([]).must_equal nil
    end


    it "succeeds if non signed file changed" do
      Dir.chdir(project_dir) do
        check.call(['file']).must_equal nil
      end
    end

    it "succeeds if matching file changed" do
      Dir.chdir(project_dir) do
        check.call(['file.good']).must_equal nil
      end
    end

    it "succeeds if matching signature file" do
      Dir.chdir(project_dir) do
        check.call(['file.good.asc']).must_equal nil
      end
    end

    it "fails if not matching file changed" do
      Dir.chdir(project_dir) do
        errors = check.call(['file.wrong'])
        errors.size.must_equal(1)
        errors[0].must_be_kind_of(PreCommit::ErrorList)
      end
    end

    it "fails if not matching signature file" do
      Dir.chdir(project_dir) do
        errors = check.call(['file.wrong.asc'])
        errors.size.must_equal(1)
        errors[0].must_be_kind_of(PreCommit::ErrorList)
      end
    end

  end # plugin methods

end
