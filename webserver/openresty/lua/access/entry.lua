--
-- SPDX-License-Identifier: Apache-2.0
-- Description: The Lua module is the OpenResty access-phase entrypoint.
-- Copyright (c) 2026 honeok <i@honeok.com>

local block_methods = require("access.block_methods")
local block_user_agent = require("access.block_user_agent")
local block_sensitive_paths = require("access.block_sensitive_paths")

block_methods()
block_user_agent()
block_sensitive_paths()
