class TutorialPagesController < ApplicationController

  def show
    @verb = params[:verb]
    @technology = params[:technology]
    @version = params[:version] || 'latest'
  end

  def canonize_name(name)
  	name.gsub(/[^0-9a-z _-]/i, '').gsub(' ', '-').gsub('_', '-').downcase
  end

end
