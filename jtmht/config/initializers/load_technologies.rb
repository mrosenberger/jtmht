TECHNOLOGIESPATH = Rails.root + "app/assets/technologies/"

def rebuild_technologies_hash(technologies_root)
	Rails.logger.debug "=============================================="
	Rails.logger.debug "Rebuilding technologies hash"
	temp = HashWithIndifferentAccess.new
	technologies = Dir.entries(technologies_root).select { |technology| ! [".", ".."].include? technology }
	Rails.logger.debug "Technologies found: #{technologies}"
	technologies.each do |technology|
		Rails.logger.debug "  Processing technology '#{technology}'"
		# Also have to create entry for each synonym to the same technology
		temp[technology] = HashWithIndifferentAccess.new # technologies[:java]
		path_into_technology = technologies_root + (technology + "/")
		technology_json_file_contents = File.open(path_into_technology + "technology.json").read
		temp[technology][:meta] = ActiveSupport::JSON.decode technology_json_file_contents # Maybe wrap with hashwithindifferentaccess
		verbs = Dir.entries(path_into_technology + "verbs/").select { |verb| ! [".", ".."].include? verb }
		temp[technology][:verbs] = HashWithIndifferentAccess.new # technologies[:java][:verbs]
		technology_synonyms = temp[technology][:meta][:synonyms]
		Rails.logger.debug "    Technology found to have the following synonyms: #{technology_synonyms}. Associating synonyms..."
		technology_synonyms.each do |technology_synonym|
			Rails.logger.debug "      Associating synonym '#{technology_synonym}'' with technology '#{technology}'"
			temp[technology_synonym] = temp[technology]
		end
		Rails.logger.debug "    Done associating synonyms"
		Rails.logger.debug "    Processing verbs"
		verbs.each do |verb|
			Rails.logger.debug "      Processing verb '#{verb}'"
			temp[technology]['verbs'][verb] = HashWithIndifferentAccess.new # technologies[:java][:verbs][:open-file]
			# Also have to create entry for each synonym to the same verb
			path_into_verb = path_into_technology + ("verbs/" + verb + "/")
			verb_json_file_contents = File.open(path_into_verb + "verb.json").read
			temp[technology][:verbs][verb][:meta] = ActiveSupport::JSON.decode verb_json_file_contents
			verb_synonyms = temp[technology][:verbs][verb][:meta][:synonyms]
			Rails.logger.debug "        Verb found to have the following synonyms: #{verb_synonyms}. Associating synonyms..."
			verb_synonyms.each do |verb_synonym|
				Rails.logger.debug "          Associating synonym '#{verb_synonym}' with verb '#{verb}'"
				temp[technology]['verbs'][verb_synonym] = temp[technology]['verbs'][verb]
			end
			Rails.logger.debug "        Done associating verb synonyms"
			temp[technology][:verbs][verb][:versions] = HashWithIndifferentAccess.new
			versions = Dir.entries(path_into_verb + "versions/").select { |version| ! [".", ".."].include? version }
			
			Rails.logger.debug "        Verb found to have the following versions: #{versions}"
			Rails.logger.debug "        Processing versions..."
			versions.each do |version|
				Rails.logger.debug "            Processing version #{version}"
				version_file_path = path_into_verb + ("versions/" + version)
				temp[technology][:verbs][verb][:versions][version] = File.open(version_file_path).read
				Rails.logger.debug "            Loaded tutorial with technology='#{technology}', verb='#{verb}', version='#{version}"
			end
			Rails.logger.debug "        Done processing versions."
			Rails.logger.debug "      Done processing verb."
		end
		Rails.logger.debug "    Done processing verbs"
		Rails.logger.debug "  Done processing technology"
	end
	Rails.logger.debug "Done processing technologies"
	return temp
end

TECHNOLOGIES = rebuild_technologies_hash(TECHNOLOGIESPATH)