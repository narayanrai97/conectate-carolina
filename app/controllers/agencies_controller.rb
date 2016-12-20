class AgenciesController < ApplicationController

	def index
		@agencies = Agency.all
		#Code hash send info of all agencies to the view to get converted to JSON
		@hash = Gmaps4rails.build_markers(@agencies) do |agency, marker|
  		marker.lat agency.latitude
  		marker.lng agency.longitude
		marker.infowindow agency.name
		end
		if params[:search]
			@agencies = Agency.search(params[:search])
		else
			@agencies = Agency.all
		end

		@categories = Category.all
	end

	def show
		@agency = Agency.find(params[:id])
		#single agency info
		@hash = Gmaps4rails.build_markers(@agency) do |agency, marker|
  		marker.lat agency.latitude
		marker.lng agency.longitude
		marker.infowindow agency.name
		end
	end

	def new
		@agency = Agency.new
	end

	def create 
		@agency = Agency.new(agency_params)
		if @agency.save
			flash[:notice] = (t'flash_notice.success')
			redirect_to @agency
		else
			render 'new'
		end
	end

	def edit
		@agency = Agency.find(params[:id])
	end

	def update
		@agency = Agency.find(params[:id])
		if @agency.update_attributes(agency_params)
			flash[:notice] = (t'flash_notice.update')
			redirect_to @agency
		else
			render  'edit'
		end
	end

	def destroy
		@agency = Agency.find(params[:id])
		@agency.destroy
		flash[:notice] = t 'flash_notice.delete'
		redirect_to new_agency_url
	end


private
	def agency_params
		params.require(:agency).permit(:name, :address, :city, :state, :zipcode, :description, :contact, :phone, category_ids: [])
	end
end
