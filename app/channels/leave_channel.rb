class LeaveChannel < ApplicationCable::Channel
  def subscribed
    stream_from "leave_channel"
  end
end
