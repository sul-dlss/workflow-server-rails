# frozen_string_literal: true

xml.objects(count: @objects.count) do
  @objects.each do |lane|
    xml.object(id: lane)
  end
end
