-- Devvychrome colorscheme for Neovim / LazyVim
--
-- Monochrome matte industrial palette. Hierarchy is carried by luminance,
-- not hue. Saturation is zero across every value — the same rule that
-- governs the terminal palette, Waybar, Mako, Walker, and Wlogout.
--
-- Luminance model (4 tiers):
--   Structural (keywords, operators) — brightest  #dcdcdc–#ececec
--   Named      (identifiers, types)  — primary    #e0e0e0
--   Literal    (strings, numbers)    — mid         #a0a0a0–#b0b0b0
--   Non-code   (comments, ghosts)    — dim         #3a3a3a–#6f6f6f
--
-- Diagnostic severity = luminance (error = brightest, hint = dimmest).
-- This mirrors the Mako urgency-tier system.

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end

vim.g.colors_name = "devvychrome"
vim.o.background = "dark"

local c = {
  -- Surfaces (darkest → lightest)
  bg0  = "#161616", -- base background
  bg1  = "#1b1b1b", -- near-bg (ANSI black)
  bg2  = "#1d1d1d", -- cursorline / sidebars
  bg3  = "#222222", -- floats / statusline / waybar bg
  bg4  = "#2a2a2a", -- visual selection / border default
  bg5  = "#3a3a3a", -- bright-black / muted lines

  -- Text (dimmest → brightest)
  t_ghost = "#3a3a3a", -- line numbers, fold text, git gutter
  t_hint  = "#6f6f6f", -- hints, placeholders, disabled
  t_dim   = "#7a7a7a", -- very dim secondary
  t_med2  = "#858585", -- dim secondary
  t_med   = "#8a8a8a", -- secondary text
  t_acc   = "#9a9a9a", -- accent — active line nr, operators, borders
  t_mid   = "#a0a0a0", -- mid-bright: strings, tag attrs
  t_lo    = "#b0b0b0", -- literals band: numbers, constants
  t_body  = "#c8c8c8", -- body text
  t_curs  = "#d0d0d0", -- cursor
  t_text  = "#dcdcdc", -- near-primary (ANSI white): types, storage
  t_pri   = "#e0e0e0", -- primary foreground
  t_hi    = "#ececec", -- brightest text (ANSI bright-white)

  none = "NONE",
}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- ── Base UI ──────────────────────────────────────────────────────────
hi("Normal",           { bg = c.bg0,  fg = c.t_pri })
hi("NormalNC",         { bg = c.bg0,  fg = c.t_med })
hi("NormalFloat",      { bg = c.bg3,  fg = c.t_pri })
hi("FloatBorder",      { bg = c.bg3,  fg = c.bg5 })
hi("FloatTitle",       { bg = c.bg3,  fg = c.t_acc })
hi("FloatFooter",      { bg = c.bg3,  fg = c.t_hint })

hi("Cursor",           { bg = c.t_curs, fg = c.bg0 })
hi("CursorIM",         { bg = c.t_curs, fg = c.bg0 })
hi("TermCursor",       { bg = c.t_curs, fg = c.bg0 })
hi("CursorLine",       { bg = c.bg2 })
hi("CursorColumn",     { bg = c.bg2 })
hi("CursorLineNr",     { fg = c.t_acc,  bold = true })
hi("LineNr",           { fg = c.t_ghost })
hi("LineNrAbove",      { fg = c.bg5 })
hi("LineNrBelow",      { fg = c.bg5 })

hi("SignColumn",       { bg = c.bg0 })
hi("ColorColumn",      { bg = c.bg2 })
hi("FoldColumn",       { bg = c.bg0,  fg = c.bg5 })
hi("Folded",           { bg = c.bg2,  fg = c.t_hint })

hi("Visual",           { bg = c.bg4 })
hi("VisualNOS",        { bg = c.bg4 })
hi("Search",           { bg = c.bg5,  fg = c.t_pri })
hi("IncSearch",        { bg = c.t_acc, fg = c.bg0 })
hi("CurSearch",        { bg = c.t_acc, fg = c.bg0 })
hi("Substitute",       { bg = c.bg5,  fg = c.t_hi })

