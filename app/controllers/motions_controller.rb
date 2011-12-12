class MotionsController < BaseController
  before_filter :ensure_group_member

  def new
    @motion = Motion.new(group: Group.find(params[:group_id]))
  end

  def destroy
    resource
    is_group_admin = @motion.group.admins.include?(current_user)
    if is_group_admin || @motion.author == current_user
      destroy! { @motion.group }
      flash[:notice] = "Motion deleted."
    else
      flash[:error] = "You do not have significant priviledges to do that."
      redirect_to @motion
    end
  end

  def show
    resource
    @user_already_voted = @motion.votes.where('user_id = ?', current_user).exists?
    @votes_for_graph = @motion.votes_graph_ready
  end

  def create
    @motion = Motion.create(params[:motion])
    @motion.author = current_user
    @motion.group = Group.find(params[:group_id])
    @motion.save
    @group_members = []
    @motion.group.memberships.each do |m|
      @group_members << m.user.email unless m.user.nil? or @motion.author == m.user or m.access_level == 'request'
    end
    GroupMailer.new_motion_created(@group_members, @motion.group, @motion).deliver!
    redirect_to motion_url(id: @motion.id)
  end

  def edit
    resource
    if (@motion.author == current_user) || (@motion.facilitator == current_user)
      edit!
    else
      flash[:error] = "Only the facilitator or author can edit a motion."
      redirect_to motion_url(@motion)
    end
  end

  private
  def ensure_group_member
    # NOTE: this method is currently duplicated in groups_controller,
    # we should figure out a way to DRY this up.
    if (params[:id] && (params[:id] != "new"))
      group = Motion.find(params[:id]).group
    elsif params[:group_id]
      group = Group.find(params[:group_id])
    end
    unless group.users.include? current_user
      if group.requested_users_include?(current_user)
        flash[:notice] = "Cannot access group yet... waiting for membership approval."
        redirect_to groups_url
      else
        redirect_to request_membership_group_url(group)
      end
    end
  end
end
