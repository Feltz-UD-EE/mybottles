class ProfilesController < ApplicationController
  def show
    @user = current_user
    @pending_invitations = invitations_sent_by_current_user.where(invitation_accepted_at: nil)
    @accepted_invitations = invitations_sent_by_current_user.where.not(invitation_accepted_at: nil)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    attrs = profile_params

    if attrs[:password].blank?
      attrs.delete(:password)
      attrs.delete(:password_confirmation)
    end

    if @user.update(attrs)
      bypass_sign_in(@user)
      redirect_to profile_path, notice: "Profile was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def invitations_sent_by_current_user
    User.where(invited_by_id: current_user.id).order(invitation_sent_at: :desc, created_at: :desc)
  end

  def profile_params
    params.expect(user: %i[ name email password password_confirmation theme_preference print_labels_by_default ])
  end
end
