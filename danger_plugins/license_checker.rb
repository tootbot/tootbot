require 'open3'
require 'shellwords'

module Danger
  class LicenseChecker < Plugin
    def check(opts = {})
      unless license = get_license(opts)
        raise 'You have to provide the license'
      end

      unless files = get_files(opts)
        raise 'You have to provide files to check'
      end

      files.each do |file|
        cmd = "comm -12 - #{file.shellescape}"
        result, status = Open3.capture2(cmd, stdin_data: license)
        unless status.success? && result == license
          warn('Please fix the license header', file: file, line: 1)
        end
      end
    end

    private

    def get_files(opts)
      if files = opts.delete(:files)
        files
      elsif file = opts.delete(:file)
        [file]
      else
        nil
      end
    end

    def get_license(opts)
      if license = opts.delete(:license)
        license
      elsif path = opts.delete(:license_path)
        return IO.read(path)
      else
        nil
      end
    rescue
      nil
    end
  end
end
