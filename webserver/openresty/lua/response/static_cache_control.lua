--
-- SPDX-License-Identifier: Apache-2.0
-- Description: The Lua file applies fallback Cache-Control headers to immutable static assets in OpenResty.
-- Copyright (c) 2026 honeok <i@honeok.com>

local ngx = ngx
local var = ngx.var
local response_headers = ngx.header

-- 仅处理 GET / HEAD 请求
local request_method = var.request_method

if request_method ~= "GET" and request_method ~= "HEAD" then
  return
end

-- 从 Nginx map 中读取静态资源兜底缓存策略
local static_cache_control = var.static_cache_control

if static_cache_control == nil or static_cache_control == "" then
  return
end

-- 仅处理正常响应, Range 响应和条件请求响应
local response_status = ngx.status

if response_status ~= 200 and response_status ~= 206 and response_status ~= 304 then
  return
end

-- 避免将 SPA fallback 或错误页面误判为静态资源
local content_type = response_headers["Content-Type"]

if
  type(content_type) == "string"
  and (content_type:find("text/html", 1, true) == 1 or content_type:find("application/xhtml+xml", 1, true) == 1)
then
  return
end

-- 尊重上游明确提供的缓存策略
local upstream_cache_control = var.upstream_http_cache_control
local upstream_expires = var.upstream_http_expires
local upstream_x_accel_expires = var.upstream_http_x_accel_expires

if
  (upstream_cache_control ~= nil and upstream_cache_control ~= "")
  or (upstream_expires ~= nil and upstream_expires ~= "")
  or (upstream_x_accel_expires ~= nil and upstream_x_accel_expires ~= "")
then
  return
end

-- 尊重其他响应过滤器已经设置的缓存策略
if response_headers["Cache-Control"] ~= nil or response_headers["Expires"] ~= nil then
  return
end

-- 带用户状态的响应不主动声明为公共缓存
local upstream_set_cookie = var.upstream_http_set_cookie

if response_headers["Set-Cookie"] ~= nil or (upstream_set_cookie ~= nil and upstream_set_cookie ~= "") then
  return
end

local authorization = var.http_authorization

if authorization ~= nil and authorization ~= "" then
  return
end

-- Vary: * 表示响应不能通过普通变体匹配复用
local vary = response_headers["Vary"]

if type(vary) == "string" then
  if vary:find("*", 1, true) then
    return
  end
elseif type(vary) == "table" then
  for i = 1, #vary do
    if vary[i]:find("*", 1, true) then
      return
    end
  end
end

-- 上游未提供缓存策略时, 由 OpenResty 补充客户端缓存策略
response_headers["Cache-Control"] = static_cache_control
