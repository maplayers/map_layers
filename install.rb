# Workaround a problem with script/plugin and http-based repos.
# See http://dev.rubyonrails.org/ticket/8189
Dir.chdir(Dir.getwd.sub(/vendor.*/, '')) do

def copy_files(source_path, destination_path, plugin_root)
  rails_root = ( defined?( RAILS_ROOT)) ? RAILS_ROOT : Rails.root 
  source, destination = File.join(File.expand_path(plugin_root), source_path), File.join( rails_root, destination_path)
  FileUtils.mkdir(destination) unless File.exist?(destination)
  FileUtils.cp_r(source, destination)
end

#copy_files("/public/.", "/public", File.dirname(__FILE__))

end
