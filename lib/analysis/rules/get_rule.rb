# encoding: utf-8
# @author yuan, Date: 2012-03-14
require "analysis/engine"

Analysis::Engine.configure do

  if_file_like(userpane_pattern) do
    if_content_like(/enter\sfind\sRecordRule/) do
      identified_by('list-record-rule')
      title_will_be('开始获取记录规则列表')
      original_task_as(:title)
    end

    if_content_like(/exit\sfind\sRecordRule/) do
      identified_by('list-record-rule')
      title_will_be('完成获取记录规则列表')
    end

    if_content_like(/enter\sfind\sRecordRule\swith\sruleKey\s*:\s*(.*)/x) do
      identified_by('get-record-rule-#{$1}')
      title_will_be('开始获取记录规则(#{$1})')
      original_task_as(:title)
    end

    if_content_like(/exit\sget\srecord\srule\swith\sruleKey\s*:\s*(.*)/x) do
      identified_by('get-record-rule-#{$1}')
      title_will_be('完成获取记录规则(#{$1})')
    end

    if_content_like(/enter\sget\sRecordRule\swidth\smoKey\s*:\s*(.+)/x) do
      identified_by('get-record-rule-with-mo-#{$1}')
      title_will_be('开始获取MO(#{$1})的记录规则')
      original_task_as(:title)
    end

    if_content_like(/exit\sget\sRecordRule\swidth\smoKey\s*:\s*(.+)/x) do
      identified_by('get-record-rule-with-mo-#{$1}')
      title_will_be('完成获取MO(#{$1})的记录规则')
    end

    if_content_like(/enter\sfind\sThresholdRule/) do
      identified_by('list-threshold-rule')
      title_will_be('开始获取阈值规则列表')
      original_task_as(:title)
    end

    if_content_like(/exit\sfind\sThresholdRule/) do
      identified_by('list-threshold-rule')
      title_will_be('完成获取阈值规则列表')
    end

    if_content_like(/enter\sfind\sThresholdRule\swith\sruleKey\s*:\s*(.*)/x) do
      identified_by('get-threshold-rule-#{$1}')
      title_will_be('开始获取阈值规则(#{$1})')
      original_task_as(:title)
    end

    if_content_like(/exit\sget\sThresholdRule\swith\sruleKey\s*:\s*(.*)/x) do
      identified_by('get-threshold-rule-#{$1}')
      title_will_be('完成获取阈值规则(#{$1})')
    end

    if_content_like(/enter\sget\sThresholdRule\swidth\smoKey\s*:\s*(.+)/x) do
      identified_by('get-threshold-rule-with-mo-#{$1}')
      title_will_be('开始获取MO(#{$1})的阈值规则')
      original_task_as(:title)
    end

    if_content_like(/exit\sget\sThresholdRule\swidth\smoKey\s*:\s*(.+)/x) do
      identified_by('get-threshold-rule-with-mo-#{$1}')
      title_will_be('完成获取MO(#{$1})的阈值规则')
    end
  end
end
