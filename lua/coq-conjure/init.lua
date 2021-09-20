local conjure_eval, conjure_promise = unpack({require("conjure.eval"), require("conjure.promise")})
local conjure_source = {["promise-id"] = nil, timer = nil}
local function map(f, ls)
  local tbl_0_ = {}
  for _, v in ipairs(ls) do
    tbl_0_[(#tbl_0_ + 1)] = f(v)
  end
  return tbl_0_
end
local function split_line(line, col)
  vim.validate({col = {col, "number"}, line = {line, "string"}})
  local c = math.min(math.max(0, col), #line)
  local lhs = string.sub(line, 1, c)
  local rhs = string.sub(line, (c + 1))
  return {lhs, rhs}
end
local function conjure_item__3elsp_item(c_item)
  local _1_
  do
    local _0_ = c_item.kind
    if (_0_ == "F") then
      _1_ = vim.lsp.protocol.CompletionItemKind.Function
    elseif (_0_ == "M") then
      _1_ = vim.lsp.protocol.CompletionItemKind.Function
    else
    _1_ = nil
    end
  end
  return {detail = c_item.info, kind = _1_, label = c_item.word}
end
local function should_call(m)
  return ((vim.bo.filetype == "clojure") and (m ~= nil) and (#m > 0))
end
local function abort()
  local _let_0_ = conjure_source
  local promise_id = _let_0_["promise-id"]
  local timer = _let_0_["timer"]
  if timer then
    timer:stop()
    timer:close()
    conjure_source["timer"] = nil
  end
  if promise_id then
    return conjure_promise:close(promise_id)
  end
end
local function complete_task(promise_id, callback)
  local function _0_()
    if conjure_promise["done?"](promise_id) then
      callback({items = map(conjure_item__3elsp_item, conjure_promise.close(promise_id))})
      return abort()
    end
  end
  return vim.schedule_wrap(_0_)
end
local function complete(m, callback)
  abort()
  conjure_source["promise-id"] = conjure_eval["completions-promise"](m)
  conjure_source["timer"] = vim.loop.new_timer()
  local _let_0_ = conjure_source
  local promise_id = _let_0_["promise-id"]
  local timer = _let_0_["timer"]
  return timer:start(100, 100, complete_task(promise_id, callback))
end
local conjure_regex = "[0-9a-zA-Z.!$%&*+/:<=>?#_~\\^\\-\\\\]\\+$"
local conjure_source_config
local function _0_(args, callback)
  local _let_0_ = args.pos
  local _ = _let_0_[1]
  local col = _let_0_[2]
  local _let_1_ = split_line(args.line, col)
  local before_cursor = _let_1_[1]
  local _0 = _let_1_[2]
  local m = vim.fn.matchstr(before_cursor, conjure_regex)
  if should_call(m) then
    return complete(m, callback)
  else
    return callback(nil)
  end
end
conjure_source_config = {fn = _0_, name = "Conjure"}
local function register()
  COQsources = (COQsources or {})
  COQsources[1000] = conjure_source_config
  return nil
end
return {register = register}
