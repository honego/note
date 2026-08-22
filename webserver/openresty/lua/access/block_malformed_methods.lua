--
-- SPDX-License-Identifier: Apache-2.0
-- Description: The lua file cheaply rejects HTTP methods whose first byte is not an uppercase ASCII letter.
-- Copyright (c) 2026 honeok <i@honeok.com>

local ngx = ngx
local exit = ngx.exit
local get_method = ngx.req.get_method
local string_byte = string.byte

return function()
  local method_first_byte = string_byte(get_method() or "", 1)

  -- 仅过滤首字节明显异常的探测请求 不校验完整 method 也不限制扩展方法
  if not method_first_byte or method_first_byte < 65 or method_first_byte > 90 then
    return exit(444)
  end
end
