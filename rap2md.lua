--[[
@date 2019-01-23
@author zhhzhhz@163.com
@note rap文档转md文档
@usage lua rap2md
--]]


print '** v0.0.1 **'
print 'developing...'

--http request type
local reqType = {
  ['1'] = 'GET',
  ['2'] = 'POST',
  ['3'] = 'PUT',
  ['4'] = 'DELETE'
}

-- write a line
function write(f, l)
  f:write(l)
  f:write('\n')
end

-- write parameter title in md
function paramTitle(f)
  write(f, "|名称 |类型 |可选 |默认值 |说明 |备注 |")
  write(f, "| ---- | ---- | ---- | ---- | ---- | ---- |")
end

-- parse parameterlist
-- @param f 文件句柄
-- @param level 当前递归层级，从0开始
-- @paramList 参数数组
function parseParamList(f, level, paramList)
  if #paramList == 0 then
    write(f, "|  |  |  |  |  |  |")
    return
  end
  -- 用n个-缩进表示参数从属
  local prefix = ''
  if level>0 then
    prefix = '' --&nbsp;
  end
  for i = 1,level do
    prefix = prefix..'- '
  end

  local level = level + 1 --向下一级参数递归
  -- 遍历当前级别参数
  local option = '' --可选
  local default = '' --默认值
  local remark = '' --备注
  for i,v in ipairs(paramList) do
    option = ''
    v.dataType = string.gsub(v.dataType, '<', '&lt;')
    v.dataType = string.gsub(v.dataType, '>', '&gt;')
    --不要mock
    if string.find(v.remark, '@mock', 1) then
      v.remark = ''
    elseif string.find(v.remark, '可选参数') then
      option = 'Yes'
    end
    write(f, string.format("|%s%s |%s |%s |%s |%s |%s |", 
      prefix, v.identifier, v.dataType, option, default, v.name, v.remark))
    if #v.parameterList>0 then
      parseParamList(f, level, v.parameterList)
    end
  end
  
end

--read file
local f,e = io.open("api.json","r")
if not f then
  print(e)
  return
end

local txt = f:read('*a')
f:close()
if not txt or #txt == 0 then
  print 'invalid api.json'
  return
end
txt = string.gsub(txt, "\\'", "'")
txt = string.gsub(txt, "\\/", "/")

--parse json
local cjson = require('cjson')
local json = cjson.decode(txt)
local api = json.projectData

local f,e = io.open("api.md","w+")
if not f then
  print(e)
  return
end
local chapter= {'一','二','三','四','五','六','七','八','九','十'}


write(f, '# **'..api.name..'**\n')
write(f, '*Introduction: '..api.introduction..'*\n')
write(f, '*Authority: '..api.user.name..'*\n')
write(f, '*CreateDate: '..api.createDateStr..'*\n')
write(f, '')
for i,mod in ipairs(api.moduleList) do
  write(f, string.format('# %s、%s',chapter[i] or i, mod.name))
  for j,page in ipairs(mod.pageList) do
    write(f, string.format('## %s. %s', j, page.name))
    for k,action in ipairs(page.actionList) do
      write(f, string.format('### %s.%s %s', j, k, action.name))
      local reqtype = reqType[action.requestType]
      if not reqtype then
        print('unknow request type:'..action.requestType)
        return
      end
      write(f, '\n请求类型：'..reqtype)
      write(f, '\n接口地址：'..action.requestUrl)
      -- 请求参数
      write(f, '\n#### 请求参数')
      if reqtype == 'POST' then
        write(f, '\n##### Body：\n')
      else
        write(f, '\n##### Query：\n')
      end
      paramTitle(f)
      parseParamList(f, 0, action.requestParameterList)

      -- 返回参数
      write(f, '\n#### 返回数据')
      paramTitle(f)
      parseParamList(f, 0, action.responseParameterList)

      write(f, '')
    end
    write(f, '')
  end
  write(f, '')
  write(f, '')
end

f:close()