hi("StatusLine",       { bg = c.bg3,  fg = c.t_acc })
hi("StatusLineNC",     { bg = c.bg1,  fg = c.bg5 })
hi("StatusLineTerm",   { bg = c.bg3,  fg = c.t_acc })

hi("TabLine",          { bg = c.bg1,  fg = c.bg5 })
hi("TabLineSel",       { bg = c.bg3,  fg = c.t_pri })
hi("TabLineFill",      { bg = c.bg0 })
hi("WinBar",           { bg = c.bg2,  fg = c.t_acc })
hi("WinBarNC",         { bg = c.bg2,  fg = c.t_hint })

hi("WinSeparator",     { fg = c.bg4 })
hi("VertSplit",        { fg = c.bg4 })

hi("Pmenu",            { bg = c.bg3,  fg = c.t_body })
hi("PmenuSel",         { bg = c.bg4,  fg = c.t_pri })
hi("PmenuSbar",        { bg = c.bg3 })
hi("PmenuThumb",       { bg = c.bg5 })
hi("PmenuBorder",      { bg = c.bg3,  fg = c.bg5 })
hi("PmenuMatch",       { fg = c.t_hi, bold = true })
hi("PmenuMatchSel",    { bg = c.bg4,  fg = c.t_hi, bold = true })

hi("MatchParen",       { bg = c.bg5,  bold = true })
hi("NonText",          { fg = c.bg5 })
hi("SpecialKey",       { fg = c.bg5 })
hi("Whitespace",       { fg = c.bg4 })
hi("EndOfBuffer",      { fg = c.bg1 })
hi("Conceal",          { fg = c.t_hint })

hi("Title",            { fg = c.t_pri,  bold = true })
hi("Question",         { fg = c.t_acc })
hi("MoreMsg",          { fg = c.t_acc })
hi("ModeMsg",          { fg = c.t_acc,  bold = true })
hi("ErrorMsg",         { fg = c.t_hi,   bold = true })
hi("WarningMsg",       { fg = c.t_lo })
hi("QuickFixLine",     { bg = c.bg4 })
hi("WildMenu",         { bg = c.bg4,  fg = c.t_pri })
hi("Directory",        { fg = c.t_acc })

hi("SpellBad",         { undercurl = true, sp = c.t_lo })
hi("SpellCap",         { undercurl = true, sp = c.t_acc })
hi("SpellLocal",       { undercurl = true, sp = c.t_med })
hi("SpellRare",        { undercurl = true, sp = c.t_hint })

-- Diff — barely-tinted dark surfaces; luminance not hue carries signal
hi("DiffAdd",          { bg = "#1a231a" })
hi("DiffChange",       { bg = "#1a1a23" })
hi("DiffDelete",       { bg = "#231a1a" })
hi("DiffText",         { bg = c.bg5,  bold = true })
hi("Added",            { fg = c.t_med })
hi("Changed",          { fg = c.t_acc })
hi("Removed",          { fg = c.t_dim })

-- ── Standard syntax ──────────────────────────────────────────────────
-- comments: clearly dim — they carry no new information
hi("Comment",          { fg = c.bg5,  italic = true })

-- literals band: identifiable as values, not as code structure
hi("Constant",         { fg = c.t_lo })
hi("String",           { fg = c.t_mid })
hi("Character",        { fg = c.t_mid })
hi("Number",           { fg = c.t_lo })
hi("Float",            { fg = c.t_lo })
hi("Boolean",          { fg = c.t_text, bold = true })

-- identifiers: baseline (primary text)
hi("Identifier",       { fg = c.t_pri })
hi("Function",         { fg = c.t_pri })

