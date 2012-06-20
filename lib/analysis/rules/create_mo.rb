# encoding: utf-8
# @author Kadvin, Date: 11-12-22

require "analysis/engine"

Analysis::Engine.configure do

  # Configure log rule for ps_userpane
  if_file_like(userpane_pattern) do
    # For Create MO
    if_content_like(/Create #{mo_ptn}/) do
      original_task_as('创建:#{$1}(#{$2})') # 创建:NetworkDevice(192.168.0.1)
      title_will_be('开始创建:#{$1}(#{$2})') # 开始创建:NetworkDevice(192.168.0.1)
      identified_by('create-#{$2}')         # create-192.168.0.1
    end
    if_content_like(/Created #{mo_ptn}/) do
      title_will_be('创建:#{$1}(#{$2})成功') # 创建:NetworkDevice(192.168.0.1)成功
      identified_by('create-#{$2}')
    end
    if_content_like(/Assigning #{mo_ptn} to #{engine_ptn}/) do
       title_will_be('向引擎:#{$5}分配:#{$1}(#{$2})') # 向引擎:20.0.9.111分配:NetworkDevice(192.168.0.1)
       identified_by('create-#{$2}')
    end
    if_content_like(/Save #{mo_ptn} after retrieving/) do
      title_will_be('刷新后保存:#{$1}(#{$2})') # 刷新后保存:NetworkDevice(192.168.0.1)
      identified_by('create-#{$2}')
    end
  end

  if_file_like(commander_pattern) do
    # For Create MO
    # connector node, two identifier
    if_content_like(/Assigned #{mo_ptn}/) do
      title_will_be('被分配:#{$1}(#{$2})')# 被分配:NetworkDevice(192.168.0.1)
      identified_by('create-#{$2}')
    end

    # 这条日志可能产生于2个业务场景
    #  * 场景1：创建时自动刷新相应的MO，为这种任务设定 identify = create-$IP
    #  * 场景2：主动刷新某MO，为这种任务，设定 identify = retrieve-$IP
    # 其额外的identifier由其他场景的规则额外增加
    if_content_like(/Retrieving #{mo_ptn}/) do
      title_will_be('开始刷新:#{$1}(#{$2})') # 开始刷新:NetworkDevice(192.168.0.1)
      identified_by('create-#{$2}')
    end

    # 这条日志可能产生于3个业务场景
    #  * 场景1：创建时刷新
    #  * 场景2：主动刷新某MO
    #  * 场景3：读取某属性
    if_content_like(/Reading #{property_ptn} -> #{indicator_ptn} for #{mo_ptn}/, "Reading-Property") do
      title_will_be('读取:#{$2}(#{$3})的属性(#{$1})') # 读取:NetworkDevice(192.168.0.1)的属性(DeviceName)
      identified_by('create-#{$4}')              # 这个是该业务场景下会有的id
      identified_by('sampling-#{$6}-#{$2}')      # 对接通用流程
    end


    if_content_like(/Save #{mo_ptn}/) do
      title_will_be('在引擎上保存:#{$1}(#{$2})') # 在引擎上保存:NetworkDevice(192.168.0.1)
      identified_by('create-#{$2}')
    end
  end

end
require 'analysis/rules/sample'
