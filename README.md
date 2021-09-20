# Coq-Conjure

A simple [coq_nvim](https://github.com/ms-jpq/coq_nvim) completion source for [conjure](https://github.com/Olical/conjure).

## Usage

You can either manually register this completion source or have it autoregister itself.

```lua
-- Automatically 
vim.g.coq_conjure_autoregister = true

-- Manually
COQsources[< Some id >] = require('coq-conjure').source
```