-- structure: brightest — keywords define the shape of code
hi("Statement",        { fg = c.t_hi,   bold = true })
hi("Keyword",          { fg = c.t_hi,   bold = true })
hi("Conditional",      { fg = c.t_hi,   bold = true })
hi("Repeat",           { fg = c.t_hi,   bold = true })
hi("Label",            { fg = c.t_text })
hi("Operator",         { fg = c.t_acc })
hi("Exception",        { fg = c.t_text, bold = true })

-- preprocessor / includes: body level (metadata, not logic)
hi("PreProc",          { fg = c.t_body })
hi("Include",          { fg = c.t_body })
hi("Define",           { fg = c.t_body })
hi("Macro",            { fg = c.t_body })
hi("PreCondit",        { fg = c.t_body })

-- types: near-primary, important but not structural
hi("Type",             { fg = c.t_text })
hi("StorageClass",     { fg = c.t_text })
hi("Structure",        { fg = c.t_text })
hi("Typedef",          { fg = c.t_text })

-- special / delimiters: accent level
hi("Special",          { fg = c.t_acc })
hi("SpecialChar",      { fg = c.t_acc })
hi("Tag",              { fg = c.t_acc })
hi("Delimiter",        { fg = c.t_acc })
hi("SpecialComment",   { fg = c.t_hint })
hi("Debug",            { fg = c.t_dim })

hi("Underlined",       { underline = true })
hi("Ignore",           { fg = c.bg5 })
hi("Error",            { fg = c.t_hi,   bold = true })
hi("Todo",             { bg = c.bg4,  fg = c.t_hi, bold = true })

-- ── TreeSitter ───────────────────────────────────────────────────────
hi("@comment",                  { link = "Comment" })
hi("@comment.doc",              { fg = c.bg5,  italic = true })
hi("@comment.todo",             { link = "Todo" })
hi("@comment.error",            { link = "Todo" })
hi("@comment.warning",          { bg = c.bg4,  fg = c.t_lo, bold = true })
hi("@comment.note",             { bg = c.bg4,  fg = c.t_acc, italic = true })

hi("@string",                   { link = "String" })
hi("@string.escape",            { fg = c.t_acc })
hi("@string.special",           { fg = c.t_acc })
hi("@string.special.url",       { fg = c.t_acc, underline = true })
hi("@string.regexp",            { fg = c.t_mid })
hi("@character",                { link = "Character" })
hi("@number",                   { link = "Number" })
hi("@number.float",             { link = "Float" })
hi("@boolean",                  { link = "Boolean" })

hi("@variable",                 { fg = c.t_pri })
hi("@variable.builtin",         { fg = c.t_text, italic = true })
hi("@variable.parameter",       { fg = c.t_pri })
hi("@variable.member",          { fg = c.t_pri })
hi("@variable.parameter.builtin", { fg = c.t_text, italic = true })

hi("@function",                 { fg = c.t_pri })
hi("@function.builtin",         { fg = c.t_text, italic = true })
hi("@function.call",            { fg = c.t_pri })
hi("@function.macro",           { fg = c.t_text })
hi("@function.method",          { fg = c.t_pri })
hi("@function.method.call",     { fg = c.t_pri })

hi("@constructor",              { fg = c.t_text })
hi("@operator",                 { fg = c.t_acc })
hi("@punctuation.bracket",      { fg = c.t_acc })
hi("@punctuation.delimiter",    { fg = c.t_acc })
hi("@punctuation.special",      { fg = c.t_acc })

hi("@keyword",                  { fg = c.t_hi,   bold = true })
hi("@keyword.import",           { fg = c.t_body })
hi("@keyword.return",           { fg = c.t_hi,   bold = true })
hi("@keyword.operator",         { fg = c.t_hi,   bold = true })
hi("@keyword.conditional",      { fg = c.t_hi,   bold = true })
hi("@keyword.conditional.ternary", { fg = c.t_acc })
hi("@keyword.repeat",           { fg = c.t_hi,   bold = true })
hi("@keyword.exception",        { fg = c.t_text, bold = true })
hi("@keyword.coroutine",        { fg = c.t_text })
hi("@keyword.debug",            { fg = c.t_dim })
hi("@keyword.type",             { fg = c.t_text, bold = true })
hi("@keyword.modifier",         { fg = c.t_text })

