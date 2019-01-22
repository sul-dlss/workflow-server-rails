# frozen_string_literal: true

xml.objects(count: @objects.count) do
  @objects.each do |druid|
    xml.object(id: druid)
  end
end
