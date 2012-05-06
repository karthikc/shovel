require 'flickr_fu'

class HomeController < ApplicationController
  
  def start
    flickr = Flickr.new(File.join(Rails.root, 'config', 'flickr.yml'))
    redirect_to flickr.auth.url(:write)
  end
  
  def auth_callback
    @flickr = Flickr.new(File.join(Rails.root, 'config', 'flickr.yml'))
    @flickr.auth.frob = params['frob']
    session[:token] = @flickr.auth.token.token
    redirect_to :action => 'photos'
  end
  
  def photos
    @page = params[:id] || 1
    @page = @page.to_i
    flickr = Flickr.new(YAML.load_file(File.join(Rails.root, 'config', 'flickr.yml')).merge(:token => session[:token]))
    @search_result = flickr.photos.search({:user_id => "me", :per_page => 20, :page => @page})
  end
  
  def save_order
    params['photo_id'].each do |index, photo_id|
      uploaded_date_changed = params['uploaded_date_changed'][index]
      uploaded_at = params['uploaded_at'][index]
      save_uploaded_date(photo_id, uploaded_at) if uploaded_date_changed == "true"
    end
    redirect_to :action => 'photos'
  end
  
  def save_uploaded_date(photo_id, new_uploaded_at)
    flickr = Flickr.new(YAML.load_file(File.join(Rails.root, 'config', 'flickr.yml')).merge(:token => session[:token]))
    photo = flickr.photos.find_by_id(photo_id)
    new_uploaded_timestamp = Time.parse(new_uploaded_at).to_i
    flickr.send_request('flickr.photos.setDates', {:photo_id => photo.id, :date_posted => new_uploaded_timestamp}, :post)
  end
  
end