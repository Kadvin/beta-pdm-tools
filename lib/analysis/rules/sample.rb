# encoding: utf-8
# @author yuan, Date: 2012-03-13

require "analysis/engine"

Analysis::Engine.configure do
  if_file_like(commander_pattern) do

    # ==!!!Connector Node Here!!!!
    # 这条日志可能产生于5个业务场景
    #  * 场景1：创建时刷新
    #  * 场景2：主动刷新某MO
    #  * 场景3：读取某属性(触发新建读取指标的任务)
    #  * 场景4：执行某操作(触发新建执行操作的任务)
    #  * 场景5：直接读取某指标
    # 而且这条日志无法产生和上面一样的ID，也就是，从这条日志开始，下面的流程都是面向TASK，而不是面向MO的
    # 所以，这条日志必须要能很自然的和其上面的流程对接
    # 我采用的方案是，从这条以下的可复用流程，生成与具体业务场景无关的id，让上面的业务场景的前置流程生成能与这条日志的log相同的id
    #
    if_content_like(/Reading #{indicator_ptn} for #{mo_ptn} cause by #{member_ptn}/, "Reading-Indicator") do
      title_will_be('读取:#{$2}(#{$3})的指标(#{$1}) 根源为:#{$6}') # 读取:NetworkDevice(192.168.0.1)的指标(SystemInfo) 根源为:DeviceName
      # 与下面的通用业务流程对接，在这里设定通用业务流程相同的id: sampling-$mokey-$member_name
      # 其中的 member name 为 indicator name 或者 operation name，并非原始触发的property名称
      identified_by('sampling-#{$5}-#{$1}')
    end
    if_content_like(/Get Result for #{mo_ptn} \/ #{member_ptn} from cache: (.*)/m) do # 多行
      title_will_be('从Cache中获得:MO(#{$1})指标(#{$5})的结果')
      identified_by('sampling-#{$4}-#{$5}')
    end
    if_content_like(/Create #{task_ptn} for #{member_ptn}/, "Create-Task")do
      title_will_be('新建任务:#{$1}-#{$2} -> #{$4}') # 新建任务:$mokey-SystemInfo -> DeviceName
      identified_by('sampling-#{$1}-#{$2}')
    end
    if_content_like(/Wait #{task_ptn} for #{member_ptn}/, "Wait-Task") do
      title_will_be('等待任务:#{$1}-#{$2} -> #{$4}') # 等待任务:$mokey-SystemInfo -> DeviceName
      identified_by('sampling-#{$1}-#{$2}')
    end
    if_content_like(/Reuse #{task_ptn} for #{member_ptn}/, "Reuse-Task") do
      title_will_be('复用任务:#{$1}-#{$2} -> #{$4}') # 复用任务:$mokey-SystemInfo -> DeviceName
      identified_by('sampling-#{$1}-#{$2}')
    end
    if_content_like(/Read #{indicator_ptn} for #{mo_ptn}/, "Read-Indicator") do
      title_will_be('读到指标:#{$2}-#{$3} -> #{$1}')# 读到指标:$mokey-SystemInfo -> DeviceName
      identified_by('sampling-#{$5}-#{$1}')
    end
    if_content_like(/Read #{property_ptn} <- #{indicator_ptn} for #{mo_ptn}/) do
      title_will_be('读到:#{$3}(#{$4})的属性(#{$1})')# 读到:NetworkDevice(192.168.0.1)的属性(DeviceName)
      identified_by('sampling-#{$6}-#{$2}')
    end
  end

  if_file_like(sampling_pattern) do
    general_id = 'sampling-#{$1}-#{$2}'
    # For Create MO
    if_content_like(/Assigned #{task_ptn}/, "Assigned-Task") do
      title_will_be('被分配任务:#{$1}-#{$2}')
      identified_by(general_id)
    end
    if_content_like(/Queuing #{task_ptn}/, "Queuing-Task") do
      title_will_be('任务排队:#{$1}-#{$2}')
      identified_by(general_id)
    end
    if_content_like(/Executing #{task_ptn}/, "Executing-Task") do
      title_will_be('任务执行:#{$1}-#{$2}')
      identified_by(general_id)
    end
    if_content_like(/Choose #{probe_ptn} for #{task_ptn}/, "Choose-Probe-for-Task") do
      title_will_be('执行任务:#{$2}-#{$3} -> 选定探针:#{$1}')
      identified_by('sampling-#{$2}-#{$3}')
    end
    if_content_like(/Failed #{task_ptn}/, "Failed-Task") do
      title_will_be('任务失败:#{$1}-#{$2}')
      identified_by(general_id)
    end
    if_content_like(/Succeed #{task_ptn}/, "Succeed-Task") do
      title_will_be('任务成功:#{$1}-#{$2}')
      identified_by(general_id)
    end
    if_content_like(/Not found any Probe for #{task_ptn}/, "No-Probe-for-Task") do
      title_will_be('无法为任务:#{$1}-#{$2} 找到任何有效探针')
      identified_by(general_id)
    end
  end
end
