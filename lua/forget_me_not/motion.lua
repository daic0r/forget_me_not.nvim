local Motion = {
   vertical_motions = {
      ["j"] = "UP",
      ["k"] = "DOWN",
      [vim.api.nvim_replace_termcodes("<C-u>", true, false, true)] = "HALF_PAGE_UP",
      [vim.api.nvim_replace_termcodes("<C-d>", true, false, true)] = "HALF_PAGE_DOWN",
      [vim.api.nvim_replace_termcodes("<C-b>", true, false, true)] = "PAGE_UP",
      [vim.api.nvim_replace_termcodes("<C-f>", true, false, true)] = "PAGE_DOWN",
      ["G"] = "END_OF_FILE",
      ["gg"] = "BEGINNING_OF_FILE",
   },
   horizontal_motions = {
      ["h"] = "LEFT",
      ["l"] = "RIGHT",
      ["w"] = "WORD",
      ["p"] = "PARAGRAPH",
      ["e"] = "WORD_END",
      ["E"] = "CAPITAL_WORD_END",
      ["b"] = "WORD_START",
      ["W"] = "CAPITAL_WORD_FORWARD",
      ["B"] = "CAPITAL_WORD_BACKWARD",
      ["$"] = "END_OF_LINE",
      ["0"] = "BEGINNING_OF_LINE",
      ["ge"] = "BACK_TO_END_OF_WORD",
      ["gE"] = "BACK_TO_END_OF_CAPITAL_WORD",
      ["^"] = "FIRST_NON_BLANK",
      ["_"] = "LAST_NON_BLANK",
      ["f."] = "FIND_CHAR_FORWARD",
      ["F."] = "FIND_CHAR_BACKWARD",
      ["t."] = "FIND_CHAR_TILL_FORWARD",
      ["T."] = "FIND_CHAR_TILL_BACKWARD",
   },
   text_objects = {
      ["iw"] = "INNER_WORD",
      ["aw"] = "AROUND_WORD",
      ["iW"] = "INNER_CAPITAL_WORD",
      ["aW"] = "AROUND_CAPITAL_WORD",
      ["ip"] = "INNER_PARAGRAPH",
      ["ap"] = "AROUND_PARAGRAPH",
      ["is"] = "INNER_SENTENCE",
      ["as"] = "AROUND_SENTENCE",
      ["i%["] = "INNER_BRACKET",
      ["a%["] = "AROUND_BRACKET",
      ["i%]"] = "INNER_BRACKET",
      ["a%]"] = "AROUND_BRACKET",
      ["iB"] = "INNER_BRACE",
      ["aB"] = "AROUND_BRACE",
      ["i%("] = "INNER_PARENTHESIS",
      ["a%("] = "AROUND_PARENTHESIS",
      ["i%)"] = "INNER_PARENTHESIS",
      ["a%)"] = "AROUND_PARENTHESIS",
      ["i%{"] = "INNER_BRACE",
      ["a%{"] = "AROUND_BRACE",
      ["i%}"] = "INNER_BRACE",
      ["a%}"] = "AROUND_BRACE",
      ["i<"] = "INNER_TAG",
      ["a<"] = "AROUND_TAG",
      ["i>"] = "INNER_TAG",
      ["a>"] = "AROUND_TAG",
      ["i'"] = "INNER_SINGLE_QUOTE",
      ["a'"] = "AROUND_SINGLE_QUOTE",
      ["i%\""] = "INNER_DOUBLE_QUOTE",
      ["a%\""] = "AROUND_DOUBLE_QUOTE",
      ["i%`"] = "INNER_BACKTICK",
      ["a%`"] = "AROUND_BACKTICK",
   },
   categories = {
      VERTICAL = 0,
      HORIZONTAL = 1,
      TEXT_OBJECT = 2,
   },
}

Motion.metatable = {
   __index = Motion,
   __eq = function(lhs, rhs)
      return lhs.motion == rhs.motion and lhs.category == rhs.category
   end,
   __tostring = function(self)
      return self:is_valid() and self.motion or ""
   end,
}

-- Pattern matching for motions
-- local motion_mt = {
--    __index = function(table, key)
--       for keys, name in pairs(table) do
--          if string.match(keys, "^" .. key) then
--             return name
--          end
--       end
--       return nil
--    end,
-- }
-- setmetatable(Motion.vertical_motions, motion_mt)
-- setmetatable(Motion.horizontal_motions, motion_mt)

-- @param motion: string
-- @return Motion
function Motion.new(motion)
   local ret = {
      motion = nil,
      category = nil,
   }
   setmetatable(ret, Motion.metatable)
   if motion ~= nil then
      ret:fill_motion(motion)
   end
   return ret
end

function Motion.match_motion(str)
   for keys, _ in pairs(Motion.vertical_motions) do
      local match = string.match(str, "^" .. keys)
      if match then
         return match, Motion.categories.VERTICAL
      end
   end
   for keys, _ in pairs(Motion.horizontal_motions) do
      local match = string.match(str, "^" .. keys)
      if match then
         return match, Motion.categories.HORIZONTAL
      end
   end
   for keys, _ in pairs(Motion.text_objects) do
      local match = string.match(str, "^" .. keys)
      if match then
         return match, Motion.categories.TEXT_OBJECT
      end
   end
   return nil, nil
end

function Motion:fill_motion(keys)
   local match, kind = Motion.match_motion(keys)
   if match then
      self.motion = match
      self.category = kind
      return true
   end
   return false
end

-- @param str: string
-- @return bool, string: true if str is a valid motion, false otherwise, and the
-- remaining string
function Motion:parse(str)
   if #str == 0 then
      return nil
   end
   for i = math.min(2, #str), 1, -1 do
      local keys = string.sub(str, 1, i)
      if self:fill_motion(keys) then
         return string.sub(str, i + 1)
      end
   end
   return nil
end

function Motion:is_valid()
   return self.motion ~= nil and self.category ~= nil
end

return Motion