hi("@type",                     { fg = c.t_text })
hi("@type.builtin",             { fg = c.t_text, italic = true })
hi("@type.definition",          { fg = c.t_text })
hi("@type.qualifier",           { fg = c.t_text })

hi("@constant",                 { fg = c.t_lo })
hi("@constant.builtin",         { fg = c.t_text, italic = true })
hi("@constant.macro",           { fg = c.t_body })

hi("@namespace",                { fg = c.t_body })
hi("@module",                   { fg = c.t_body })
hi("@module.builtin",           { fg = c.t_text, italic = true })
hi("@label",                    { fg = c.t_text })

hi("@tag",                      { fg = c.t_text })
hi("@tag.attribute",            { fg = c.t_mid })
hi("@tag.delimiter",            { fg = c.t_acc })
hi("@attribute",                { fg = c.t_body })
hi("@attribute.builtin",        { fg = c.t_body, italic = true })
hi("@annotation",               { fg = c.t_acc })

-- Markup (Markdown, RST, etc.)
hi("@markup.heading",           { fg = c.t_hi,   bold = true })
hi("@markup.heading.1",         { fg = c.t_hi,   bold = true })
hi("@markup.heading.2",         { fg = c.t_text, bold = true })
hi("@markup.heading.3",         { fg = c.t_lo,   bold = true })
hi("@markup.heading.4",         { fg = c.t_acc,  bold = true })
hi("@markup.heading.5",         { fg = c.t_med })
hi("@markup.heading.6",         { fg = c.t_dim })
hi("@markup.bold",              { bold = true })
hi("@markup.italic",            { italic = true })
hi("@markup.underline",         { underline = true })
hi("@markup.strikethrough",     { strikethrough = true })
hi("@markup.link",              { fg = c.t_acc, underline = true })
hi("@markup.link.url",          { fg = c.t_acc, underline = true })
hi("@markup.link.label",        { fg = c.t_pri })
hi("@markup.raw",               { fg = c.t_mid })
hi("@markup.raw.block",         { fg = c.t_mid })
hi("@markup.list",              { fg = c.t_acc })
hi("@markup.list.checked",      { fg = c.bg5 })
hi("@markup.list.unchecked",    { fg = c.t_acc })
hi("@markup.quote",             { fg = c.t_hint, italic = true })
hi("@markup.math",              { fg = c.t_lo })

hi("@diff.plus",                { fg = c.t_med })
hi("@diff.minus",               { fg = c.t_dim })
hi("@diff.delta",               { fg = c.t_acc })

-- ── Diagnostics ──────────────────────────────────────────────────────
-- Severity = luminance: error (critical) = brightest, hint = dimmest.
-- This mirrors the Mako urgency-tier convention.
hi("DiagnosticError",           { fg = c.t_hi })
hi("DiagnosticWarn",            { fg = c.t_lo })
hi("DiagnosticInfo",            { fg = c.t_acc })
hi("DiagnosticHint",            { fg = c.t_hint })
hi("DiagnosticOk",              { fg = c.bg5 })
hi("DiagnosticUnnecessary",     { fg = c.t_hint, italic = true })
hi("DiagnosticDeprecated",      { fg = c.t_dim,  strikethrough = true })

hi("DiagnosticUnderlineError",  { undercurl = true, sp = c.t_hi })
hi("DiagnosticUnderlineWarn",   { undercurl = true, sp = c.t_lo })
hi("DiagnosticUnderlineInfo",   { undercurl = true, sp = c.t_acc })
hi("DiagnosticUnderlineHint",   { undercurl = true, sp = c.t_hint })
hi("DiagnosticUnderlineOk",     { undercurl = true, sp = c.bg5 })

