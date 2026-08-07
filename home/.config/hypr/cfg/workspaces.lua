-- ━━━━━━━━━━━━━━━━ Workspace Rules ━━━━━━━━━━━━━━━━
-- https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.workspace_rule({ workspace = "1", monitor = MONITOR1, persistent = true, default = true })
hl.workspace_rule({ workspace = "2", monitor = MONITOR1, persistent = true })
hl.workspace_rule({ workspace = "3", monitor = MONITOR1, persistent = true })

hl.workspace_rule({ workspace = "6", monitor = MONITOR3, persistent = true, default = true })
hl.workspace_rule({ workspace = "7", monitor = MONITOR3, persistent = true })
hl.workspace_rule({ workspace = "8", monitor = MONITOR2, persistent = true, default = true })
hl.workspace_rule({ workspace = "9", monitor = MONITOR2, persistent = true })
