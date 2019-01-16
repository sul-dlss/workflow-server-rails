# frozen_string_literal: true

xml.lanes do
  @lanes.each do |lane|
    xml.lane(id: lane)
  end
end