hi("DiagnosticSignError",       { fg = c.t_hi })
hi("DiagnosticSignWarn",        { fg = c.t_lo })
hi("DiagnosticSignInfo",        { fg = c.t_acc })
hi("DiagnosticSignHint",        { fg = c.t_hint })

-- Virtual text: even dimmer to avoid competing with real code
hi("DiagnosticVirtualTextError", { fg = c.t_dim,  italic = true })
hi("DiagnosticVirtualTextWarn",  { fg = c.bg5,    italic = true })
hi("DiagnosticVirtualTextInfo",  { fg = c.bg5,    italic = true })
hi("DiagnosticVirtualTextHint",  { fg = c.bg4,    italic = true })

-- ── LSP ──────────────────────────────────────────────────────────────
hi("LspReferenceText",          { bg = c.bg4 })
hi("LspReferenceRead",          { bg = c.bg4 })
hi("LspReferenceWrite",         { bg = c.bg5 })
hi("LspSignatureActiveParameter", { bg = c.bg4,  bold = true })
hi("LspInlayHint",              { fg = c.bg5,  italic = true })
hi("LspCodeLens",               { fg = c.t_hint, italic = true })

-- ── Git signs ────────────────────────────────────────────────────────
hi("GitSignsAdd",               { fg = c.bg5 })
hi("GitSignsChange",            { fg = c.bg5 })
hi("GitSignsDelete",            { fg = c.bg5 })
hi("GitSignsAddNr",             { fg = c.bg5 })
hi("GitSignsChangeNr",          { fg = c.bg5 })
hi("GitSignsDeleteNr",          { fg = c.bg5 })

-- ── Telescope ────────────────────────────────────────────────────────
hi("TelescopeNormal",           { bg = c.bg3,  fg = c.t_body })
hi("TelescopeBorder",           { bg = c.bg3,  fg = c.bg5 })
hi("TelescopeTitle",            { bg = c.bg3,  fg = c.t_acc })
hi("TelescopePromptNormal",     { bg = c.bg2,  fg = c.t_pri })
hi("TelescopePromptBorder",     { bg = c.bg2,  fg = c.bg5 })
hi("TelescopePromptTitle",      { bg = c.bg2,  fg = c.t_acc })
hi("TelescopeResultsNormal",    { bg = c.bg3,  fg = c.t_body })
hi("TelescopePreviewNormal",    { bg = c.bg1,  fg = c.t_body })
hi("TelescopeSelection",        { bg = c.bg4,  fg = c.t_pri })
hi("TelescopeSelectionCaret",   { fg = c.t_acc })
hi("TelescopeMatching",         { fg = c.t_hi, bold = true })

-- ── Snacks (LazyVim default pickers) ─────────────────────────────────
hi("SnacksIndent",              { fg = c.bg4 })
hi("SnacksIndentScope",         { fg = c.bg5 })
hi("SnacksNormal",              { bg = c.bg3,  fg = c.t_pri })
hi("SnacksBorder",              { bg = c.bg3,  fg = c.bg5 })
hi("SnacksPickerMatch",         { fg = c.t_hi, bold = true })
hi("SnacksPickerListCursorLine",   { bg = c.bg4 })
hi("SnacksPickerPreviewCursorLine",{ bg = c.bg2 })
hi("SnacksPickerInputBorder",      { bg = c.bg2, fg = c.bg5 })
hi("SnacksPickerInputTitle",       { fg = c.t_acc })
hi("SnacksDashboardHeader",     { fg = c.t_hi })
hi("SnacksDashboardIcon",       { fg = c.t_acc })
hi("SnacksDashboardDesc",       { fg = c.t_body })
hi("SnacksDashboardKey",        { fg = c.t_acc })
hi("SnacksDashboardFooter",     { fg = c.t_hint })
hi("SnacksDashboardSpecial",    { fg = c.t_acc })

