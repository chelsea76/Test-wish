module ApplicationHelper
  def handle_for_user(user)
    auth     = user.first_authorization
    provider = auth.provider
    link_to submitted_user_posts_path(user) do
      icon(provider) + ' ' + icon(:'angle-right') + ' ' +
        content_tag(:span, user.handle)
    end
  end

  def get_activity(activity)
    case activity.item_type
    when "Comment"
      activity.name + " has commented on your wish " + "<a href=#{post_comments_path(post_id: activity.post_id)}>" + activity.title + '</a>'
    when "ActsAsVotable::Vote"
      activity.name + " has votes your wish " + "<a href=#{post_comments_path(post_id: activity.post_id)}>" + activity.title + '</a>'
    end
  end
end
