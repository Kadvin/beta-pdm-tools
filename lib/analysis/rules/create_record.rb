# encoding: utf-8
# @author Kadvin, Date: 11-12-22

require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_userpane
  if_file_like(userpane_pattern) do
    if_content_like(/Creating\s#{record_rule_ptn}\./) do
      identified_by('create-record-#{$1}')
      title_will_be('创建记录规则(#{$1})')
      original_task_as(:title)
    end
    if_content_like(/Created\s#{record_rule_ptn}\./) do
      identified_by('create-record-#{$1}')
      title_will_be('成功创建记录规则(#{$1})')
    end
    if_content_like(/Create\s#{record_rule_ptn}\sfailed,\sbecause\sof:.*/) do
      identified_by('create-record-#{$1}')
      title_will_be('创建记录规则(#{$1})失败')
    end
    if_content_like(/Creating\s#{record_rule_ptn}\sfor\s#{mo_simple_ptn}/) do
      identified_by('create-record-#{$1}')
      title_will_be('为MO(#{$2})创建记录规则(#{$1})')
    end
    if_content_like(/Created\s#{record_rule_ptn}\sfor\s#{mo_simple_ptn}/) do
      identified_by('create-record-#{$1}')
      title_will_be('成功为MO(#{$2})创建记录规则(#{$1})')
    end
    if_content_like(/\w\sbroadcast\s#{/ModelEvent(eventType: `afterCreate`, modelClass: `PsRecordRule`, model:.*"name"\s*:\s*"\([^\"]*\)".*)/}/) do
      identified_by('create-record-#{$1}')
      title_will_be('保存记录到数据库(#{$1})')
    end
    if_content_like(/Dispatching\s#{create_record_event_ptn}\sto\s#{engine_ptn}/) do
      identified_by('create-record-#{$1}')
      title_will_be('派发记录规则(#{$1})到引擎(#{$3})')
    end
    if_content_like(/Dispatched\s#{create_record_event_ptn}\sto\s#{engine_ptn}/) do
      identified_by('create-record-#{$1}')
      title_will_be('成功派发记录规则(#{$1})到引擎(#{$3})')
    end
    if_content_like(/Dispatch\s#{create_record_event_ptn}\sfailed,\sbecause\sof:.*/) do
      identified_by('create-record-#{$1}')
      title_will_be('派发记录规则(#{$1})失败')
    end
  end

  # Configure log rule for se_commander
  if_file_like(commander_pattern) do

    if_content_like(/Receive\s'#{create_record_event_ptn}'/) do
      identified_by('create-record-#{$1}')
      title_will_be('接收到记录规则(#{$1})的创建事件')
    end

    if_content_like(/Process\s'#{create_record_event_ptn}'\ssuccess/) do
      identified_by('create-record-#{$1}')
      title_will_be('处理记录规则(#{$1})的创建事件')
    end

    if_content_like(/Process\s'#{create_record_event_ptn}'\sfailed,\sbecause\sof:\s/) do
      identified_by('create-record-#{$1}')
      title_will_be('处理记录规则(#{$1})的创建事件失败')
    end

    if_content_like(/Publish\s'#{create_record_event_ptn}'\sto\s'(.*)'/) do
      identified_by('create-record-#{$1}')
      title_will_be('发布记录规则(#{$1})的创建事件到事件队列(#{$2})')
    end
  end

  # Configure log rule for se_scheduler
  if_file_like(scheduler_pattern) do

      if_content_like(/Receive\s'#{create_record_event_ptn}'/) do
        identified_by('create-record-#{$1}')
        title_will_be('接收到记录规则(#{$1})的创建事件')
      end

      if_content_like(/Process\s'#{create_record_event_ptn}'\ssuccess/) do
        identified_by('create-record-#{$1}')
        title_will_be('处理记录规则(#{$1})的创建事件')
      end

      if_content_like(/Process\s'#{create_record_event_ptn}'\sfailed,\sbecause of:\s.*/) do
        identified_by('create-record-#{$1}')
        title_will_be('处理记录规则(#{$1})的创建事件失败')
      end
      if_content_like(/Starting\s'#{record_rule_ptn}'/) do
        identified_by('create-record-#{$1}')
        title_will_be('启动记录规则(#{$1})')
      end
      if_content_like(/[Ss]tart\s#{record_rule_ptn}\sfailed,\sbecause\sof:\s.*/) do
        identified_by('create-record-#{$1}')
        title_will_be('启动记录规则(#{$1})发生错误')
      end
      if_content_like(/Started\s'#{record_rule_ptn}'\sdone/) do
        identified_by('create-record-#{$1}')
        title_will_be('启动记录规则(#{$1})结束')
      end
  end

end
