# encoding: utf-8
# @author yuan, Date: 2012-03-27
require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_adminpane
  if_file_like(adminpane_pattern) do
    if_content_like(/show\sdetail\sof\spackage\s:\s([^\s]+)\sstart/) do
      original_task_as('管理员查看探针包(#{$1})')
      title_will_be('开始查看探针包(#{$1})')
      identified_by('ap-show-probe-#{$1}')
    end

    if_content_like(/show\sdetail\sof\spackage\s:\s([^\s]+)\send/) do
      title_will_be('完成查看探针包(#{$1})')
      identified_by('ap-show-probe-#{$1}')
    end
  end

end
