local MiniTest = require('mini.test')
local helpers = require('grug-far/test/helpers')

---@type NeovimChild
local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      helpers.initChildNeovim(child)
    end,
    -- Stop once all test cases are finished
    post_once = child.stop,
  },
})

T['can disable keymaps and they disappear from UI'] = function()
  helpers.childRunGrugFar(child, {
    keymaps = {
      replace = false,
      syncLine = '',
    },
  })
  helpers.childExpectScreenshot(child)
end

T['can open with icons disabled'] = function()
  helpers.childRunGrugFar(child, {
    icons = { enabled = false },
  })
  helpers.childExpectScreenshot(child)
end

T['can launch with :GrugFar'] = function()
  child.type_keys('<esc>:GrugFar<cr>')
  helpers.childWaitForScreenshotText(child, 'Search:')
  helpers.childExpectScreenshot(child)
end

T['can launch with :GrugFar ripgrep'] = function()
  child.type_keys('<esc>:GrugFar<cr>')
  helpers.childWaitForScreenshotText(child, 'ripgrep')
end

T['can search manually on insert leave or normal mode change'] = function()
  helpers.writeTestFiles({
    { filename = 'file1', content = [[ grug walks ]] },
    {
      filename = 'file2',
      content = [[ 
      grug talks and grug drinks
      then grug thinks
    ]],
    },
  })

  helpers.childRunGrugFar(child, {
    searchOnInsertLeave = true,
  })

  helpers.childWaitForScreenshotText(child, 'Search:')
  child.type_keys('<esc>cc', 'walks')
  vim.uv.sleep(100)
  helpers.childExpectScreenshot(child)

  child.type_keys('<esc>')
  helpers.childWaitForUIVirtualText(child, '1 matches in 1 files')
  helpers.childWaitForFinishedStatus(child)
  helpers.childExpectScreenshot(child)

  child.type_keys('0x')
  helpers.childWaitForUIVirtualText(child, '2 matches in 2 files')
  helpers.childWaitForFinishedStatus(child)
  helpers.childExpectScreenshot(child)
end

return T
