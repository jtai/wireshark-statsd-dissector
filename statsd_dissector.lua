local statsd = Proto("statsd","Statsd Protocol")

local pf_metric_name = ProtoField.new("Metric Name", "statsd.metric_name", ftypes.STRING)
local pf_value = ProtoField.new("Value", "statsd.value", ftypes.STRING)
local pf_metric_type = ProtoField.new("Metric Type", "statsd.metric_type", ftypes.STRING)

statsd.fields = { pf_metric_name, pf_value, pf_metric_type }

function statsd.dissector(tvbuf,pktinfo,root)
  local pktlen = tvbuf:reported_length_remaining()
  local tvbr = tvbuf:range(0,pktlen)

  -- <metric name>:<value>|<metric type>[|@<sample rate>]
  local payload = tvbr:string()
  local a, b, metric_name, value, metric_type = string.find(payload, "^([^:]+):([^|]+)|([^|]+)")

  if a then
    pktinfo.cols.protocol:set("Statsd")
    pktinfo.cols.info:set(payload)

    local pos = 0
    local tree = root:add(statsd, tvbr)

    tree:add(pf_metric_name, tvbuf:range(pos, metric_name:len()), metric_name)
    pos = pos + metric_name:len() + 1

    tree:add(pf_value, tvbuf:range(pos, value:len()), value)
    pos = pos + value:len() + 1

    tree:add(pf_metric_type, tvbuf:range(pos, metric_type:len()), metric_type)
    pos = pos + metric_type:len()
  end
end

DissectorTable.get("udp.port"):add(8125, statsd)