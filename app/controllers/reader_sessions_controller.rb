class ReaderSessionsController < ReaderActionController

  no_login_required
  before_filter :require_reader, :only => :destroy
  radiant_layout { |controller| controller.layout_for :reader }
  
  def new
    @reader_session = ReaderSession.new
  end
  
  def create
    @reader_session = ReaderSession.new(params[:reader_session])
    if @reader_session.save
      if @reader_session.reader.activated? && @reader_session.reader.clear_password        
        @reader_session.reader.clear_password = ""                          # we forget the cleartext version on the first successful login after activation
        @reader_session.reader.save(false)
      end
      respond_to do |format|
        format.html { 
          flash[:notice] = "Hello #{@reader_session.reader.name}. Welcome back."
          redirect_back_or_to url_for(@reader_session.reader) 
        }
        format.js { 
          redirect_back_with_format(:js)
        }
      end
      
    else
      respond_to do |format|
        format.html { render :action => :new }
        format.js { render :action => :new, :layout => false }
      end
    end
  end
  
  def destroy
    current_reader_session.destroy
    flash[:notice] = "You are logged out. Bye!"
    redirect_back_or_to reader_login_url
  end

end