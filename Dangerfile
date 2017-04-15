danger.import_plugin 'danger_plugins/license_checker'

changed_files = git.added_files + git.modified_files
changed_swift = changed_files.uniq.lazy
  .select { |file| file.end_with? '.swift' }
  .reject { |file| file.start_with? 'Pods/' }
  .map { |file| file.gsub(/\{.*? => (.*?)\}/, '\1') }

license_checker.check(
  files: changed_swift,
  license_path: 'danger_plugins/required_license.txt'
)
