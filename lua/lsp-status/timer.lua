--- Timer instance
local timer = nil
--- This flag is used to redraw one more time after the las LSP update.
-- NOTE: This is achieved by setting the redraw_flag to true if
-- vim.b.lsp_status_redraw is true and there has been an update. Next time if
-- vim.b.lsp_status_redraw is false (no update) it will still redraw the
-- statusline and this flag will be set to false.
local redraw_flag = false

--- Timer callback function
-- NOTE: This function uses get_lsp_statusline so that needs nvim api functions
-- so it should call in the vim.schedule_wrap()
local function timer_callback()
  -- Check if need to redraw
  local update_flag = vim.b.lsp_status_redraw
  if update_flag or redraw_flag then
    vim.b.lsp_status_redraw = false
    -- Schedule the command when it's safe to call it
    local new_state = require('lsp-status/statusline').get_lsp_statusline()
    if new_state ~= vim.b.lsp_status_statusline then
      vim.b.lsp_status_statusline = new_state
      vim.api.nvim_command('redrawstatus!')
      -- If this was an lsp update (update_flag is true) redraw also next time
      -- by setting redraw_flag
      redraw_flag = update_flag
    end
  end
end

--- Function to register a timer to update statusline
-- This function is called on attach of a LSP Server and will pull updates for
-- status line on a specific every interval of time. It will also schedule the
-- redraw of the status line on the main loop. This will reduce the lag for
-- servers that constantly update the messages like `rust-analyzer`. It will
-- set use the variable timer to schedule the updates.
-- TODO: This could error if the lsp is disconnected, the timer should be
-- stopped
local function register_timer()
  -- Guard the for an already defined timer
  if timer ~= nil then
    return
  end
  timer = vim.loop.new_timer()
  -- Execute the timer every 100 milliseconds
  -- NOTE: This could be 30 to get a 30 updates per seconds, but set to 100 to
  -- copy coc.nvim status interval
  timer:start(0, 100, vim.schedule_wrap(timer_callback))
end

local M = {
  timer = timer,
  register_timer = register_timer,
}

return M
