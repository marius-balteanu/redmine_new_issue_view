module LoginSupport
  private

  def login_as_admin
    admin = create :admin
    @request.session[:user_id] = admin.id
  end
end
