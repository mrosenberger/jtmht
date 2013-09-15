TECHNOLOGIESPATH = Rails.root + "app/assets/technologies/"

def rebuild_technologies_hash(technologies_root)
	temp = HashWithIndifferentAccess.new
	technologies = Dir.entries(technologies_root).select { |technology| ! [".", ".."].include? technology }
	technologies.each do |technology|
		# Also have to create entry for each synonym to the same technology
		temp[technology] = HashWithIndifferentAccess.new # technologies[:java]
		path_into_technology = technologies_root + (technology + "/")
		Rails.logger.debug(path_into_technology + "technology.json")
		technology_json_file_contents = File.open(path_into_technology + "technology.json").read
		temp[technology][:meta] = ActiveSupport::JSON.decode technology_json_file_contents # Maybe wrap with hashwithindifferentaccess
		verbs = Dir.entries(path_into_technology + "verbs/").select { |verb| ! [".", ".."].include? verb }
		temp[technology][:verbs] = HashWithIndifferentAccess.new # technologies[:java][:verbs]
		Rails.logger.debug(verbs)
		verbs.each do |verb|
			temp[technology]['verbs'][verb] = HashWithIndifferentAccess.new # technologies[:java][:verbs][:open-file]
			# Also have to create entry for each synonym to the same verb
			path_into_verb = path_into_technology + ("verbs/" + verb + "/")
			verb_json_file_contents = File.open(path_into_verb + "verb.json").read
			temp[technology][:verbs][verb][:meta] = ActiveSupport::JSON.decode verb_json_file_contents
			temp[technology][:verbs][verb][:versions] = HashWithIndifferentAccess.new
			versions = Dir.entries(path_into_verb + "versions/").select { |version| ! [".", ".."].include? version }
			versions.each do |version|
				version_file_path = path_into_verb + ("versions/" + version)
				temp[technology][:verbs][verb][:versions][version] = File.open(version_file_path).read
			end
		end
	end

	return temp
end

TECHNOLOGIES = rebuild_technologies_hash(TECHNOLOGIESPATH)