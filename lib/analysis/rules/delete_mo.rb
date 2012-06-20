# encoding: utf-8
# @author Kadvin, Date: 11-12-22

require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_userpane
  if_file_like(userpane_pattern) do
    # For Delete MO
    if_content_like(/Deleting #{mo_ptn}/).identified_by('delete-#{$4}').title_will_be('删除MO(#{$4})').original_task_as('删除MO(#{$1})')
    if_content_like(/Deleted #{mo_ptn}/).identified_by('delete-#{$4}').title_will_be('成功删除MO(#{$4})')
    if_content_like(/Delete #{mo_simple_ptn} failed, because of: (.*)/).identified_by('delete-#{$1}').title_will_be('删除MO(#{$1})失败(#{$2})')
    if_content_like(/Revoking #{mo_ptn} from #{engine_ptn}/).identified_by('delete-#{$4}').title_will_be('从引擎#{$5}回收MO(#{$4})')
    if_content_like(/Revoked #{mo_ptn} from #{engine_ptn}/).identified_by('delete-#{$4}').title_will_be('从引擎#{$5}回收MO(#{$4})成功')
  end

  if_file_like(commander_pattern) do
    # For Delete MO
    if_content_like(/Revoking #{mo_simple_ptn}/).title_will_be('回收:#{$1}').identified_by('delete-#{$1}')
    if_content_like(/Revoked #{mo_simple_ptn}/).title_will_be('完成回收:#{$1}').identified_by('delete-#{$1}')
    if_content_like(/Deleting #{mo_ptn} from local se db/).title_will_be('删除:#{$1}').identified_by('delete-#{$4}')
    if_content_like(/Deleted #{mo_ptn} from local se db/).title_will_be('完成删除:#{$1}').identified_by('delete-#{$4}')
  end

end