-- ── Neo-tree ─────────────────────────────────────────────────────────
hi("NeoTreeNormal",             { bg = c.bg1,  fg = c.t_body })
hi("NeoTreeNormalNC",           { bg = c.bg1,  fg = c.t_body })
hi("NeoTreeEndOfBuffer",        { bg = c.bg1,  fg = c.bg1 })
hi("NeoTreeRootName",           { fg = c.t_acc, bold = true })
hi("NeoTreeDirectoryName",      { fg = c.t_body })
hi("NeoTreeDirectoryIcon",      { fg = c.t_acc })
hi("NeoTreeFileName",           { fg = c.t_body })
hi("NeoTreeFileIcon",           { fg = c.t_med })
hi("NeoTreeModified",           { fg = c.t_acc })
hi("NeoTreeGitAdded",           { fg = c.t_med })
hi("NeoTreeGitModified",        { fg = c.t_acc })
hi("NeoTreeGitDeleted",         { fg = c.t_dim })
hi("NeoTreeGitConflict",        { fg = c.t_lo,   bold = true })
hi("NeoTreeGitIgnored",         { fg = c.t_hint })
hi("NeoTreeGitUntracked",       { fg = c.t_dim })
hi("NeoTreeTabActive",          { bg = c.bg3,  fg = c.t_pri })
hi("NeoTreeTabInactive",        { bg = c.bg1,  fg = c.t_hint })
hi("NeoTreeTabSeparatorActive", { bg = c.bg3,  fg = c.bg3 })
hi("NeoTreeTabSeparatorInactive",{ bg = c.bg1, fg = c.bg1 })

-- ── Which-key ────────────────────────────────────────────────────────
hi("WhichKey",                  { fg = c.t_acc })
hi("WhichKeyGroup",             { fg = c.t_text, bold = true })
hi("WhichKeyDesc",              { fg = c.t_body })
hi("WhichKeySeparator",         { fg = c.t_hint })
hi("WhichKeyFloat",             { bg = c.bg3 })
hi("WhichKeyBorder",            { bg = c.bg3,  fg = c.bg5 })
hi("WhichKeyTitle",             { bg = c.bg3,  fg = c.t_acc })

-- ── Notify ───────────────────────────────────────────────────────────
-- Severity luminance matches DiagnosticXxx and Mako urgency tiers
hi("NotifyERRORBorder",         { fg = c.bg5 })
hi("NotifyWARNBorder",          { fg = c.bg5 })
hi("NotifyINFOBorder",          { fg = c.bg5 })
hi("NotifyDEBUGBorder",         { fg = c.bg5 })
hi("NotifyTRACEBorder",         { fg = c.bg5 })
hi("NotifyERRORIcon",           { fg = c.t_hi })
hi("NotifyWARNIcon",            { fg = c.t_lo })
hi("NotifyINFOIcon",            { fg = c.t_acc })
hi("NotifyDEBUGIcon",           { fg = c.t_hint })
hi("NotifyTRACEIcon",           { fg = c.t_hint })
hi("NotifyERRORTitle",          { fg = c.t_hi })
hi("NotifyWARNTitle",           { fg = c.t_lo })
hi("NotifyINFOTitle",           { fg = c.t_acc })
hi("NotifyDEBUGTitle",          { fg = c.t_hint })
hi("NotifyTRACETitle",          { fg = c.t_hint })
hi("NotifyERRORBody",           { bg = c.bg3, fg = c.t_body })
hi("NotifyWARNBody",            { bg = c.bg3, fg = c.t_body })
hi("NotifyINFOBody",            { bg = c.bg3, fg = c.t_body })
hi("NotifyDEBUGBody",           { bg = c.bg3, fg = c.t_body })
hi("NotifyTRACEBody",           { bg = c.bg3, fg = c.t_body })

-- ── Flash / Hop ───────────────────────────────────────────────────────
hi("FlashBackdrop",             { fg = c.t_hint })
hi("FlashLabel",                { bg = c.t_acc, fg = c.bg0, bold = true })
hi("FlashCurrent",              { bg = c.bg5,  fg = c.t_hi, bold = true })
hi("FlashMatch",                { bg = c.bg4,  fg = c.t_pri })

