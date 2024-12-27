-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.keymap.set

keymap("v", "<", "<gv^", opts)
keymap("v", ">", ">gv^", opts)

local function toggle_input_answer_output_split()
  local files = { "input.txt", "answer.txt", "output.txt" }
  local windows = {}

  -- Save the current window and buffer
  local current_win = vim.api.nvim_get_current_win()

  -- Check if each file's window is open
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    for _, file in ipairs(files) do
      if name:match(file) then
        windows[file] = win
      end
    end
  end

  -- If all windows are open, close them
  if windows[files[1]] and windows[files[2]] and windows[files[3]] then
    for _, win in pairs(windows) do
      vim.api.nvim_win_close(win, true)
    end
  else
    -- Ensure each file exists
    local function ensure_file(file)
      if vim.fn.filereadable(file) == 0 then
        vim.fn.writefile({}, file)
      end
    end
    for _, file in ipairs(files) do
      ensure_file(file)
    end

    -- Open the three files in a vertical split with horizontal splits for each file
    vim.cmd("50vsplit " .. files[1])
    vim.cmd("split " .. files[2])
    vim.cmd("split " .. files[3])
  end

  -- Refocus the original window
  vim.api.nvim_set_current_win(current_win)
end

-- Map the toggle function to a key, e.g., <leader>ioa
vim.keymap.set(
  "n",
  "<leader>io",
  toggle_input_answer_output_split,
  { desc = "Toggle input.txt, answer.txt, and output.txt in split view" }
)

-- Plugin for notifications
local notify = Snacks.notifier.notify

-- Function to compile, execute, and compare output
local function run_cpp_file()
  local file_path = vim.fn.expand("%:p")
  local binary_name = "tmp_exc"
  notify("Compiling and executing " .. file_path, "info")
  notify("binary name: " .. binary_name, "info")
  local compile_cmd = string.format("g++ %s -o %s 2>&1", file_path, binary_name)
  local execute_cmd = string.format("./%s < input.txt > output.txt 2> error.log", binary_name)

  -- Capture the current buffer number to return focus later
  local current_buf = vim.api.nvim_get_current_buf()

  -- Compile the C++ file and capture errors
  local compile_handle = io.popen(compile_cmd)
  local compile_output = compile_handle:read("*a")
  local compile_success = compile_handle:close()

  if not compile_success then
    -- Extract and display the first few lines of the error message
    local error_message = compile_output:match("^(.-)\n")
    notify("Compilation failed: " .. (error_message or "Unknown error"), "error")
    return
  end

  -- Spinner animation
  local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
  local spinner_index = 1
  local spinner_id = "execution_progress"
  local spinner_active = true

  -- Function to update the spinner
  local function update_spinner()
    if spinner_active then
      notify(
        "Execution in progress " .. spinner_frames[spinner_index],
        "info",
        { title = "Executing", id = spinner_id }
      )
      spinner_index = (spinner_index % #spinner_frames) + 1
      vim.defer_fn(update_spinner, 100) -- Update every 100ms
    end
  end

  -- Start the spinner
  update_spinner()

  -- Execute the binary asynchronously
  local execute_start = vim.loop.hrtime()
  vim.fn.jobstart(execute_cmd, {
    on_exit = function(_, exit_code)
      local execute_end = vim.loop.hrtime()
      spinner_active = false -- Stop the spinner

      if exit_code ~= 0 then
        -- Read the error log file
        local error_log = io.open("error.log", "r")
        local error_message = error_log:read("*a")
        error_log:close()
        notify(
          "Execution failed: " .. (error_message or "Unknown error"),
          "error",
          { id = "execution message", icon = "❌" }
        )
        return
      end

      -- Reload the output.txt buffer if it's open
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(buf):match("output.txt$") then
          vim.api.nvim_buf_call(buf, function()
            vim.cmd("edit")
          end)
        end
      end

      local function read_file_trimmed(file)
        local content = ""
        for line in io.lines(file) do
          content = content .. line:gsub("%s+", "")
        end
        return content
      end

      local output_content = read_file_trimmed("output.txt")
      local answer_content = read_file_trimmed("answer.txt")

      if output_content == answer_content then
        notify("passed", "info", { id = spinner_id, title = "verdict" })
      else
        notify("Wrong answer", "error", { id = spinner_id, title = "verdict" })
      end

      local execution_time_ms = (execute_end - execute_start) / 1e6
      local execution_time_s = execution_time_ms / 1e3
      local execution_time_min = execution_time_s / 60
      if execution_time_min > 1 then
        notify(string.format("Execution time: %.4f minutes", execution_time_min), "info", { title = "Time" })
      elseif execution_time_s > 1 then
        notify(string.format("Execution time: %.4f seconds", execution_time_s), "info", { title = "Time" })
      else
        notify(string.format("Execution time: %.2f milliseconds", execution_time_ms), "info", { title = "Time" })
      end

      -- Remove the executable binary
      -- local remove_success, remove_err = os.remove(binary_name)
      -- if not remove_success then
      --   notify("Failed to remove binary: " .. (remove_err or "Unknown error"), "error")
      -- end

      -- Return focus to the original buffer
      vim.api.nvim_set_current_buf(current_buf)
    end,
  })
end

-- Map the function to a key, e.g., <leader>cc
vim.keymap.set("n", "<leader>cc", run_cpp_file, { desc = "Compile, run, compare, and show execution time" })