-- ── Indent Blankline ─────────────────────────────────────────────────
hi("IblIndent",                 { fg = c.bg2 })
hi("IblScope",                  { fg = c.bg4 })
hi("IndentBlanklineChar",       { fg = c.bg2 })
hi("IndentBlanklineScopeChar",  { fg = c.bg4 })

-- ── Mini (LazyVim default statusline/tabline) ─────────────────────────
hi("MiniStatuslineModeNormal",  { bg = c.bg5,  fg = c.t_acc, bold = true })
hi("MiniStatuslineModeInsert",  { bg = c.bg5,  fg = c.t_pri, bold = true })
hi("MiniStatuslineModeVisual",  { bg = c.bg5,  fg = c.t_pri, bold = true })
hi("MiniStatuslineModeReplace", { bg = c.bg5,  fg = c.t_lo,  bold = true })
hi("MiniStatuslineModeCommand", { bg = c.bg5,  fg = c.t_text, bold = true })
hi("MiniStatuslineModeOther",   { bg = c.bg5,  fg = c.t_acc, bold = true })
hi("MiniStatuslineFilename",    { bg = c.bg3,  fg = c.t_body })
hi("MiniStatuslineDevinfo",     { bg = c.bg3,  fg = c.t_hint })
hi("MiniStatuslineFileinfo",    { bg = c.bg3,  fg = c.t_hint })
hi("MiniStatuslineInactive",    { bg = c.bg1,  fg = c.t_hint })

hi("MiniTablineCurrent",        { bg = c.bg3,  fg = c.t_pri })
hi("MiniTablineVisible",        { bg = c.bg1,  fg = c.t_body })
hi("MiniTablineHidden",         { bg = c.bg1,  fg = c.t_hint })
hi("MiniTablineModifiedCurrent",{ bg = c.bg3,  fg = c.t_acc })
hi("MiniTablineModifiedVisible",{ bg = c.bg1,  fg = c.t_acc })
hi("MiniTablineModifiedHidden", { bg = c.bg1,  fg = c.t_hint })
hi("MiniTablineFill",           { bg = c.bg0 })

hi("MiniJump",                  { bg = c.bg5,  fg = c.t_hi,  bold = true })
hi("MiniJump2dSpot",            { bg = c.t_acc, fg = c.bg0,  bold = true })
hi("MiniJump2dSpotAhead",       { bg = c.bg5,  fg = c.t_acc })
hi("MiniJump2dSpotUnique",      { bg = c.t_acc, fg = c.bg0,  bold = true })

hi("MiniPickBorder",            { bg = c.bg3,  fg = c.bg5 })
hi("MiniPickPrompt",            { bg = c.bg2,  fg = c.t_pri })
hi("MiniPickBorderText",        { bg = c.bg3,  fg = c.t_acc })
hi("MiniPickMatchCurrent",      { bg = c.bg4 })
hi("MiniPickMatchMarked",       { bg = c.bg5 })
hi("MiniPickMatchRanges",       { fg = c.t_hi, bold = true })

-- ── Trouble ──────────────────────────────────────────────────────────
hi("TroubleNormal",             { bg = c.bg1,  fg = c.t_body })
hi("TroubleText",               { fg = c.t_body })
hi("TroubleTitle",              { fg = c.t_acc, bold = true })
hi("TroubleFile",               { fg = c.t_acc })
hi("TroubleLocation",           { fg = c.t_hint })
hi("TroubleCount",              { fg = c.t_acc })

-- ── CMP completion ────────────────────────────────────────────────────
hi("CmpItemAbbrMatch",          { fg = c.t_hi,  bold = true })
hi("CmpItemAbbrMatchFuzzy",     { fg = c.t_lo,  bold = true })
hi("CmpItemKind",               { fg = c.t_acc })
hi("CmpItemMenu",               { fg = c.t_hint })
